#!/usr/bin/env python3
"""
BOM Validator using Mouser API
Validates BOM parts and updates pricing using Mouser API
"""

import os
import json
import argparse
import csv
import time
import requests
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


class MouserAPIError(Exception):
    """Base exception for Mouser API errors"""

    pass


class MouserRateLimitError(MouserAPIError):
    """Raised when rate limit is exceeded"""

    pass


class BOMValidator:
    """BOM validator using Mouser API"""

    def __init__(self, api_key: str = None):
        """Initialize BOM validator with Mouser API key"""
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
        print("✅ BOM validator initialized with Mouser API")

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


def main():
    parser = argparse.ArgumentParser(description="Validate BOM with Mouser API")
    parser.add_argument("--bom-file", required=True, help="BOM file to validate")
    parser.add_argument("--output-dir", default=".", help="Output directory")
    parser.add_argument(
        "--api-key", help="Mouser API key (or set MOUSER_API_KEY env var)"
    )
    parser.add_argument(
        "--priority-components", nargs="*", help="Priority component MPNs"
    )

    args = parser.parse_args()

    try:
        validator = BOMValidator(args.api_key)
        results = validator.validate_bom(args.bom_file, args.priority_components)

        if "error" not in results:
            output_file = os.path.join(args.output_dir, "validation_results.json")
            with open(output_file, "w") as f:
                json.dump(results, f, indent=2)

            print(f"💾 Results saved to {output_file}")
            return 0
        else:
            print(f"❌ Validation failed: {results['error']}")
            return 1

    except Exception as e:
        print(f"❌ Fatal error: {e}")
        return 1


if __name__ == "__main__":
    exit(main())
