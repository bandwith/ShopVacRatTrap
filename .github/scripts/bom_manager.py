#!/usr/bin/env python3
"""
BOM Manager - Consolidated script for BOM validation, price updates, and reporting
Replaces multiple separate scripts with a single, unified tool.

This script:
1. Validates BOM parts and updates pricing using Mouser API
2. Generates purchase guide with direct links
3. Creates Mouser upload files for bulk ordering
4. Monitors component availability
5. Analyzes Mouser consolidation opportunities
6. Updates BOM files with current pricing
7. Generates reports and analysis
"""

import os
import json
import argparse
import csv
import time
import requests
import random
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional

# Load environment variables from .env file if it exists (for local development)
try:
    from dotenv import load_dotenv

    env_path = Path(__file__).parent.parent.parent / ".env"
    if env_path.exists():
        load_dotenv(env_path)
        print(f"🔧 Loaded environment variables from {env_path}")
except ImportError:
    # python-dotenv not available, continue with system environment variables
    pass

# Constants
MOUSER_API_BASE = "https://api.mouser.com/api/v1"
MOUSER_SEARCH_ENDPOINT = f"{MOUSER_API_BASE}/search/partnumber"

# Rate limiting configuration
REQUESTS_PER_SECOND = 8  # Conservative limit (10 max)

# Safety-critical components that require special monitoring
CRITICAL_COMPONENTS = [
    "D2425-10",  # SSR (safety critical)
    "SCT-013-020",  # Current transformer
    "LRS-15-5",  # Power supply
    "6200.4210",  # IEC inlet with fuse
    "0218012.MXP",  # Fuses
    "ESP32-S3-5323",  # Main controller
]

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
}

# Component mapping: Adafruit/SparkFun to Mouser part numbers for direct consolidation
MOUSER_COMPONENT_MAPPING = {
    # Adafruit components available at Mouser
    "5323": "485-5323",  # ESP32-S3 Feather
    "1578": "485-1578",  # LiPo Battery 2500mAh
    "2830": "485-2830",  # Feather Stacking Headers
    "4210": "485-4210",  # VL53L0X ToF Sensor (Note: was 3317 in smaller BOM)
    "5027": "485-5027",  # 1.3" OLED Display
    "4816": "485-4816",  # BME280 Sensor
    "4397": "485-4397",  # STEMMA QT Cable 100mm
    "4399": "485-4399",  # STEMMA QT Cable 200mm
    "1944": "485-1944",  # DC Barrel Jack
    "368": "485-368",  # Arcade Button
    "4090": "485-4090",  # Terminal Block Kit
    "3258": "485-3258",  # Wire Red
    "3259": "485-3259",  # Wire Black
    # SparkFun components available at Mouser
    "COM-14456": "474-COM-14456",  # SSR Kit 25A
    # Components already at Mouser (keep existing)
    "LRS-35-5": "709-LRS35-5",  # Power Supply
    "PN-1334-C": "563-PN-1334-C",  # Enclosure
    "4300.0030": "693-4300.0030",  # IEC Inlet
    "5320-W": "546-5320-W",  # NEMA Outlet
}


class MouserAPIError(Exception):
    """Base exception for Mouser API errors"""

    pass


class MouserRateLimitError(MouserAPIError):
    """Raised when rate limit is exceeded"""

    pass


def exponential_backoff(
    attempt: int, base_delay: float = 1.0, max_delay: float = 60.0
) -> float:
    """Calculate exponential backoff delay with jitter"""
    delay = min(base_delay * (2**attempt), max_delay)
    # Add jitter to prevent thundering herd
    jitter = random.uniform(0.1, 0.5) * delay
    return delay + jitter


class BOMManager:
    """Unified BOM Management class"""

    def __init__(self, api_key: str = None):
        """Initialize BOM Manager with Mouser API key"""
        self.api_key = api_key or os.getenv("MOUSER_API_KEY")
        if not self.api_key:
            raise ValueError(
                "Mouser API key required. Set MOUSER_API_KEY environment variable."
            )

        self.session = requests.Session()
        self.session.headers.update(
            {
                "Content-Type": "application/json",
                "Accept": "application/json",
            }
        )

        # Rate limiting tracking
        self.request_times = []
        print("✅ BOM Manager initialized with Mouser API")

    def _check_rate_limit(self):
        """Check and enforce rate limits"""
        current_time = time.time()

        # Check per-second limit
        self.request_times = [t for t in self.request_times if current_time - t < 1.0]
        if len(self.request_times) >= REQUESTS_PER_SECOND:
            sleep_time = 1.0 - (current_time - self.request_times[0])
            if sleep_time > 0:
                print(f"🐌 Rate limiting: sleeping {sleep_time:.1f}s")
                time.sleep(sleep_time)

        # Record this request
        self.request_times.append(time.time())

    def search_part(self, part_number: str, manufacturer: str = None) -> Dict:
        """Search for a part by part number"""
        self._check_rate_limit()

        url = f"{MOUSER_SEARCH_ENDPOINT}?apiKey={self.api_key}"

        # Mouser API requires POST with JSON payload
        payload = {
            "SearchByPartRequest": {
                "mouserPartNumber": part_number,
                "partSearchOptions": "Exact",
            }
        }

        try:
            print(f"🔍 Searching for part: {part_number}")
            response = self.session.post(url, json=payload, timeout=30)

            # Handle API errors
            if response.status_code == 429:
                raise MouserRateLimitError("Rate limit exceeded (HTTP 429)")

            response.raise_for_status()
            data = response.json()

            # Check for API-level errors
            if "Errors" in data and data["Errors"]:
                error_msg = "; ".join(
                    [err.get("Message", "") for err in data["Errors"]]
                )
                raise MouserAPIError(f"API error: {error_msg}")

            # Check for results in Mouser API response format
            if "SearchResults" not in data or not data["SearchResults"].get("Parts"):
                print(f"⚠️ No results found for {part_number}")
                return {"found": False}

            parts = data["SearchResults"]["Parts"]

            # Filter by manufacturer if specified
            if manufacturer:
                parts = [
                    p
                    for p in parts
                    if manufacturer.lower() in p.get("Manufacturer", "").lower()
                ]

            if parts:
                part = parts[0]  # Take first match

                # Extract pricing information
                price_breaks = []
                for price_break in part.get("PriceBreaks", []):
                    price_breaks.append(
                        {
                            "quantity": int(price_break.get("Quantity", 0)),
                            "price": float(
                                price_break.get("Price", "0")
                                .replace("$", "")
                                .replace(",", "")
                            ),
                            "currency": price_break.get("Currency", "USD"),
                        }
                    )

                # Get stock information
                availability = part.get("Availability", "").strip()
                stock_qty = 0

                # Try to parse quantity from availability string
                if availability:
                    try:
                        stock_text = (
                            availability.split(":")[1].strip()
                            if ":" in availability
                            else availability
                        )
                        stock_qty = int(
                            "".join(c for c in stock_text if c.isdigit()) or 0
                        )
                    except (IndexError, ValueError):
                        stock_qty = 0

                return {
                    "found": True,
                    "mouser_part": part.get("MouserPartNumber", ""),
                    "manufacturer": part.get("Manufacturer", ""),
                    "mpn": part.get("ManufacturerPartNumber", ""),
                    "description": part.get("Description", ""),
                    "availability": availability,
                    "stock_qty": stock_qty,
                    "price_breaks": price_breaks,
                    "datasheet": part.get("DataSheetUrl", ""),
                    "product_url": part.get("ProductDetailUrl", ""),
                    "image_url": part.get("ImagePath", ""),
                }

            return {"found": False}

        except MouserRateLimitError:
            print(f"🐌 Rate limited for {part_number}, retrying after delay...")
            time.sleep(2)  # Wait before retry
            return self.search_part(part_number, manufacturer)

        except requests.exceptions.RequestException as e:
            print(f"❌ Request error: {e}")
            return {"found": False, "error": str(e)}

    def get_best_price(self, part: Dict, quantity: int = 1) -> Optional[Dict]:
        """Get best price for a given quantity"""
        price_breaks = part.get("price_breaks", [])

        if not price_breaks:
            return None

        # Find applicable price breaks (price break qty <= requested qty)
        applicable_breaks = [pb for pb in price_breaks if pb["quantity"] <= quantity]

        if not applicable_breaks:
            # Use minimum quantity if requested quantity is too low
            min_break = min(price_breaks, key=lambda x: x["quantity"])
            return {
                "quantity": min_break["quantity"],
                "unit_price": min_break["price"],
                "total_price": min_break["price"] * min_break["quantity"],
                "currency": min_break["currency"],
                "note": f"Minimum order quantity: {min_break['quantity']}",
            }

        # Use highest applicable quantity for best price
        best_break = max(applicable_breaks, key=lambda x: x["quantity"])
        return {
            "quantity": quantity,
            "unit_price": best_break["price"],
            "total_price": best_break["price"] * quantity,
            "currency": best_break["currency"],
            "price_break_qty": best_break["quantity"],
        }

    def validate_bom(
        self, bom_file: str, priority_components: List[str] = None
    ) -> Dict:
        """Validate entire BOM file with pricing and availability"""
        print(f"📋 Validating BOM file: {bom_file}")

        try:
            # Read BOM file
            components = []
            with open(bom_file, "r", newline="") as csvfile:
                reader = csv.DictReader(csvfile)
                for row in reader:
                    components.append(row)

            validation_results = {
                "bom_file": bom_file,
                "timestamp": datetime.now().isoformat(),
                "total_components": len(components),
                "found_components": 0,
                "total_cost": 0.0,
                "components": [],
                "pricing_changes": {
                    "changes_detected": False,
                    "significant_changes": False,
                    "total_change_percent": 0.0,
                    "changed_components": 0,
                },
                "availability_issues": {
                    "unavailable_components": 0,
                    "low_stock_components": 0,
                    "critical_availability": False,
                },
            }

            priority_set = set(priority_components or [])

            # Process components with priority items first
            sorted_components = sorted(
                components,
                key=lambda c: c.get("Manufacturer Part Number", "") in priority_set,
                reverse=True,
            )

            current_total_cost = 0.0
            updated_total_cost = 0.0

            for component in sorted_components:
                mpn = component.get("Manufacturer Part Number", "").strip()
                manufacturer = component.get("Manufacturer", "").strip()
                description = component.get("Description", "")

                try:
                    quantity = int(component.get("Quantity", 1))
                except ValueError:
                    quantity = 1

                try:
                    current_price = float(component.get("Unit Price", 0))
                except ValueError:
                    current_price = 0.0

                # Calculate current cost
                current_extended = current_price * quantity
                current_total_cost += current_extended

                # Skip empty or comment rows
                if not mpn or mpn.startswith("#"):
                    continue

                is_priority = mpn in priority_set

                print(
                    f"🔍 Validating {mpn} ({manufacturer}) - {'⭐ Priority' if is_priority else 'Standard'}"
                )

                component_result = {
                    "mpn": mpn,
                    "manufacturer": manufacturer,
                    "description": description,
                    "quantity": quantity,
                    "current_price": current_price,
                    "current_extended": current_extended,
                    "is_priority": is_priority,
                    "found": False,
                    "updated_price": None,
                    "price_change": 0.0,
                    "price_change_percent": 0.0,
                    "availability": "Unknown",
                    "stock_qty": 0,
                    "in_stock": False,
                }

                # Search part in Mouser
                part_result = self.search_part(mpn, manufacturer)

                if part_result.get("found"):
                    component_result["found"] = True
                    validation_results["found_components"] += 1

                    # Update with Mouser data
                    component_result["availability"] = part_result.get(
                        "availability", "Unknown"
                    )
                    component_result["stock_qty"] = part_result.get("stock_qty", 0)
                    component_result["in_stock"] = (
                        component_result["stock_qty"] > quantity
                    )
                    component_result["datasheet"] = part_result.get("datasheet", "")
                    component_result["product_url"] = part_result.get("product_url", "")

                    # Check for availability issues
                    if component_result["stock_qty"] == 0:
                        validation_results["availability_issues"][
                            "unavailable_components"
                        ] += 1
                        if is_priority:
                            validation_results["availability_issues"][
                                "critical_availability"
                            ] = True
                    elif component_result["stock_qty"] < quantity:
                        validation_results["availability_issues"][
                            "low_stock_components"
                        ] += 1

                    # Get pricing information
                    pricing = self.get_best_price(part_result, quantity)

                    if pricing:
                        component_result["updated_price"] = pricing["unit_price"]
                        component_result["updated_extended"] = pricing["total_price"]
                        updated_total_cost += pricing["total_price"]

                        # Calculate price changes
                        if current_price > 0:
                            price_change = pricing["unit_price"] - current_price
                            price_change_percent = (price_change / current_price) * 100

                            component_result["price_change"] = price_change
                            component_result["price_change_percent"] = (
                                price_change_percent
                            )

                            # Track significant price changes
                            if (
                                abs(price_change_percent) >= 5.0
                            ):  # 5% threshold for significance
                                validation_results["pricing_changes"][
                                    "changed_components"
                                ] += 1
                                validation_results["pricing_changes"][
                                    "changes_detected"
                                ] = True

                                if abs(price_change_percent) >= 10.0 or (
                                    is_priority and abs(price_change_percent) >= 5.0
                                ):
                                    validation_results["pricing_changes"][
                                        "significant_changes"
                                    ] = True
                else:
                    component_result["error"] = part_result.get(
                        "error", "Part not found"
                    )

                validation_results["components"].append(component_result)

                # Add some delay between requests
                time.sleep(0.2)

            # Calculate overall cost change
            if current_total_cost > 0:
                total_change_percent = (
                    (updated_total_cost - current_total_cost) / current_total_cost
                ) * 100
                validation_results["pricing_changes"]["total_change_percent"] = (
                    total_change_percent
                )

                # If total cost changed by more than 5%, mark as significant
                if abs(total_change_percent) >= 5.0:
                    validation_results["pricing_changes"]["significant_changes"] = True

            # Generate pricing report
            self._generate_pricing_report(validation_results)

            # Generate availability report
            self._generate_availability_report(validation_results)

            print("✅ BOM validation complete:")
            print(f"   Total components: {validation_results['total_components']}")
            print(f"   Found components: {validation_results['found_components']}")
            print(
                f"   Success rate: {(validation_results['found_components'] / validation_results['total_components']) * 100:.1f}%"
            )
            print(
                f"   Price changes: {validation_results['pricing_changes']['changed_components']}"
            )
            print(
                f"   Availability issues: {validation_results['availability_issues']['unavailable_components']} unavailable, {validation_results['availability_issues']['low_stock_components']} low stock"
            )

            return validation_results

        except Exception as e:
            print(f"❌ Error validating BOM: {e}")
            return {"error": str(e)}

    def _generate_pricing_report(self, validation_results: Dict):
        """Generate pricing report from validation results"""
        report = []

        report.append("# BOM Pricing Validation Report")
        report.append(
            f"*Generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*\n"
        )

        # Overall summary
        report.append("## 📊 Overall Summary")
        report.append(f"**Total Components:** {validation_results['total_components']}")
        report.append(f"**Components Found:** {validation_results['found_components']}")
        report.append(
            f"**Success Rate:** {(validation_results['found_components'] / validation_results['total_components']) * 100:.1f}%"
        )

        # Pricing changes
        changes = validation_results["pricing_changes"]
        report.append("\n## 💰 Pricing Changes")
        report.append(
            f"**Components with Price Changes:** {changes['changed_components']}"
        )
        report.append(
            f"**Total BOM Cost Change:** {changes['total_change_percent']:.1f}%"
        )
        report.append(
            f"**Significant Changes Detected:** {'Yes' if changes['significant_changes'] else 'No'}"
        )

        # List significant price changes
        significant_changes = []
        for component in validation_results["components"]:
            if (
                component.get("found")
                and abs(component.get("price_change_percent", 0)) >= 5.0
            ):
                significant_changes.append(component)

        if significant_changes:
            report.append("\n### Significant Price Changes")
            report.append(
                "| Part Number | Description | Old Price | New Price | Change |"
            )
            report.append(
                "|------------|-------------|-----------|-----------|--------|"
            )

            # Sort by absolute change percentage (highest first)
            for component in sorted(
                significant_changes,
                key=lambda x: abs(x.get("price_change_percent", 0)),
                reverse=True,
            ):
                old_price = f"${component['current_price']:.2f}"
                new_price = f"${component['updated_price']:.2f}"
                change = f"{component['price_change_percent']:.1f}%"

                report.append(
                    f"| {component['mpn']} | {component['description'][:30]}... | {old_price} | {new_price} | {change} |"
                )

        # Save report
        with open("pricing_report.md", "w") as f:
            f.write("\n".join(report))

    def _generate_availability_report(self, validation_results: Dict):
        """Generate availability report from validation results"""
        report = []

        report.append("# Component Availability Report")
        report.append(
            f"*Generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*\n"
        )

        # Overall summary
        issues = validation_results["availability_issues"]
        report.append("## 📦 Availability Summary")
        report.append(f"**Unavailable Components:** {issues['unavailable_components']}")
        report.append(f"**Low Stock Components:** {issues['low_stock_components']}")
        report.append(
            f"**Critical Availability Issues:** {'Yes' if issues['critical_availability'] else 'No'}"
        )

        # List unavailable components
        unavailable = []
        low_stock = []

        for component in validation_results["components"]:
            if component.get("found"):
                if component.get("stock_qty", 0) == 0:
                    unavailable.append(component)
                elif component.get("stock_qty", 0) < component.get("quantity", 1):
                    low_stock.append(component)

        # List priority unavailable components first
        if unavailable:
            report.append("\n### Unavailable Components")
            report.append("| Part Number | Description | Priority | Required Qty |")
            report.append("|------------|-------------|----------|--------------|")

            # Sort by priority first, then by description
            for component in sorted(
                unavailable,
                key=lambda x: (
                    not x.get("is_priority", False),
                    x.get("description", ""),
                ),
            ):
                priority = (
                    "⭐ HIGH" if component.get("is_priority", False) else "Normal"
                )
                report.append(
                    f"| {component['mpn']} | {component['description'][:30]}... | {priority} | {component['quantity']} |"
                )

        if low_stock:
            report.append("\n### Low Stock Components")
            report.append("| Part Number | Description | Available | Required |")
            report.append("|------------|-------------|-----------|----------|")

            for component in sorted(
                low_stock,
                key=lambda x: (not x.get("is_priority", False), x.get("stock_qty", 0)),
            ):
                report.append(
                    f"| {component['mpn']} | {component['description'][:30]}... | {component['stock_qty']} | {component['quantity']} |"
                )

        # Save report
        with open("availability_report.md", "w") as f:
            f.write("\n".join(report))

        # Set output variable for GitHub Actions
        has_unavailable = issues["unavailable_components"] > 0
        with open(os.environ.get("GITHUB_OUTPUT", "github_output.txt"), "a") as f:
            f.write(
                f"unavailable_components={'true' if has_unavailable else 'false'}\n"
            )

    def update_bom_pricing(self, bom_file: str, validation_results: Dict) -> bool:
        """Update BOM with current pricing from validation results"""
        print(f"📝 Updating BOM pricing in {bom_file}...")

        try:
            # Read the original BOM to preserve structure
            with open(bom_file, "r", newline="") as csvfile:
                reader = csv.reader(csvfile)
                header = next(reader)
                rows = list(reader)

            # Map columns for easier access
            header_map = {col: idx for idx, col in enumerate(header)}
            unit_price_col = next(
                (idx for col, idx in header_map.items() if "unit price" in col.lower()),
                None,
            )
            mpn_col = next(
                (
                    idx
                    for col, idx in header_map.items()
                    if "part number" in col.lower()
                ),
                None,
            )
            ext_price_col = next(
                (
                    idx
                    for col, idx in header_map.items()
                    if "extended price" in col.lower()
                ),
                None,
            )

            if not unit_price_col or not mpn_col:
                print("❌ Could not find required columns in BOM file")
                return False

            # Create a lookup for validated components
            validated_components = {}
            for component in validation_results["components"]:
                if (
                    component.get("found")
                    and component.get("updated_price") is not None
                ):
                    validated_components[component["mpn"]] = component

            # Update the prices
            updates = 0
            for row in rows:
                if len(row) > max(unit_price_col, mpn_col, ext_price_col or 0):
                    mpn = row[mpn_col].strip()

                    if mpn in validated_components:
                        component = validated_components[mpn]
                        new_price = component["updated_price"]
                        quantity = component["quantity"]

                        # Update unit price
                        row[unit_price_col] = f"{new_price:.2f}"

                        # Update extended price if column exists
                        if ext_price_col is not None:
                            row[ext_price_col] = f"{new_price * quantity:.2f}"

                        updates += 1

            # Write updated BOM
            with open(bom_file, "w", newline="") as csvfile:
                writer = csv.writer(csvfile)
                writer.writerow(header)
                writer.writerows(rows)

            print(f"✅ Updated {updates} component prices in {bom_file}")
            return True

        except Exception as e:
            print(f"❌ Error updating BOM pricing: {e}")
            return False

    def generate_purchase_guide(
        self, bom_file: str, validation_results: Dict = None, output_dir: str = "."
    ) -> str:
        """Generate purchase guide with direct links"""
        print("📋 Generating purchase guide...")

        # Load BOM data
        components = []
        try:
            with open(bom_file, "r", newline="") as csvfile:
                reader = csv.DictReader(csvfile)
                for row in reader:
                    components.append(row)
        except Exception as e:
            print(f"❌ Error reading BOM file: {e}")
            return None

        # Create purchase guide
        guide = []
        guide.append("# Component Purchase Guide")
        guide.append(f"*Generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*\n")

        # Add validation summary if available
        if validation_results:
            guide.append("## 📊 Validation Summary")
            guide.append(
                f"**Total Components:** {validation_results.get('total_components', len(components))}"
            )
            guide.append(
                f"**Components Found:** {validation_results.get('found_components', 0)}"
            )
            guide.append(
                f"**Success Rate:** {(validation_results.get('found_components', 0) / validation_results.get('total_components', len(components)) * 100):.1f}%"
            )
            guide.append("")

        # Group components by distributor
        distributors = {}
        for component in components:
            distributor = component.get("Distributor", "Other")
            if distributor not in distributors:
                distributors[distributor] = []
            distributors[distributor].append(component)

        # Create section for each distributor
        for distributor, dist_components in distributors.items():
            guide.append(f"## {distributor} Components")
            guide.append("| Qty | Part Number | Description | Price | Link |")
            guide.append("|-----|------------|-------------|-------|------|")

            for component in dist_components:
                mpn = component.get("Manufacturer Part Number", "")
                description = component.get("Description", "")
                quantity = component.get("Quantity", "1")
                unit_price = component.get("Unit Price", "")

                # Generate link based on distributor
                link = ""
                if distributor.lower() == "mouser":
                    part_no = component.get("Distributor Part Number", mpn)
                    link = f"[Buy](https://www.mouser.com/ProductDetail/{part_no})"
                elif distributor.lower() == "digikey":
                    part_no = component.get("Distributor Part Number", mpn)
                    link = f"[Buy](https://www.digikey.com/product-detail/{part_no})"
                elif distributor.lower() == "adafruit":
                    part_no = component.get("Distributor Part Number", "")
                    if part_no:
                        link = f"[Buy](https://www.adafruit.com/product/{part_no})"
                elif distributor.lower() == "sparkfun":
                    part_no = component.get("Distributor Part Number", mpn)
                    if part_no:
                        link = f"[Buy](https://www.sparkfun.com/products/{part_no})"

                price_str = f"${unit_price}" if unit_price else ""
                guide.append(
                    f"| {quantity} | {mpn} | {description[:40]}... | {price_str} | {link} |"
                )

            guide.append("")

        # Add bulk order instructions
        guide.append("## 📦 Bulk Ordering Instructions")
        guide.append("### Mouser")
        guide.append("1. Go to [Mouser BOM Tool](https://www.mouser.com/bom/)")
        guide.append("2. Upload the `mouser_upload_consolidated.csv` file")
        guide.append("3. Review quantities and add all to cart")
        guide.append("\n### Digi-Key")
        guide.append("1. Go to [Digi-Key BOM Manager](https://www.digikey.com/BOM)")
        guide.append("2. Upload the `digikey_upload.csv` file")
        guide.append("3. Review quantities and add all to cart")

        # Save the purchase guide
        os.makedirs(output_dir, exist_ok=True)
        guide_content = "\n".join(guide)
        guide_path = os.path.join(output_dir, "PURCHASE_GUIDE.md")

        with open(guide_path, "w") as f:
            f.write(guide_content)

        # Also create a copy in the main directory for easier access
        with open("PURCHASE_GUIDE.md", "w") as f:
            f.write(guide_content)

        print(f"✅ Created purchase guide: {guide_path}")

        return guide_path

    def generate_mouser_upload_file(self, bom_file: str, output_dir: str) -> str:
        """Generate Mouser BOM upload file"""
        print("🛒 Generating Mouser upload file...")

        # Ensure output directory exists
        os.makedirs(output_dir, exist_ok=True)

        # Load BOM data
        components = []
        try:
            with open(bom_file, "r", newline="") as csvfile:
                reader = csv.DictReader(csvfile)
                for row in reader:
                    components.append(row)
        except Exception as e:
            print(f"❌ Error reading BOM file: {e}")
            return None

        # Filter for Mouser components
        mouser_components = []
        for component in components:
            distributor = component.get("Distributor", "").lower()
            if distributor == "mouser":
                mouser_components.append(component)

        if not mouser_components:
            print("⚠️ No Mouser components found in BOM")
            return None

        # Create Mouser upload file (simple format: PartNumber,Quantity)
        output_file = os.path.join(output_dir, "mouser_upload_consolidated.csv")
        with open(output_file, "w", newline="") as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(
                ["Part Number", "Quantity", "Description", "Customer Reference"]
            )

            for component in mouser_components:
                part_number = component.get("Distributor Part Number", "")
                quantity = component.get("Quantity", "1")
                description = component.get("Description", "")
                ref = component.get("Reference Designator", "")

                writer.writerow([part_number, quantity, description, ref])

        print(f"✅ Created Mouser upload file: {output_file}")
        return output_file

    def generate_mouser_only_bom(self, bom_file: str, output_dir: str) -> str:
        """Generate a consolidated BOM with only Mouser parts"""
        print("🔄 Generating Mouser-only BOM...")

        # Read the consolidated BOM
        components = []
        try:
            with open(bom_file, "r", newline="", encoding="utf-8") as csvfile:
                reader = csv.DictReader(csvfile)
                for row in reader:
                    components.append(row)
        except Exception as e:
            print(f"❌ Error reading BOM file: {e}")
            return None

        # Convert all components to Mouser
        mouser_components = []
        for component in components:
            mpn = component.get("Manufacturer Part Number", "")
            new_component = component.copy()

            # Check if we have a Mouser mapping for this part
            if mpn in MOUSER_COMPONENT_MAPPING:
                new_component["Distributor"] = "Mouser"
                new_component["Distributor Part Number"] = MOUSER_COMPONENT_MAPPING[mpn]
                print(f"✅ Mapped {mpn} -> {MOUSER_COMPONENT_MAPPING[mpn]}")
            elif component.get("Distributor", "").lower() == "mouser":
                # Already at Mouser, keep as-is
                print(f"✅ Keeping Mouser part: {mpn}")
            else:
                # Unknown mapping - flag for manual review
                print(
                    f"⚠️ Manual review needed for: {mpn} from {component.get('Distributor', 'Unknown')}"
                )
                new_component["Distributor"] = "Mouser"
                new_component["Distributor Part Number"] = f"REVIEW-{mpn}"

            mouser_components.append(new_component)

        # Ensure output directory exists
        os.makedirs(output_dir, exist_ok=True)

        # Write the Mouser-only BOM
        output_file = os.path.join(output_dir, "BOM_MOUSER_ONLY.csv")
        with open(output_file, "w", newline="", encoding="utf-8") as csvfile:
            if mouser_components:
                fieldnames = mouser_components[0].keys()
                writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
                writer.writeheader()
                writer.writerows(mouser_components)

        # Generate Mouser upload file for consolidated BOM
        upload_file = os.path.join(output_dir, "mouser_upload_consolidated_only.csv")
        with open(upload_file, "w", newline="", encoding="utf-8") as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(
                [
                    "Mouser Part Number",
                    "Quantity",
                    "Customer Part Number",
                    "Description",
                ]
            )

            for component in mouser_components:
                if not component["Distributor Part Number"].startswith("REVIEW-"):
                    writer.writerow(
                        [
                            component["Distributor Part Number"],
                            component["Quantity"],
                            component.get("Reference Designator", ""),
                            component["Description"],
                        ]
                    )

        print(f"✅ Created Mouser-only BOM: {output_file}")
        print(f"✅ Created Mouser upload file: {upload_file}")

        return output_file

    def calculate_mouser_consolidation_cost(
        self, bom_file: str, output_dir: str
    ) -> Dict:
        """Calculate cost comparison between current BOM and Mouser alternatives"""
        print("📊 Analyzing Mouser consolidation opportunities...")

        components = []
        try:
            with open(bom_file, "r", newline="", encoding="utf-8") as csvfile:
                reader = csv.DictReader(csvfile)
                for row in reader:
                    components.append(row)
        except Exception as e:
            print(f"❌ Error reading BOM file: {e}")
            return None

        analysis = {
            "current_total": 0,
            "mouser_total": 0,
            "components": [],
            "adafruit_components": [],
            "non_adafruit_components": [],
            "savings": 0,
            "unavailable_alternatives": [],
        }

        for component in components:
            distributor = component.get("Distributor", "")
            quantity = int(component.get("Quantity", 1))

            try:
                current_price = float(component.get("Unit Price", 0))
            except ValueError:
                current_price = 0.0

            extended_price = current_price * quantity

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
                adafruit_id = component.get("Distributor Part Number", "")

                if adafruit_id in ADAFRUIT_TO_MOUSER_MAPPING:
                    mapping = ADAFRUIT_TO_MOUSER_MAPPING[adafruit_id]
                    alternatives = []

                    for alternative in mapping["mouser_alternatives"]:
                        mouser_part = alternative["part"]

                        # Get pricing if API is available
                        pricing_info = self.search_part(mouser_part)

                        if pricing_info.get("found", False):
                            price_data = self.get_best_price(pricing_info, quantity)

                            if price_data:
                                alternatives.append(
                                    {
                                        "mouser_part": mouser_part,
                                        "manufacturer": pricing_info["manufacturer"],
                                        "description": pricing_info["description"],
                                        "unit_price": price_data["unit_price"],
                                        "availability": pricing_info["availability"],
                                        "min_order_qty": price_data.get("quantity", 1),
                                        "estimated_price": price_data["total_price"],
                                    }
                                )
                        else:
                            # Use estimated pricing if API failed
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

        # Generate analysis report
        self._generate_consolidation_analysis(
            analysis, os.path.join(output_dir, "mouser_consolidation_analysis.md")
        )

        return analysis

    def _generate_consolidation_analysis(
        self, analysis: Dict, output_file: str = "mouser_consolidation_analysis.md"
    ):
        """Generate detailed consolidation analysis report"""
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
            report.append("1. Review the generated `BOM_MOUSER_ONLY.csv`")
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
        description="BOM Manager - consolidated tool for BOM management"
    )
    parser.add_argument("--bom-file", required=True, help="BOM file to process")
    parser.add_argument("--output-dir", default=".", help="Output directory")
    parser.add_argument(
        "--api-key", help="Mouser API key (or set MOUSER_API_KEY env var)"
    )
    parser.add_argument(
        "--priority-components", nargs="*", help="Priority component MPNs"
    )

    # Action flags
    parser.add_argument("--validate", action="store_true", help="Validate BOM pricing")
    parser.add_argument(
        "--check-availability", action="store_true", help="Check component availability"
    )
    parser.add_argument(
        "--update-pricing", action="store_true", help="Update BOM with current pricing"
    )
    parser.add_argument(
        "--generate-purchase-files",
        action="store_true",
        help="Generate purchase guide and files",
    )
    parser.add_argument(
        "--analyze-consolidation",
        action="store_true",
        help="Analyze Mouser consolidation opportunities",
    )
    parser.add_argument(
        "--generate-mouser-only", action="store_true", help="Generate Mouser-only BOM"
    )

    # If no action specified, do all
    parser.add_argument("--all", action="store_true", help="Perform all operations")

    args = parser.parse_args()

    # If no specific action is set, do all
    do_all = args.all or not any(
        [
            args.validate,
            args.check_availability,
            args.update_pricing,
            args.generate_purchase_files,
            args.analyze_consolidation,
            args.generate_mouser_only,
        ]
    )

    try:
        # Ensure output directory exists
        os.makedirs(args.output_dir, exist_ok=True)

        # Initialize BOM Manager
        manager = BOMManager(args.api_key)

        # Track results for later operations
        validation_results = None

        # Validate BOM
        if do_all or args.validate or args.check_availability:
            validation_results = manager.validate_bom(
                args.bom_file, args.priority_components
            )

            if "error" not in validation_results:
                output_file = os.path.join(args.output_dir, "validation_results.json")
                with open(output_file, "w") as f:
                    json.dump(validation_results, f, indent=2)
                print(f"💾 Validation results saved to {output_file}")

                # Set GitHub Actions outputs if running in GH Actions
                if "GITHUB_OUTPUT" in os.environ:
                    with open(os.environ["GITHUB_OUTPUT"], "a") as f:
                        f.write(
                            f"changes_detected={validation_results['pricing_changes']['changes_detected']}\n"
                        )
                        f.write(
                            f"significant_changes={validation_results['pricing_changes']['significant_changes']}\n"
                        )

                        # Availability checks
                        if args.check_availability or do_all:
                            has_unavailable = (
                                validation_results["availability_issues"][
                                    "unavailable_components"
                                ]
                                > 0
                            )
                            f.write(
                                f"unavailable_components={'true' if has_unavailable else 'false'}\n"
                            )
            else:
                print(f"❌ Validation failed: {validation_results['error']}")
                return 1

        # Update BOM pricing if changes detected
        if (
            (do_all or args.update_pricing)
            and validation_results
            and validation_results["pricing_changes"]["changes_detected"]
        ):
            manager.update_bom_pricing(args.bom_file, validation_results)

        # Generate purchase files
        if do_all or args.generate_purchase_files:
            # Purchase guide generation removed - see COMPONENT_SOURCING.md instead
            # manager.generate_purchase_guide(
            #     args.bom_file, validation_results, args.output_dir
            # )
            manager.generate_mouser_upload_file(args.bom_file, args.output_dir)

        # Analyze Mouser consolidation opportunities
        if do_all or args.analyze_consolidation:
            manager.calculate_mouser_consolidation_cost(args.bom_file, args.output_dir)

        # Generate Mouser-only BOM
        if do_all or args.generate_mouser_only:
            manager.generate_mouser_only_bom(args.bom_file, args.output_dir)

        print("✅ BOM management operations complete")
        return 0

    except Exception as e:
        print(f"❌ Fatal error: {e}")
        return 1


if __name__ == "__main__":
    exit(main())
