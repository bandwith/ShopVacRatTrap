#!/usr/bin/env python3
"""
Generate purchase links and Mouser-compatible BOM upload files
Creates comprehensive purchasing documentation with direct links and cart imports
"""

import json
import sys
import csv
import urllib.parse
from pathlib import Path


def generate_mouser_cart_url(components):
    """Generate Mouser cart URL for components"""
    cart_items = []

    for comp in components:
        if comp.get("found") and comp.get("sources"):
            for source in comp.get("sources", []):
                if source.get("supplier") == "Mouser":
                    mouser_part = source.get("mouser_part")
                    qty = comp.get("pricing", {}).get("quantity", 1)
                    if mouser_part:
                        # Mouser cart format: partnumber:quantity
                        cart_items.append(f"{mouser_part}:{qty}")

    if cart_items:
        # Mouser cart URL format
        cart_data = "|".join(cart_items)
        encoded_cart = urllib.parse.quote(cart_data)
        return f"https://www.mouser.com/AddToCartFromCartString/{encoded_cart}"

    return None


def generate_adafruit_cart_url(components):
    """Generate Adafruit cart URL for components"""
    cart_items = []

    for comp in components:
        if comp.get("found"):
            mpn = comp.get("mpn", "")
            qty = comp.get("pricing", {}).get("quantity", 1)

            # Check if this is an Adafruit component
            if (
                mpn.isdigit() and len(mpn) <= 5
            ):  # Adafruit part numbers are typically numeric
                cart_items.append(f"add[]={mpn}&qty[]={qty}")

    if cart_items:
        cart_data = "&".join(cart_items)
        return f"https://www.adafruit.com/shopping_cart?{cart_data}"

    return None


def generate_sparkfun_cart_url(components):
    """Generate SparkFun cart URL for components"""
    cart_items = []

    for comp in components:
        if comp.get("found"):
            mpn = comp.get("mpn", "")
            qty = comp.get("pricing", {}).get("quantity", 1)

            # Check if this is a SparkFun component (COM-XXXXX format)
            if mpn.startswith("COM-"):
                sku = mpn.replace("COM-", "")
                cart_items.append(f"products[{sku}]={qty}")

    if cart_items:
        cart_data = "&".join(cart_items)
        return f"https://www.sparkfun.com/cart?{cart_data}"

    return None


def generate_mouser_upload_csv(components, filename):
    """Generate Mouser-compatible CSV for bulk upload"""
    csv_data = []

    for comp in components:
        if comp.get("found") and comp.get("sources"):
            for source in comp.get("sources", []):
                if source.get("supplier") == "Mouser":
                    mouser_part = source.get("mouser_part")
                    description = source.get("description", "")
                    qty = comp.get("pricing", {}).get("quantity", 1)

                    if mouser_part:
                        csv_data.append(
                            {
                                "Mouser Part Number": mouser_part,
                                "Quantity": qty,
                                "Description": description,
                                "Manufacturer Part Number": comp.get("mpn", ""),
                                "Manufacturer": comp.get("manufacturer", ""),
                                "Customer Part Number": comp.get("reference", ""),
                            }
                        )

    if csv_data:
        with open(filename, "w", newline="", encoding="utf-8") as csvfile:
            fieldnames = [
                "Mouser Part Number",
                "Quantity",
                "Description",
                "Manufacturer Part Number",
                "Manufacturer",
                "Customer Part Number",
            ]
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(csv_data)
        return len(csv_data)

    return 0


def generate_digikey_upload_csv(components, filename):
    """Generate Digi-Key compatible CSV for bulk upload"""
    csv_data = []

    for comp in components:
        if comp.get("found") and comp.get("sources"):
            for source in comp.get("sources", []):
                if "Digi-Key" in source.get("supplier", ""):
                    digikey_part = source.get("digikey_part") or source.get(
                        "part_number"
                    )
                    description = source.get("description", "")
                    qty = comp.get("pricing", {}).get("quantity", 1)

                    if digikey_part:
                        csv_data.append(
                            {
                                "Digi-Key Part Number": digikey_part,
                                "Quantity": qty,
                                "Customer Reference": comp.get("reference", ""),
                                "Description": description,
                            }
                        )

    if csv_data:
        with open(filename, "w", newline="", encoding="utf-8") as csvfile:
            fieldnames = [
                "Digi-Key Part Number",
                "Quantity",
                "Customer Reference",
                "Description",
            ]
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(csv_data)
        return len(csv_data)

    return 0


def generate_purchase_links_report(results):
    """Generate comprehensive purchase links report"""
    bom_file = results.get("bom_file", "Unknown")
    components = results.get("components", [])
    found_components = [c for c in components if c.get("found")]

    if not found_components:
        return f"\n### 🛒 Purchase Links for {bom_file}\n\n❌ No components found for purchase\n\n"

    report = f"\n### 🛒 Purchase Links for {bom_file}\n\n"

    # Generate cart URLs
    mouser_url = generate_mouser_cart_url(found_components)
    adafruit_url = generate_adafruit_cart_url(found_components)
    sparkfun_url = generate_sparkfun_cart_url(found_components)

    # Quick purchase section
    report += "#### 🚀 One-Click Purchase Links\n\n"

    if mouser_url:
        report += f"- **[📦 Add All Mouser Parts to Cart]({mouser_url})**\n"
        report += "  - Professional electronic components\n"
        report += "  - Fast shipping and reliable stock\n"
        report += "  - Bulk pricing available\n\n"

    if adafruit_url:
        report += f"- **[🔧 Add All Adafruit Parts to Cart]({adafruit_url})**\n"
        report += "  - Maker-friendly modules and sensors\n"
        report += "  - Educational documentation included\n"
        report += "  - STEMMA QT ecosystem components\n\n"

    if sparkfun_url:
        report += f"- **[⚡ Add All SparkFun Parts to Cart]({sparkfun_url})**\n"
        report += "  - Open-source hardware designs\n"
        report += "  - Qwiic-compatible modules\n"
        report += "  - Comprehensive tutorials\n\n"

    # BOM upload files section
    report += "#### 📋 BOM Upload Files (Generated)\n\n"

    # Generate upload files
    bom_basename = Path(bom_file).stem

    mouser_csv = f"mouser_upload_{bom_basename}.csv"
    mouser_count = generate_mouser_upload_csv(found_components, mouser_csv)

    digikey_csv = f"digikey_upload_{bom_basename}.csv"
    digikey_count = generate_digikey_upload_csv(found_components, digikey_csv)

    if mouser_count > 0:
        report += (
            f"- **Mouser Bulk Upload**: `{mouser_csv}` ({mouser_count} components)\n"
        )
        report += "  - Upload at: https://www.mouser.com/tools/bom-tool\n"
        report += "  - Supports quantity pricing and availability check\n"
        report += "  - Professional procurement workflow\n\n"

    if digikey_count > 0:
        report += f"- **Digi-Key Bulk Upload**: `{digikey_csv}` ({digikey_count} components)\n"
        report += (
            "  - Upload at: https://www.digikey.com/en/products/calculator/bom-tool\n"
        )
        report += "  - Immediate availability and pricing\n"
        report += "  - Technical support included\n\n"

    # Component-by-component purchase links
    report += "#### 🔗 Individual Component Links\n\n"

    # Group by supplier for better organization
    suppliers = {}
    for comp in found_components:
        for source in comp.get("sources", []):
            supplier = source.get("supplier", "Unknown")
            if supplier not in suppliers:
                suppliers[supplier] = []
            suppliers[supplier].append((comp, source))

    for supplier in sorted(suppliers.keys()):
        if supplier == "Unknown":
            continue

        report += f"##### {supplier}\n\n"
        report += "| Component | Part Number | Qty | Price | Link |\n"
        report += "|-----------|-------------|-----|-------|------|\n"

        for comp, source in suppliers[supplier]:
            mpn = comp.get("mpn", "")
            manufacturer = comp.get("manufacturer", "")
            qty = comp.get("pricing", {}).get("quantity", 1)
            unit_price = comp.get("pricing", {}).get("unit_price", 0)
            total_price = comp.get("pricing", {}).get("total_price", 0)

            supplier_part = ""
            product_url = source.get("product_url", "")

            if supplier == "Mouser":
                supplier_part = source.get("mouser_part", "")
                if not product_url and supplier_part:
                    product_url = (
                        f"https://www.mouser.com/ProductDetail/{supplier_part}"
                    )
            elif supplier == "Adafruit" and mpn.isdigit():
                product_url = f"https://www.adafruit.com/product/{mpn}"
                supplier_part = mpn
            elif supplier == "SparkFun" and mpn.startswith("COM-"):
                sku = mpn.replace("COM-", "")
                product_url = f"https://www.sparkfun.com/products/{sku}"
                supplier_part = mpn

            # Format component name
            comp_name = f"{mpn}" if mpn else "Unknown"
            if manufacturer and manufacturer != "Unknown":
                comp_name += f" ({manufacturer})"

            # Format pricing
            price_str = f"${unit_price:.2f}" if unit_price > 0 else "TBD"
            if qty > 1:
                price_str += f" ea<br/>${total_price:.2f} total"

            # Create link
            link_str = (
                f"[View Product]({product_url})" if product_url else "Contact Supplier"
            )

            report += f"| {comp_name} | {supplier_part} | {qty} | {price_str} | {link_str} |\n"

        report += "\n"

    # Purchase instructions
    report += "#### 📋 Purchase Instructions\n\n"
    report += "**Recommended Purchase Order:**\n"
    report += (
        "1. **Safety-Critical Components First** (Power supplies, relays, fuses)\n"
    )
    report += "2. **Electronics Components** (ESP32, sensors, displays)\n"
    report += "3. **Mechanical Components** (Enclosures, hardware, wire)\n\n"

    report += "**Bulk Ordering Tips:**\n"
    report += "- Use BOM upload files for 10+ units to get volume pricing\n"
    report += "- Contact suppliers directly for 100+ unit quotes\n"
    report += "- Consider lead times when ordering safety-critical parts\n"
    report += "- Order 10% extra connectors and small components\n\n"

    report += "**Alternative Supplier Options:**\n"
    report += "- **Amazon/McMaster**: Mechanical hardware and enclosures\n"
    report += "- **Allied Electronics**: Professional electrical components\n"
    report += "- **Newark**: Global component distribution\n"
    report += "- **Local Electrical Supply**: AC components and wire\n\n"

    return report


def generate_cost_analysis(results_list):
    """Generate cost analysis across all BOMs"""
    total_project_cost = 0
    total_components = 0
    found_components = 0

    cost_by_category = {
        "Power & Safety": 0,
        "Electronics": 0,
        "Sensors": 0,
        "Mechanical": 0,
        "Misc": 0,
    }

    for results in results_list:
        components = results.get("components", [])
        total_components += len(components)

        for comp in components:
            if comp.get("found"):
                found_components += 1
                total_price = comp.get("pricing", {}).get("total_price", 0)
                total_project_cost += total_price

                # Categorize component
                mpn = comp.get("mpn", "").upper()
                manufacturer = comp.get("manufacturer", "").upper()

                if any(
                    keyword in mpn
                    for keyword in ["LRS", "PSU", "BREAKER", "FUSE", "SSR"]
                ):
                    cost_by_category["Power & Safety"] += total_price
                elif any(
                    keyword in manufacturer
                    for keyword in ["ADAFRUIT", "SPARKFUN", "ESP32"]
                ):
                    cost_by_category["Electronics"] += total_price
                elif any(keyword in mpn for keyword in ["VL53", "BME280", "OLED"]):
                    cost_by_category["Sensors"] += total_price
                elif any(keyword in mpn for keyword in ["PN-", "ENCLOSURE", "BOX"]):
                    cost_by_category["Mechanical"] += total_price
                else:
                    cost_by_category["Misc"] += total_price

    report = "\n### 💰 Project Cost Analysis\n\n"

    report += "| Category | Cost | Percentage |\n"
    report += "|----------|------|------------|\n"

    for category, cost in cost_by_category.items():
        if cost > 0:
            percentage = (
                (cost / total_project_cost * 100) if total_project_cost > 0 else 0
            )
            report += f"| {category} | ${cost:.2f} | {percentage:.1f}% |\n"

    report += f"| **TOTAL** | **${total_project_cost:.2f}** | **100.0%** |\n\n"

    # Component coverage
    coverage = (
        (found_components / total_components * 100) if total_components > 0 else 0
    )
    report += f"**Component Coverage:** {found_components}/{total_components} ({coverage:.1f}%)\n\n"

    # Cost estimates for different quantities
    report += "#### Quantity Pricing Estimates\n\n"
    report += "| Quantity | Unit Cost | Total Cost | Notes |\n"
    report += "|----------|-----------|------------|-------|\n"
    report += f"| 1 unit | ${total_project_cost:.2f} | ${total_project_cost:.2f} | List pricing |\n"

    # Estimate bulk discounts
    qty_10_discount = 0.85  # 15% discount
    qty_100_discount = 0.75  # 25% discount

    report += f"| 10 units | ${total_project_cost * qty_10_discount:.2f} | ${total_project_cost * qty_10_discount * 10:.2f} | ~15% bulk discount |\n"
    report += f"| 100 units | ${total_project_cost * qty_100_discount:.2f} | ${total_project_cost * qty_100_discount * 100:.2f} | ~25% bulk discount |\n\n"

    report += "**Notes:**\n"
    report += "- Bulk pricing estimates based on typical distributor discounts\n"
    report += "- Safety-critical components may have limited bulk discounts\n"
    report += "- Contact suppliers directly for 100+ unit quotes\n"
    report += "- Shipping costs not included in estimates\n\n"

    return report


def main():
    """Main function"""
    if len(sys.argv) < 2:
        print(
            "Usage: python generate_purchase_links.py <validation_results.json> [additional_results.json...]"
        )
        sys.exit(1)

    results_files = sys.argv[1:]
    all_results = []

    # Load all results files
    for results_file in results_files:
        try:
            with open(results_file, "r") as f:
                results = json.load(f)
                all_results.append(results)
        except FileNotFoundError:
            print(f"Warning: File {results_file} not found")
            continue
        except json.JSONDecodeError:
            print(f"Warning: Invalid JSON in {results_file}")
            continue

    if not all_results:
        print("Error: No valid results files found")
        sys.exit(1)

    # Generate purchase links report
    purchase_report = ""

    # Header
    purchase_report += "# 🛒 Complete Purchase Guide\n"
    purchase_report += f"*Generated on {__import__('datetime').datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}*\n\n"

    purchase_report += "This guide provides direct purchase links, bulk upload files, and cost analysis for the ShopVac Rat Trap 2025 project.\n\n"

    # Cost analysis (if multiple BOMs)
    if len(all_results) > 1:
        purchase_report += generate_cost_analysis(all_results)

    # Purchase links for each BOM
    for results in all_results:
        purchase_report += generate_purchase_links_report(results)

    # Footer with additional resources
    purchase_report += "---\n\n"
    purchase_report += "### 📚 Additional Resources\n\n"
    purchase_report += (
        "- **Project Documentation**: [ELECTRICAL_DESIGN.md](../ELECTRICAL_DESIGN.md)\n"
    )
    purchase_report += (
        "- **Installation Guide**: [INSTALLATION_GUIDE.md](../INSTALLATION_GUIDE.md)\n"
    )
    purchase_report += (
        "- **Component Sourcing**: [COMPONENT_SOURCING.md](../COMPONENT_SOURCING.md)\n"
    )
    purchase_report += (
        "- **Safety Guidelines**: [SAFETY_REFERENCE.md](../SAFETY_REFERENCE.md)\n\n"
    )

    purchase_report += "*💡 Tip: Bookmark this page and check back weekly for updated pricing and availability.*\n"

    print(purchase_report)


if __name__ == "__main__":
    main()
