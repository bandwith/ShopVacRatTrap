#!/usr/bin/env python3
"""
Nexar API Parts Validation Tool
Validates BOM components against Nexar database for pricing and availability
"""

import csv
import json
import os
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import requests
from dotenv import load_dotenv

# Path configuration
REPO_ROOT = Path(__file__).parent.parent.parent
GITHUB_DIR = Path(__file__).parent.parent


@dataclass
class PartInfo:
    """Part information from BOM"""

    manufacturer: str
    part_number: str
    description: str
    quantity: int
    estimated_cost: float
    supplier: str = ""


@dataclass
class NexarPartData:
    """Part data from Nexar API"""

    manufacturer: str
    part_number: str
    description: str
    availability: int
    unit_price: float
    supplier: str
    datasheet_url: str = ""
    lifecycle_status: str = ""


class NexarAPIClient:
    """Nexar API client for parts validation"""

    def __init__(self):
        load_dotenv()
        self.client_id = os.getenv("NEXAR_CLIENT_ID")
        self.client_secret = os.getenv("NEXAR_CLIENT_SECRET")
        self.api_url = os.getenv("NEXAR_API_URL", "https://api.nexar.com/graphql")
        self.auth_url = os.getenv(
            "NEXAR_AUTH_URL", "https://identity.nexar.com/connect/token"
        )
        self.access_token = None

    def authenticate(self) -> bool:
        """Authenticate with Nexar API and get access token"""
        if not self.client_secret:
            print("⚠️  NEXAR_CLIENT_SECRET not set in .env file")
            print("   Please add your client secret to continue")
            return False

        auth_data = {
            "grant_type": "client_credentials",
            "client_id": self.client_id,
            "client_secret": self.client_secret,
            "scope": "supply.domain",
        }

        try:
            response = requests.post(self.auth_url, data=auth_data)
            response.raise_for_status()
            token_data = response.json()
            self.access_token = token_data["access_token"]
            return True
        except requests.RequestException as e:
            print(f"❌ Authentication failed: {e}")
            return False

    def search_part(
        self, manufacturer: str, part_number: str
    ) -> Optional[NexarPartData]:
        """Search for a part in Nexar database"""
        if not self.access_token:
            if not self.authenticate():
                return None

        # GraphQL query for part search
        query = """
        query SearchParts($manufacturer: String!, $partNumber: String!) {
          supSearch(
            q: $partNumber
            filters: {
              manufacturers: [$manufacturer]
            }
            limit: 1
          ) {
            results {
              part {
                manufacturer {
                  name
                }
                mpn
                shortDescription
                descriptions {
                  text
                }
                specs {
                  attribute {
                    name
                  }
                  displayValue
                }
              }
              sellers {
                company {
                  name
                }
                offers {
                  inventoryLevel
                  prices {
                    price
                    quantity
                  }
                  clickUrl
                }
              }
            }
          }
        }
        """

        variables = {"manufacturer": manufacturer, "partNumber": part_number}

        headers = {
            "Authorization": f"Bearer {self.access_token}",
            "Content-Type": "application/json",
        }

        try:
            response = requests.post(
                self.api_url,
                json={"query": query, "variables": variables},
                headers=headers,
            )
            response.raise_for_status()
            data = response.json()

            if "errors" in data:
                print(f"⚠️  GraphQL errors: {data['errors']}")
                return None

            results = data.get("data", {}).get("supSearch", {}).get("results", [])
            if not results:
                return None

            # Extract part data from first result
            result = results[0]
            part = result["part"]
            sellers = result.get("sellers", [])

            # Find best pricing/availability
            best_offer = None
            for seller in sellers:
                for offer in seller.get("offers", []):
                    prices = offer.get("prices", [])
                    if prices and (
                        not best_offer
                        or offer["inventoryLevel"] > best_offer["inventoryLevel"]
                    ):
                        best_offer = {
                            "supplier": seller["company"]["name"],
                            "availability": offer["inventoryLevel"],
                            "unit_price": prices[0]["price"],
                            "click_url": offer.get("clickUrl", ""),
                        }

            if not best_offer:
                return None

            return NexarPartData(
                manufacturer=part["manufacturer"]["name"],
                part_number=part["mpn"],
                description=part.get("shortDescription", ""),
                availability=best_offer["availability"],
                unit_price=best_offer["unit_price"],
                supplier=best_offer["supplier"],
            )

        except requests.RequestException as e:
            print(f"❌ API request failed: {e}")
            return None


def load_bom_file(filepath: str) -> List[PartInfo]:
    """Load parts from BOM CSV file"""
    parts = []

    try:
        with open(filepath, "r", newline="", encoding="utf-8") as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                # Handle different CSV column formats
                part_number = (
                    row.get("Manufacturer Part Number")
                    or row.get("Part Number")
                    or row.get("PartNumber", "")
                )
                manufacturer = row.get("Manufacturer") or row.get("Mfg", "")
                description = row.get("Description") or row.get("Desc", "")

                # Parse quantity
                qty_str = row.get("Quantity") or row.get("Qty", "1")
                try:
                    quantity = int(qty_str) if qty_str else 1
                except (ValueError, TypeError):
                    quantity = 1

                # Parse cost
                cost_str = (
                    row.get("Unit Price")
                    or row.get("Est. Cost")
                    or row.get("Cost", "$0")
                )
                try:
                    cost_clean = (
                        str(cost_str).replace("$", "").replace(",", "")
                        if cost_str
                        else "0"
                    )
                    cost = float(cost_clean) if cost_clean else 0.0
                except (ValueError, TypeError):
                    cost = 0.0

                # Get supplier/distributor
                supplier = row.get("Distributor") or row.get("Supplier", "")

                if part_number and manufacturer:
                    parts.append(
                        PartInfo(
                            manufacturer=manufacturer,
                            part_number=part_number,
                            description=description,
                            quantity=quantity,
                            estimated_cost=cost,
                            supplier=supplier,
                        )
                    )

    except FileNotFoundError:
        print(f"❌ BOM file not found: {filepath}")
    except Exception as e:
        print(f"❌ Error reading BOM file {filepath}: {e}")

    return parts


def validate_bom(bom_file: str, output_file: str = None) -> Tuple[int, int, float]:
    """Validate BOM against Nexar database"""
    print(f"\n🔍 Validating BOM: {bom_file}")
    print("=" * 60)

    parts = load_bom_file(bom_file)
    if not parts:
        print("❌ No parts loaded from BOM")
        return 0, 0, 0.0

    client = NexarAPIClient()
    if not client.authenticate():
        return 0, 0, 0.0

    validated_parts = []
    total_estimated = 0.0
    total_actual = 0.0
    found_count = 0

    for i, part in enumerate(parts, 1):
        print(f"\n[{i:2d}/{len(parts)}] {part.manufacturer} {part.part_number}")

        nexar_data = client.search_part(part.manufacturer, part.part_number)

        if nexar_data:
            found_count += 1
            unit_cost = nexar_data.unit_price
            total_cost = unit_cost * part.quantity
            total_estimated += part.estimated_cost * part.quantity
            total_actual += total_cost

            price_diff = (
                ((unit_cost - part.estimated_cost) / part.estimated_cost * 100)
                if part.estimated_cost > 0
                else 0
            )

            print(f"  ✅ Found: {nexar_data.description}")
            print(f"     Supplier: {nexar_data.supplier}")
            print(f"     Stock: {nexar_data.availability:,} units")
            print(
                f"     Price: ${unit_cost:.2f} (est: ${part.estimated_cost:.2f}, {price_diff:+.1f}%)"
            )
            print(f"     Total: ${total_cost:.2f} (qty: {part.quantity})")

            validated_parts.append(
                {
                    "part": part,
                    "nexar_data": nexar_data,
                    "price_difference": price_diff,
                    "total_cost": total_cost,
                }
            )
        else:
            print("  ❌ Not found in Nexar database")
            total_estimated += part.estimated_cost * part.quantity

            validated_parts.append(
                {
                    "part": part,
                    "nexar_data": None,
                    "price_difference": None,
                    "total_cost": part.estimated_cost * part.quantity,
                }
            )

    # Summary
    print("\n📊 VALIDATION SUMMARY")
    print("=" * 60)
    print(f"Total Parts: {len(parts)}")
    print(f"Found in Nexar: {found_count} ({found_count / len(parts) * 100:.1f}%)")
    print(f"Missing: {len(parts) - found_count}")
    print(f"Estimated Total: ${total_estimated:.2f}")
    print(f"Actual Total: ${total_actual:.2f}")
    print(
        f"Price Difference: ${total_actual - total_estimated:.2f} ({(total_actual - total_estimated) / total_estimated * 100:+.1f}%)"
    )

    # Save validation report
    if output_file:
        save_validation_report(
            validated_parts, output_file, total_estimated, total_actual
        )

    return len(parts), found_count, total_actual


def save_validation_report(
    validated_parts: List[Dict],
    output_file: str,
    total_estimated: float,
    total_actual: float,
):
    """Save validation report to JSON file"""
    report = {
        "validation_date": "2025-08-09",
        "summary": {
            "total_parts": len(validated_parts),
            "found_parts": len([p for p in validated_parts if p["nexar_data"]]),
            "total_estimated": total_estimated,
            "total_actual": total_actual,
            "price_difference": total_actual - total_estimated,
        },
        "parts": [],
    }

    for item in validated_parts:
        part = item["part"]
        nexar_data = item["nexar_data"]

        part_info = {
            "manufacturer": part.manufacturer,
            "part_number": part.part_number,
            "description": part.description,
            "quantity": part.quantity,
            "estimated_cost": part.estimated_cost,
            "found_in_nexar": nexar_data is not None,
        }

        if nexar_data:
            part_info.update(
                {
                    "nexar_description": nexar_data.description,
                    "actual_cost": nexar_data.unit_price,
                    "availability": nexar_data.availability,
                    "supplier": nexar_data.supplier,
                    "price_difference_percent": item["price_difference"],
                    "total_cost": item["total_cost"],
                }
            )

        report["parts"].append(part_info)

    with open(output_file, "w") as f:
        json.dump(report, f, indent=2)

    print(f"\n💾 Validation report saved: {output_file}")


def main():
    """Main function"""
    print("🔧 ShopVac Rat Trap - Nexar Parts Validation")
    print("=" * 60)

    # Load BOM files from environment or use defaults
    bom_files = os.getenv("BOM_FILES", f"{REPO_ROOT}/BOM_CONSOLIDATED.csv").split(",")

    total_parts = 0
    total_found = 0

    for bom_file in bom_files:
        bom_file = bom_file.strip()
        if os.path.exists(bom_file):
            output_file = f"validation_report_{bom_file.replace('.csv', '.json')}"
            parts, found, actual_cost = validate_bom(bom_file, output_file)
            total_parts += parts
            total_found += found
        else:
            print(f"⚠️  BOM file not found: {bom_file}")

    print("\n🎯 OVERALL RESULTS")
    print("=" * 60)
    print(f"Total Parts Validated: {total_parts}")
    if total_parts > 0:
        print(
            f"Successfully Found: {total_found} ({total_found / total_parts * 100:.1f}%)"
        )

        if total_found < total_parts:
            print(
                "\n💡 TIP: Missing parts may need manual verification or alternative sourcing"
            )
    else:
        print("⚠️  No parts were loaded from BOM files")
        print("   Check BOM file format and column headers")


if __name__ == "__main__":
    main()
