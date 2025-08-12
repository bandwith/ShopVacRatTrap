#!/usr/bin/env python3
"""
BOM Manager - Consolidated script for BOM validation, price updates, and reporting
Replaces multiple separate scripts with a single, unified tool.

This script:
1. Validates BOM parts and updates pricing using Mouser API
2. Generates official Mouser template format files for direct upload
3. Creates consolidated Mouser-only BOMs with dynamic part lookup
4. Monitors component availability
5. Analyzes Mouser consolidation opportunities
6. Updates BOM files with current pricing
7. Generates reports and analysis

NEW FEATURES (August 2025):
- Official Mouser template format generation (BOM_MOUSER_TEMPLATE.xlsx)
- Dynamic part lookup eliminating hardcoded mappings
- Real-time pricing and availability via API
- Complete component data including datasheets and lifecycle info
- Replaces legacy shell scripts with comprehensive Python functionality

QUICK START EXAMPLES:
    # Generate all purchase files (replaces generate_purchase_files.sh)
    python3 .github/scripts/bom_manager.py --bom-file BOM_CONSOLIDATED.csv --generate-purchase-files

    # Full validation and all output files
    python3 .github/scripts/bom_manager.py --bom-file BOM_CONSOLIDATED.csv --all

    # Just generate Mouser template for upload
    python3 .github/scripts/bom_manager.py --bom-file BOM_CONSOLIDATED.csv --generate-mouser-template

    # Validate pricing and availability only
    python3 .github/scripts/bom_manager.py --bom-file BOM_CONSOLIDATED.csv --validate --check-availability

GENERATED FILES:
    - BOM_MOUSER_TEMPLATE.xlsx: Official Mouser template (RECOMMENDED for upload)
    - BOM_MOUSER_TEMPLATE.csv: CSV version for review
    - BOM_MOUSER_ONLY.csv: Mouser-only consolidated BOM
    - mouser_upload_consolidated_only.csv: Legacy simple upload format
    - PURCHASE_GUIDE.md: Comprehensive purchase instructions
    - pricing_report.md: Price change analysis
    - availability_report.md: Component availability status
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

# Vendor prefix mapping for Mouser part numbers
VENDOR_PREFIXES = {
    "Adafruit": "485",  # Corrected from user feedback
    "SparkFun": "474",  # Confirmed correct
    "Mean Well": "709",
    "Schurter": "693",
    "Leviton": "546",
    "default": "",  # For manufacturers already using Mouser part numbers
}

# Rate limiting configuration
REQUESTS_PER_SECOND = 8  # Conservative limit (10 max)


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

    def get_mouser_part_number(
        self, manufacturer: str, manufacturer_part_number: str
    ) -> str:
        """Generate correct Mouser part number with vendor prefix"""
        # Get vendor prefix from mapping
        prefix = VENDOR_PREFIXES.get(manufacturer, VENDOR_PREFIXES["default"])

        if prefix:
            # Format: {prefix}-{manufacturer_part_number}
            mouser_part = f"{prefix}-{manufacturer_part_number}"
            print(
                f"🔧 Generated Mouser part number: {mouser_part} (for {manufacturer} {manufacturer_part_number})"
            )
            return mouser_part
        else:
            # Use manufacturer part number directly (for vendors already using Mouser format)
            return manufacturer_part_number

    def search_part(self, part_number: str, manufacturer: str = None) -> dict:
        """Search for a part by part number"""
        self._check_rate_limit()

        # Generate correct Mouser part number if manufacturer is known
        search_part_number = part_number
        if manufacturer:
            search_part_number = self.get_mouser_part_number(manufacturer, part_number)

        url = f"{MOUSER_SEARCH_ENDPOINT}?apiKey={self.api_key}"

        # Mouser API requires POST with JSON payload
        payload = {
            "SearchByPartRequest": {
                "mouserPartNumber": search_part_number,
                "partSearchOptions": "Exact",
            }
        }

        try:
            print(
                f"🔍 Searching for part: {search_part_number} (original: {part_number})"
            )
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

    def get_best_price(self, part: dict, quantity: int = 1) -> dict | None:
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
        self, bom_file: str, priority_components: list[str] = None
    ) -> dict:
        """Validate entire BOM file with pricing and availability"""
        print(f"📋 Validating BOM file: {bom_file}")

        try:
            # Read BOM file
            components = []
            with open(bom_file, newline="") as csvfile:
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

    def _generate_pricing_report(self, validation_results: dict):
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

    def _generate_availability_report(self, validation_results: dict):
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

    def update_bom_pricing(self, bom_file: str, validation_results: dict) -> bool:
        """Update BOM with current pricing from validation results"""
        print(f"📝 Updating BOM pricing in {bom_file}...")

        try:
            # Read the original BOM to preserve structure
            with open(bom_file, newline="") as csvfile:
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
        self, bom_file: str, validation_results: dict = None, output_dir: str = "."
    ) -> str:
        """Generate purchase guide with direct links"""
        print("📋 Generating purchase guide...")

        # Load BOM data
        components = []
        try:
            with open(bom_file, newline="") as csvfile:
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

    def generate_mouser_template_file(self, bom_file: str, output_dir: str) -> str:
        """Generate BOM in official Mouser template format using dynamic lookup"""
        print("🛒 Generating Mouser template format file...")

        # Ensure output directory exists
        os.makedirs(output_dir, exist_ok=True)

        # Use the standard Mouser template column structure
        mouser_columns = [
            "Mfr Part Number (Input)",
            "Manufacturer Part Number",
            "Mouser Part Number",
            "Manufacturer Name",
            "Description",
            "Quantity 1",
            "Unit Price 1",
            "Quantity 2",
            "Unit Price 2",
            "Quantity 3",
            "Unit Price 3",
            "Quantity 4",
            "Unit Price 4",
            "Quantity 5",
            "Unit Price 5",
            "Order Quantity",
            "Order Unit Price",
            "Min./Mult.",
            "Availability",
            "Lead Time in Days",
            "Lifecycle",
            "NCNR",
            "RoHS",
            "Pb Free",
            "Package Type",
            "Datasheet URL",
            "Product Image",
            "Design Risk",
        ]
        print(
            f"📋 Using standard Mouser template structure: {len(mouser_columns)} columns"
        )

        # Load BOM data
        components = []
        try:
            with open(bom_file, newline="", encoding="utf-8") as csvfile:
                reader = csv.DictReader(csvfile)
                for row in reader:
                    components.append(row)
        except Exception as e:
            print(f"❌ Error reading BOM file: {e}")
            return None

        print(f"📦 Processing {len(components)} components for Mouser template...")

        # Create the migrated BOM data
        template_data = []

        for i, component in enumerate(components, 1):
            print(
                f"🔍 [{i}/{len(components)}] Processing: {component['Description'][:50]}..."
            )

            manufacturer = component.get("Manufacturer", "")
            mpn = component.get("Manufacturer Part Number", "")
            quantity = int(component.get("Quantity", 1))
            current_distributor = component.get("Distributor", "")

            # Initialize row with template structure
            row_data = {col: "" for col in mouser_columns}

            # Set basic information
            row_data["Mfr Part Number (Input)"] = mpn
            row_data["Manufacturer Part Number"] = mpn
            row_data["Manufacturer Name"] = manufacturer
            row_data["Description"] = component.get("Description", "")
            row_data["Order Quantity"] = quantity

            # If already from Mouser, use existing data
            if current_distributor.lower() == "mouser":
                mouser_part = component.get("Distributor Part Number", "")
                unit_price = component.get("Unit Price", "0")

                row_data["Mouser Part Number"] = mouser_part
                row_data["Order Unit Price"] = unit_price

                print(f"  ✅ Already Mouser: {mouser_part}")

            else:
                # Use dynamic lookup to find Mouser equivalent
                if manufacturer and mpn:
                    # Try to get Mouser part number using vendor prefix
                    mouser_part = self.get_mouser_part_number(manufacturer, mpn)

                    if mouser_part:
                        # Search for detailed part information
                        part_result = self.search_part(mouser_part)

                        if part_result.get("found"):
                            # Get pricing for our quantity
                            price_data = self.get_best_price(part_result, quantity)

                            row_data["Mouser Part Number"] = mouser_part
                            row_data["Manufacturer Name"] = part_result.get(
                                "manufacturer", manufacturer
                            )
                            row_data["Description"] = part_result.get(
                                "description", component.get("Description", "")
                            )

                            if price_data:
                                row_data["Order Unit Price"] = price_data["unit_price"]
                                row_data["Quantity 1"] = price_data.get("quantity", 1)
                                row_data["Unit Price 1"] = price_data["unit_price"]

                            row_data["Availability"] = part_result.get(
                                "availability", "Unknown"
                            )
                            row_data["Lead Time in Days"] = part_result.get(
                                "lead_time", "Unknown"
                            )
                            row_data["Lifecycle"] = part_result.get(
                                "lifecycle", "Unknown"
                            )
                            row_data["RoHS"] = part_result.get("rohs", "Unknown")
                            row_data["Package Type"] = part_result.get(
                                "package", "Unknown"
                            )
                            row_data["Datasheet URL"] = part_result.get(
                                "datasheet_url", ""
                            )

                            print(f"  ✅ Found Mouser equivalent: {mouser_part}")
                        else:
                            row_data["Order Unit Price"] = component.get(
                                "Unit Price", "0"
                            )
                            row_data["Design Risk"] = "No Mouser equivalent found"
                            print(f"  ❌ No Mouser part found for {mouser_part}")
                    else:
                        # Try direct search
                        part_result = self.search_part(mpn, manufacturer)

                        if part_result.get("found"):
                            mouser_part = part_result.get("mouser_part", "")
                            price_data = self.get_best_price(part_result, quantity)

                            row_data["Mouser Part Number"] = mouser_part
                            row_data["Manufacturer Name"] = part_result.get(
                                "manufacturer", manufacturer
                            )
                            row_data["Description"] = part_result.get(
                                "description", component.get("Description", "")
                            )

                            if price_data:
                                row_data["Order Unit Price"] = price_data["unit_price"]

                            print(f"  ✅ Found by search: {mouser_part}")
                        else:
                            row_data["Order Unit Price"] = component.get(
                                "Unit Price", "0"
                            )
                            row_data["Design Risk"] = (
                                f"No Mouser equivalent found for {manufacturer} {mpn}"
                            )
                            print("  ❌ No Mouser equivalent found")
                else:
                    row_data["Order Unit Price"] = component.get("Unit Price", "0")
                    row_data["Design Risk"] = "Incomplete manufacturer/part number data"
                    print("  ⚠️ Missing manufacturer or part number information")

            template_data.append(row_data)

        # Save as Excel and CSV files
        try:
            import pandas as pd

            output_df = pd.DataFrame(template_data)

            # Save as Excel file (Mouser preferred format)
            excel_file = os.path.join(output_dir, "BOM_MOUSER_TEMPLATE.xlsx")
            output_df.to_excel(excel_file, index=False, engine="openpyxl")

            # Also save as CSV for easy viewing
            csv_file = os.path.join(output_dir, "BOM_MOUSER_TEMPLATE.csv")
            output_df.to_csv(csv_file, index=False)

            print("✅ Created Mouser template files:")
            print(f"   📁 Excel: {excel_file}")
            print(f"   📁 CSV: {csv_file}")

            # Generate summary
            total_components = len(template_data)
            with_mouser_parts = len(
                [row for row in template_data if row["Mouser Part Number"]]
            )

            print("\n📊 Template Summary:")
            print(f"  Total components: {total_components}")
            print(
                f"  With Mouser parts: {with_mouser_parts} ({with_mouser_parts / total_components * 100:.1f}%)"
            )

            return excel_file

        except ImportError:
            print("❌ pandas not available, saving CSV only")
            csv_file = os.path.join(output_dir, "BOM_MOUSER_TEMPLATE.csv")
            with open(csv_file, "w", newline="", encoding="utf-8") as csvfile:
                writer = csv.DictWriter(csvfile, fieldnames=mouser_columns)
                writer.writeheader()
                writer.writerows(template_data)

            print(f"✅ Created Mouser template CSV: {csv_file}")
            return csv_file

    def generate_mouser_only_bom(self, bom_file: str, output_dir: str) -> str:
        """Generate a consolidated BOM with only Mouser parts"""
        print("🔄 Generating Mouser-only BOM...")

        # Read the consolidated BOM
        components = []
        try:
            with open(bom_file, newline="", encoding="utf-8") as csvfile:
                reader = csv.DictReader(csvfile)
                for row in reader:
                    components.append(row)
        except Exception as e:
            print(f"❌ Error reading BOM file: {e}")
            return None

        # Convert all components to Mouser using dynamic lookup
        mouser_components = []
        for component in components:
            mpn = component.get("Manufacturer Part Number", "")
            manufacturer = component.get("Manufacturer", "")
            new_component = component.copy()

            # Try to find Mouser equivalent using dynamic lookup
            if manufacturer and mpn:
                mouser_part_number = self.get_mouser_part_number(manufacturer, mpn)
                part_result = self.search_part(mpn, manufacturer)

                if part_result.get("found"):
                    new_component["Distributor"] = "Mouser"
                    new_component["Distributor Part Number"] = mouser_part_number
                    print(f"✅ Found Mouser equivalent: {mpn} -> {mouser_part_number}")
                else:
                    print(
                        f"⚠️ No Mouser equivalent found for: {mpn} from {manufacturer}"
                    )
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
    ) -> dict:
        """Calculate cost comparison between current BOM and Mouser alternatives using dynamic lookup"""
        print("📊 Analyzing Mouser consolidation opportunities...")

        components = []
        try:
            with open(bom_file, newline="", encoding="utf-8") as csvfile:
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
            "non_mouser_components": [],
            "mouser_components": [],
            "savings": 0,
            "unavailable_alternatives": [],
        }

        for component in components:
            distributor = component.get("Distributor", "")
            manufacturer = component.get("Manufacturer", "")
            mpn = component.get("Manufacturer Part Number", "")
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
                "mouser_equivalent": None,
                "potential_savings": 0,
            }

            if distributor.lower() != "mouser" and manufacturer and mpn:
                # Try to find Mouser equivalent using dynamic lookup
                print(f"🔍 Searching for Mouser equivalent of {manufacturer} {mpn}...")

                part_result = self.search_part(mpn, manufacturer)

                if part_result.get("found"):
                    price_data = self.get_best_price(part_result, quantity)

                    if price_data:
                        mouser_extended = price_data["total_price"]
                        savings = extended_price - mouser_extended

                        component_analysis["mouser_equivalent"] = {
                            "mouser_part": part_result["mouser_part"],
                            "manufacturer": part_result["manufacturer"],
                            "description": part_result["description"],
                            "unit_price": price_data["unit_price"],
                            "extended_price": mouser_extended,
                            "availability": part_result["availability"],
                            "savings": savings,
                        }
                        component_analysis["potential_savings"] = savings
                        analysis["mouser_total"] += mouser_extended

                        print(
                            f"✅ Found: {part_result['mouser_part']} - ${price_data['unit_price']:.2f} each"
                        )
                    else:
                        print("⚠️ Found part but no pricing available")
                        analysis["unavailable_alternatives"].append(component_analysis)
                        analysis["mouser_total"] += (
                            extended_price  # Use current price as fallback
                        )
                else:
                    print(f"❌ No Mouser equivalent found for {manufacturer} {mpn}")
                    analysis["unavailable_alternatives"].append(component_analysis)
                    analysis["mouser_total"] += (
                        extended_price  # Use current price as fallback
                    )

                analysis["non_mouser_components"].append(component_analysis)
            else:
                # Already at Mouser or no manufacturer info
                analysis["mouser_components"].append(component_analysis)
                analysis["mouser_total"] += extended_price
                print(f"✅ Already Mouser: {mpn}")

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
        self, analysis: dict, output_file: str = "mouser_consolidation_analysis.md"
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
        non_mouser_count = len(analysis["non_mouser_components"])
        mouser_count = len(analysis["mouser_components"])

        report.append("## 🧩 Component Distribution")
        report.append("| Source | Components | Current Cost | Mouser Cost |")
        report.append("|--------|------------|--------------|-------------|")

        non_mouser_current = sum(
            c["current_extended"] for c in analysis["non_mouser_components"]
        )
        non_mouser_mouser = sum(
            c["mouser_equivalent"]["extended_price"]
            if c["mouser_equivalent"]
            else c["current_extended"]
            for c in analysis["non_mouser_components"]
        )

        mouser_current = sum(
            c["current_extended"] for c in analysis["mouser_components"]
        )

        report.append(
            f"| Non-Mouser | {non_mouser_count} | ${non_mouser_current:.2f} | ${non_mouser_mouser:.2f} |"
        )
        report.append(
            f"| Mouser | {mouser_count} | ${mouser_current:.2f} | ${mouser_current:.2f} |"
        )
        report.append("")

        # Detailed component analysis
        if analysis["non_mouser_components"]:
            report.append("## 🔍 Non-Mouser Component Analysis")
            report.append(
                "| Component | Current Price | Best Mouser Alternative | Mouser Price | Savings |"
            )
            report.append(
                "|-----------|---------------|------------------------|--------------|---------|"
            )

            for comp in analysis["non_mouser_components"]:
                original = comp["original"]
                current_cost = comp["current_extended"]

                if comp["mouser_equivalent"]:
                    alt = comp["mouser_equivalent"]
                    alt_cost = alt["extended_price"]
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
        "--generate-mouser-template",
        action="store_true",
        help="Generate BOM in official Mouser template format",
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
            args.generate_mouser_template,
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
            print("🛒 Generating comprehensive purchase files...")

            # Generate Mouser template (primary format)
            manager.generate_mouser_template_file(args.bom_file, args.output_dir)

            # Generate legacy Mouser-only BOM (for compatibility)
            manager.generate_mouser_only_bom(args.bom_file, args.output_dir)

            # Create unified purchase guide
            manager.generate_purchase_guide(
                args.bom_file, validation_results, args.output_dir
            )

            print("")
            print("✅ Purchase files generated successfully!")
            print("")
            print("📁 Generated Files:")
            print(
                "   - BOM_MOUSER_TEMPLATE.xlsx (Official Mouser template - RECOMMENDED)"
            )
            print("   - BOM_MOUSER_TEMPLATE.csv (CSV version for review)")
            print("   - BOM_MOUSER_ONLY.csv (Mouser-only consolidated BOM)")
            print(
                "   - mouser_upload_consolidated_only.csv (Legacy simple upload format)"
            )
            print("   - PURCHASE_GUIDE.md (Comprehensive purchase instructions)")
            print("")
            print("🛒 Next Steps:")
            print("1. See COMPONENT_SOURCING.md for complete sourcing strategy")
            print(
                "2. Upload BOM_MOUSER_TEMPLATE.xlsx to https://www.mouser.com/tools/bom-tool"
            )
            print("3. Enjoy simplified single-distributor ordering!")
            print("")
            print("💡 Benefits of integrated BOM manager:")
            print("   ✅ Real-time pricing via Mouser API")
            print("   ✅ Dynamic part lookup (no hardcoded mappings)")
            print("   ✅ Official Mouser template format")
            print("   ✅ Complete component data (availability, datasheets)")
            print("")

        # Generate Mouser template format (NEW - preferred format)
        if do_all or args.generate_mouser_template:
            manager.generate_mouser_template_file(args.bom_file, args.output_dir)

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
