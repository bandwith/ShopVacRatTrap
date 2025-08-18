import csv
import re
from datetime import datetime
from mouser_api import MouserAPIClient, MouserPartNotFoundError


class BOMValidator:
    """Validates a BOM file using the Mouser API."""

    def __init__(self, client: MouserAPIClient):
        self.client = client

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
                try:
                    parts = self.client.search_part_number(mpn, manufacturer)
                    if parts:
                        best_part = parts[0]
                        component_result["found"] = True
                        validation_results["found_components"] += 1

                        # Update with Mouser data
                        component_result["availability"] = best_part.availability
                        # Extract stock quantity from availability string
                        stock_match = re.search(
                            r"(\d+)\s+In Stock", best_part.availability
                        )
                        if stock_match:
                            component_result["stock_qty"] = int(stock_match.group(1))
                        else:
                            component_result["stock_qty"] = 0

                        component_result["in_stock"] = (
                            component_result["stock_qty"] >= quantity
                        )
                        component_result["datasheet"] = best_part.data_sheet_url
                        component_result["product_url"] = best_part.product_detail_url

                        # Get pricing information
                        pricing = self.client.get_best_price(best_part, quantity)

                        if pricing:
                            component_result["updated_price"] = pricing["unit_price"]
                            component_result["updated_extended"] = pricing[
                                "total_price"
                            ]
                            updated_total_cost += pricing["total_price"]

                            # Calculate price changes
                            if current_price > 0:
                                price_change = pricing["unit_price"] - current_price
                                price_change_percent = (
                                    price_change / current_price
                                ) * 100

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
                        component_result["error"] = "Part not found"
                except MouserPartNotFoundError:
                    component_result["error"] = "Part not found"

                validation_results["components"].append(component_result)

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

            return validation_results

        except Exception as e:
            print(f"❌ Error validating BOM: {e}")
            return {"error": str(e)}
