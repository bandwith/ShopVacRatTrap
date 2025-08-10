#!/usr/bin/env python3
"""
Mouser Consolidation Analyzer
Analyze BOM to check if all components can be sourced from Mouser with better pricing
"""

import csv
import requests
import time
from datetime import datetime
import argparse

# Mapping of Adafruit components to Mouser equivalents
ADAFRUIT_TO_MOUSER_MAPPING = {
    # ESP32-S3 Development Boards
    "5323": {  # ESP32-S3 Feather
        "mouser_alternatives": [
            {
                "part": "356-ESP32-S3-DEVKTC1",
                "manufacturer": "Espressif",
                "description": "ESP32-S3-DevKitC-1 Development Board",
            },
            {
                "part": "915-ESP32-S3-WROOM-1",
                "manufacturer": "Espressif",
                "description": "ESP32-S3-WROOM-1 Module",
            },
            {
                "part": "485-ESP32-S3-WROOM-1",
                "manufacturer": "SparkFun",
                "description": "ESP32-S3 Thing Plus",
            },
        ]
    },
    # Headers and Connectors
    "2830": {  # Feather Headers
        "mouser_alternatives": [
            {
                "part": "517-974-12",
                "manufacturer": "3M",
                "description": "12-Pin Female Header",
            },
            {
                "part": "517-974-16",
                "manufacturer": "3M",
                "description": "16-Pin Female Header",
            },
            {
                "part": "575-26-60-4120",
                "manufacturer": "Amphenol FCI",
                "description": "2.54mm Female Headers",
            },
        ]
    },
    # ToF Distance Sensor
    "3317": {  # VL53L0X ToF Sensor
        "mouser_alternatives": [
            {
                "part": "511-VL53L0X",
                "manufacturer": "STMicroelectronics",
                "description": "VL53L0X ToF Sensor IC",
            },
            {
                "part": "474-SEN-14722",
                "manufacturer": "SparkFun",
                "description": "VL53L0X Breakout Board",
            },
            {
                "part": "700-VL53L0X-SATEL",
                "manufacturer": "STMicroelectronics",
                "description": "VL53L0X Satellite Board",
            },
        ]
    },
    # OLED Display
    "326": {  # 0.96" OLED 128x64
        "mouser_alternatives": [
            {
                "part": "992-UG-2864HSWEG01",
                "manufacturer": "WiseChip",
                "description": '0.96" OLED 128x64 I2C',
            },
            {
                "part": "426-MOD-LCD-1.3",
                "manufacturer": "Waveshare",
                "description": '1.3" OLED 128x64 I2C',
            },
            {
                "part": "474-LCD-14532",
                "manufacturer": "SparkFun",
                "description": "OLED Display 128x64",
            },
        ]
    },
    # Environmental Sensor
    "2652": {  # BME280
        "mouser_alternatives": [
            {
                "part": "262-BME280",
                "manufacturer": "Bosch",
                "description": "BME280 Sensor IC",
            },
            {
                "part": "474-SEN-15440",
                "manufacturer": "SparkFun",
                "description": "BME280 Breakout Board",
            },
            {
                "part": "700-BME280-MODULE",
                "manufacturer": "Bosch",
                "description": "BME280 Evaluation Board",
            },
        ]
    },
    # Optocoupler
    "2515": {  # 4N35 Optocoupler
        "mouser_alternatives": [
            {
                "part": "782-4N35",
                "manufacturer": "Vishay",
                "description": "4N35 Optocoupler DIP-6",
            },
            {
                "part": "512-4N35",
                "manufacturer": "ON Semiconductor",
                "description": "4N35 Optocoupler",
            },
            {
                "part": "630-4N35",
                "manufacturer": "Lite-On",
                "description": "4N35 Optocoupler",
            },
        ]
    },
    # STEMMA QT/I2C Cables (generic JST SH connectors)
    "4210": {  # 100mm Cable
        "mouser_alternatives": [
            {
                "part": "538-53047-0410",
                "manufacturer": "Molex",
                "description": "JST SH 4-Pin Cable 100mm",
            },
            {
                "part": "455-2660",
                "manufacturer": "JST",
                "description": "SH Series 4-Pin Cable",
            },
            {
                "part": "485-CAB-14427",
                "manufacturer": "SparkFun",
                "description": "Qwiic Cable 100mm",
            },
        ]
    },
    "4401": {  # 200mm Cable
        "mouser_alternatives": [
            {
                "part": "538-53047-0420",
                "manufacturer": "Molex",
                "description": "JST SH 4-Pin Cable 200mm",
            },
            {
                "part": "455-2661",
                "manufacturer": "JST",
                "description": "SH Series 4-Pin Cable 200mm",
            },
            {
                "part": "485-CAB-14428",
                "manufacturer": "SparkFun",
                "description": "Qwiic Cable 200mm",
            },
        ]
    },
    # Arcade Button
    "368": {  # 60mm Red Button
        "mouser_alternatives": [
            {
                "part": "642-1RT2-P2M1",
                "manufacturer": "E-Switch",
                "description": "60mm Round Pushbutton Red",
            },
            {
                "part": "633-A22NN-RPC-RNA",
                "manufacturer": "Omron",
                "description": "A22 Series Pushbutton 60mm",
            },
            {
                "part": "693-0004.1262",
                "manufacturer": "Schurter",
                "description": "60mm Emergency Stop Button",
            },
        ]
    },
    # Terminal Blocks
    "4090": {  # Terminal Block Kit
        "mouser_alternatives": [
            {
                "part": "651-1725656",
                "manufacturer": "Phoenix Contact",
                "description": "2.54mm Terminal Block",
            },
            {
                "part": "571-2-282834-0",
                "manufacturer": "TE Connectivity",
                "description": "Terminal Block 2.54mm",
            },
            {
                "part": "700-TB008-254-02BE",
                "manufacturer": "CUI Devices",
                "description": "Screw Terminal 2.54mm",
            },
        ]
    },
    # Wire (26AWG)
    "1877": {  # Red Wire
        "mouser_alternatives": [
            {
                "part": "602-WH26-02-100",
                "manufacturer": "Alpha Wire",
                "description": "26AWG Stranded Wire Red",
            },
            {
                "part": "602-UL1007-26-RED",
                "manufacturer": "Alpha Wire",
                "description": "UL1007 26AWG Red",
            },
            {
                "part": "602-3051-26-RED",
                "manufacturer": "Alpha Wire",
                "description": "Hook-up Wire 26AWG Red",
            },
        ]
    },
    "1881": {  # Black Wire
        "mouser_alternatives": [
            {
                "part": "602-WH26-02-100",
                "manufacturer": "Alpha Wire",
                "description": "26AWG Stranded Wire Black",
            },
            {
                "part": "602-UL1007-26-BLK",
                "manufacturer": "Alpha Wire",
                "description": "UL1007 26AWG Black",
            },
            {
                "part": "602-3051-26-BLK",
                "manufacturer": "Alpha Wire",
                "description": "Hook-up Wire 26AWG Black",
            },
        ]
    },
}


class MouserConsolidationAnalyzer:
    def __init__(self, mouser_api_key=None):
        self.mouser_api_key = mouser_api_key
        self.session = requests.Session()

        if mouser_api_key:
            self.session.headers.update({"Content-Type": "application/json"})

    def load_current_bom(self, bom_file):
        """Load the current BOM file"""
        components = []
        with open(bom_file, "r", newline="", encoding="utf-8") as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                components.append(row)
        return components

    def get_mouser_pricing(self, part_number, quantity=1):
        """Get pricing from Mouser API if available"""
        if not self.mouser_api_key:
            return None

        try:
            # Use simplified API call with proper error handling
            url = f"https://api.mouser.com/api/v1/search/partnumber?apikey={self.mouser_api_key}"
            data = {
                "SearchByPartRequest": {
                    "mouserPartNumber": part_number,
                    "partSearchOptions": "Exact",
                }
            }

            # Add exponential backoff retry logic
            max_retries = 3
            retry_delay = 1.0

            for attempt in range(max_retries):
                try:
                    response = self.session.post(url, json=data, timeout=30)

                    # Handle rate limiting
                    if response.status_code == 429:
                        if attempt < max_retries - 1:
                            sleep_time = retry_delay * (2**attempt)
                            print(f"Rate limited, retrying in {sleep_time:.1f}s...")
                            time.sleep(sleep_time)
                            continue

                    response.raise_for_status()
                    break
                except requests.exceptions.RequestException:
                    if attempt < max_retries - 1:
                        sleep_time = retry_delay * (2**attempt)
                        print(f"Request failed, retrying in {sleep_time:.1f}s...")
                        time.sleep(sleep_time)
                    else:
                        raise

            result = response.json()
            parts = result.get("SearchResults", {}).get("Parts", [])

            if parts:
                part = parts[0]
                price_breaks = part.get("PriceBreaks", [])

                # Find appropriate price for quantity
                unit_price = None
                for price_break in price_breaks:
                    if price_break.get("Quantity", 0) <= quantity:
                        unit_price = float(
                            price_break.get("Price", "")
                            .replace("$", "")
                            .replace(",", "")
                        )

                return {
                    "part_number": part.get("MouserPartNumber"),
                    "manufacturer": part.get("Manufacturer"),
                    "description": part.get("Description"),
                    "unit_price": unit_price,
                    "availability": part.get("Availability"),
                    "min_order_qty": part.get("Min", 1),
                    "price_breaks": price_breaks,
                }

        except Exception as e:
            print(f"Error fetching Mouser pricing for {part_number}: {e}")

        return None

    def analyze_component_alternatives(self, adafruit_part, quantity=1):
        """Analyze Mouser alternatives for an Adafruit component"""
        adafruit_id = adafruit_part.get("Distributor Part Number", "")

        if adafruit_id not in ADAFRUIT_TO_MOUSER_MAPPING:
            return None

        mapping = ADAFRUIT_TO_MOUSER_MAPPING[adafruit_id]
        alternatives = []

        for alternative in mapping["mouser_alternatives"]:
            mouser_part = alternative["part"]

            # Get pricing if API is available
            pricing_info = self.get_mouser_pricing(mouser_part, quantity)

            if pricing_info:
                alternatives.append(
                    {
                        "mouser_part": mouser_part,
                        "manufacturer": pricing_info["manufacturer"],
                        "description": pricing_info["description"],
                        "unit_price": pricing_info["unit_price"],
                        "availability": pricing_info["availability"],
                        "min_order_qty": pricing_info["min_order_qty"],
                        "estimated_price": pricing_info["unit_price"] * quantity
                        if pricing_info["unit_price"]
                        else None,
                    }
                )
            else:
                # Use estimated pricing if API not available
                alternatives.append(
                    {
                        "mouser_part": mouser_part,
                        "manufacturer": alternative["manufacturer"],
                        "description": alternative["description"],
                        "unit_price": None,
                        "availability": "Unknown",
                        "min_order_qty": 1,
                        "estimated_price": None,
                    }
                )

        return alternatives

    def calculate_cost_comparison(self, current_bom):
        """Calculate cost comparison between current BOM and Mouser alternatives"""
        analysis = {
            "current_total": 0,
            "mouser_total": 0,
            "components": [],
            "adafruit_components": [],
            "non_adafruit_components": [],
            "savings": 0,
            "unavailable_alternatives": [],
        }

        for component in current_bom:
            distributor = component.get("Distributor", "")
            quantity = int(component.get("Quantity", 1))
            current_price = float(component.get("Unit Price", 0))
            extended_price = float(component.get("Extended Price", 0))

            analysis["current_total"] += extended_price

            component_analysis = {
                "original": component,
                "quantity": quantity,
                "current_price": current_price,
                "current_extended": extended_price,
                "alternatives": [],
                "best_alternative": None,
                "potential_savings": 0,
            }

            if distributor.lower() == "adafruit":
                analysis["adafruit_components"].append(component_analysis)

                # Check for Mouser alternatives
                alternatives = self.analyze_component_alternatives(component, quantity)

                if alternatives:
                    component_analysis["alternatives"] = alternatives

                    # Find best alternative (lowest total cost)
                    best_alt = None
                    best_total = float("inf")

                    for alt in alternatives:
                        if (
                            alt["estimated_price"]
                            and alt["estimated_price"] < best_total
                        ):
                            best_alt = alt
                            best_total = alt["estimated_price"]

                    if best_alt:
                        component_analysis["best_alternative"] = best_alt
                        component_analysis["potential_savings"] = (
                            extended_price - best_total
                        )
                        analysis["mouser_total"] += best_total
                    else:
                        analysis["mouser_total"] += (
                            extended_price  # Keep original if no better alternative
                        )
                        analysis["unavailable_alternatives"].append(
                            component["Description"]
                        )
                else:
                    analysis["mouser_total"] += (
                        extended_price  # Keep original if no mapping
                    )
                    analysis["unavailable_alternatives"].append(
                        component["Description"]
                    )
            else:
                # Non-Adafruit component - keep as is
                analysis["non_adafruit_components"].append(component_analysis)
                analysis["mouser_total"] += extended_price

            analysis["components"].append(component_analysis)

        analysis["savings"] = analysis["current_total"] - analysis["mouser_total"]
        analysis["savings_percentage"] = (
            (analysis["savings"] / analysis["current_total"] * 100)
            if analysis["current_total"] > 0
            else 0
        )

        return analysis

    def generate_mouser_consolidated_bom(self, current_bom, analysis):
        """Generate a new BOM using Mouser alternatives where beneficial"""
        new_bom = []

        for i, component in enumerate(current_bom):
            comp_analysis = analysis["components"][i]

            if (
                comp_analysis["best_alternative"]
                and comp_analysis["potential_savings"] > 0
            ):
                # Use Mouser alternative
                alt = comp_analysis["best_alternative"]
                new_component = {
                    "Manufacturer": alt["manufacturer"],
                    "Manufacturer Part Number": alt["mouser_part"].split("-")[-1]
                    if "-" in alt["mouser_part"]
                    else alt["mouser_part"],
                    "Description": alt["description"],
                    "Quantity": component["Quantity"],
                    "Reference Designator": component["Reference Designator"],
                    "Distributor": "Mouser",
                    "Distributor Part Number": alt["mouser_part"],
                    "Unit Price": f"{alt['unit_price']:.2f}"
                    if alt["unit_price"]
                    else component["Unit Price"],
                    "Extended Price": f"{alt['estimated_price']:.2f}"
                    if alt["estimated_price"]
                    else component["Extended Price"],
                }
            else:
                # Keep original component
                new_component = component.copy()

            new_bom.append(new_component)

        return new_bom

    def save_bom_csv(self, bom_data, filename):
        """Save BOM data to CSV file"""
        fieldnames = [
            "Manufacturer",
            "Manufacturer Part Number",
            "Description",
            "Quantity",
            "Reference Designator",
            "Distributor",
            "Distributor Part Number",
            "Unit Price",
            "Extended Price",
        ]

        with open(filename, "w", newline="", encoding="utf-8") as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(bom_data)

    def generate_analysis_report(
        self, analysis, output_file="mouser_consolidation_analysis.md"
    ):
        """Generate detailed analysis report"""
        report = []

        report.append("# Mouser Consolidation Analysis")
        report.append(
            f"*Generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*\n"
        )

        report.append("## 📊 Cost Comparison Summary")
        report.append(f"**Current Total Cost:** ${analysis['current_total']:.2f}")
        report.append(f"**Mouser Consolidated Cost:** ${analysis['mouser_total']:.2f}")
        report.append(
            f"**Potential Savings:** ${analysis['savings']:.2f} ({analysis['savings_percentage']:.1f}%)"
        )
        report.append("")

        # Component distribution
        adafruit_count = len(analysis["adafruit_components"])
        non_adafruit_count = len(analysis["non_adafruit_components"])

        report.append("## 🧩 Component Distribution")
        report.append("| Source | Components | Current Cost | Mouser Cost |")
        report.append("|--------|------------|--------------|-------------|")

        adafruit_current = sum(
            c["current_extended"] for c in analysis["adafruit_components"]
        )
        adafruit_mouser = sum(
            c["best_alternative"]["estimated_price"]
            if c["best_alternative"]
            else c["current_extended"]
            for c in analysis["adafruit_components"]
        )

        non_adafruit_current = sum(
            c["current_extended"] for c in analysis["non_adafruit_components"]
        )

        report.append(
            f"| Adafruit | {adafruit_count} | ${adafruit_current:.2f} | ${adafruit_mouser:.2f} |"
        )
        report.append(
            f"| Other | {non_adafruit_count} | ${non_adafruit_current:.2f} | ${non_adafruit_current:.2f} |"
        )
        report.append("")

        # Detailed component analysis
        if analysis["adafruit_components"]:
            report.append("## 🔍 Adafruit Component Analysis")
            report.append(
                "| Component | Current Price | Best Mouser Alternative | Mouser Price | Savings |"
            )
            report.append(
                "|-----------|---------------|------------------------|--------------|---------|"
            )

            for comp in analysis["adafruit_components"]:
                original = comp["original"]
                current_cost = comp["current_extended"]

                if comp["best_alternative"]:
                    alt = comp["best_alternative"]
                    alt_cost = alt["estimated_price"] or current_cost
                    savings = current_cost - alt_cost
                    savings_str = f"${savings:.2f}" if savings > 0 else "$0.00"

                    report.append(
                        f"| {original['Description'][:40]}... | ${current_cost:.2f} | {alt['mouser_part']} | ${alt_cost:.2f} | {savings_str} |"
                    )
                else:
                    report.append(
                        f"| {original['Description'][:40]}... | ${current_cost:.2f} | No alternative found | - | $0.00 |"
                    )

            report.append("")

        # Unavailable alternatives
        if analysis["unavailable_alternatives"]:
            report.append("## ⚠️ Components Without Mouser Alternatives")
            for component in analysis["unavailable_alternatives"]:
                report.append(f"- {component}")
            report.append("")

        report.append("## 🛒 Recommendation")

        if analysis["savings"] > 0:
            report.append("✅ **RECOMMENDED**: Switch to Mouser consolidation")
            report.append(
                f"- **Total savings**: ${analysis['savings']:.2f} ({analysis['savings_percentage']:.1f}%)"
            )
            report.append("- **Single supplier**: Simplified ordering and shipping")
            report.append("- **Professional components**: Higher quality alternatives")
            report.append("")
            report.append("### Next Steps:")
            report.append("1. Review the generated `BOM_MOUSER_CONSOLIDATED.csv`")
            report.append(
                "2. Verify component compatibility for STEMMA QT alternatives"
            )
            report.append("3. Test the generated purchase files")
            report.append("4. Update project documentation if adopting changes")
        else:
            report.append(
                "❌ **NOT RECOMMENDED**: Current multi-supplier approach is more cost-effective"
            )
            report.append("- Consider Mouser for future revisions as pricing changes")
            report.append("- Keep current BOM for optimal cost")

        report.append("")
        report.append("---")
        report.append(
            "*Analysis based on current Mouser pricing and component availability.*"
        )

        with open(output_file, "w") as f:
            f.write("\n".join(report))

        return output_file


def main():
    parser = argparse.ArgumentParser(
        description="Analyze BOM for Mouser consolidation opportunities"
    )
    parser.add_argument(
        "--bom-file", default="BOM_CONSOLIDATED.csv", help="Input BOM file"
    )
    parser.add_argument("--output-dir", default=".", help="Output directory")
    parser.add_argument("--mouser-api-key", help="Mouser API key for real-time pricing")

    args = parser.parse_args()

    analyzer = MouserConsolidationAnalyzer(args.mouser_api_key)

    print("🔍 Loading current BOM...")
    current_bom = analyzer.load_current_bom(args.bom_file)

    print("📊 Analyzing Mouser alternatives...")
    analysis = analyzer.calculate_cost_comparison(current_bom)

    print("📋 Generating analysis report...")
    report_file = analyzer.generate_analysis_report(
        analysis, f"{args.output_dir}/mouser_consolidation_analysis.md"
    )

    print("💰 Cost Analysis Summary:")
    print(f"   Current Total: ${analysis['current_total']:.2f}")
    print(f"   Mouser Total: ${analysis['mouser_total']:.2f}")
    print(
        f"   Potential Savings: ${analysis['savings']:.2f} ({analysis['savings_percentage']:.1f}%)"
    )

    if analysis["savings"] > 0:
        print("✅ Mouser consolidation recommended - generating consolidated BOM...")

        # Generate new BOM
        mouser_bom = analyzer.generate_mouser_consolidated_bom(current_bom, analysis)
        mouser_bom_file = f"{args.output_dir}/BOM_MOUSER_CONSOLIDATED.csv"
        analyzer.save_bom_csv(mouser_bom, mouser_bom_file)

        print("📁 Generated files:")
        print(f"   - {report_file}")
        print(f"   - {mouser_bom_file}")

        return 0  # Success - consolidation recommended
    else:
        print("❌ Mouser consolidation not cost-effective - keeping current BOM")
        print(f"📁 Generated analysis report: {report_file}")

        return 1  # No consolidation recommended


if __name__ == "__main__":
    exit(main())
