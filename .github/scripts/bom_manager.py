import argparse
import json
import os
from pathlib import Path
import csv
from datetime import datetime
import re

from mouser_api import MouserAPIClient, MouserPartNotFoundError, MouserBOMValidator


class BOMManagerError(Exception):
    """Base exception for BOM Manager errors."""

    pass


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


def load_bom_components(bom_file: str) -> list[dict]:
    """Loads BOM components from a CSV file."""
    components = []
    try:
        with open(bom_file, newline="", encoding="utf-8") as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                components.append(row)
        return components
    except Exception as e:
        raise BOMManagerError(f"Error reading BOM file: {e}") from e


class BOMColumns:
    UNIT_PRICE = "Unit Price"
    MANUFACTURER_PART_NUMBER = "Manufacturer Part Number"
    EXTENDED_PRICE = "Extended Price"
    MANUFACTURER = "Manufacturer"
    DESCRIPTION = "Description"
    QUANTITY = "Quantity"
    DISTRIBUTOR = "Distributor"
    DISTRIBUTOR_PART_NUMBER = "Distributor Part Number"


class BOMUpdater:
    """Updates a BOM file with new data."""

    def _find_column_indices(
        self, header: list[str]
    ) -> tuple[int | None, int | None, int | None]:
        """Finds the column indices for unit price, MPN, and extended price."""
        header_map = {col: idx for idx, col in enumerate(header)}

        unit_price_col = next(
            (
                idx
                for col, idx in header_map.items()
                if BOMColumns.UNIT_PRICE.lower() in col.lower()
            ),
            None,
        )
        mpn_col = next(
            (
                idx
                for col, idx in header_map.items()
                if BOMColumns.MANUFACTURER_PART_NUMBER.lower() in col.lower()
            ),
            None,
        )
        ext_price_col = next(
            (
                idx
                for col, idx in header_map.items()
                if BOMColumns.EXTENDED_PRICE.lower() in col.lower()
            ),
            None,
        )
        return unit_price_col, mpn_col, ext_price_col

    def update_bom_pricing(self, bom_file: str, validation_results: dict) -> bool:
        """Update BOM with current pricing from validation results"""
        print(f"📝 Updating BOM pricing in {bom_file}...\n")

        try:
            # Read the original BOM to preserve structure
            with open(bom_file, newline="") as csvfile:
                reader = csv.reader(csvfile)
                header = next(reader)
                rows = list(reader)

            unit_price_col, mpn_col, ext_price_col = self._find_column_indices(header)

            if not unit_price_col or not mpn_col:
                raise BOMManagerError("Could not find required columns in BOM file")

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
            raise BOMManagerError(f"Error updating BOM pricing: {e}") from e


class BOMValidator:
    """Validates a BOM file using the Mouser API."""

    SIGNIFICANT_PRICE_CHANGE_THRESHOLD = 5.0  # Percentage
    CRITICAL_PRICE_CHANGE_THRESHOLD = 10.0  # Percentage

    def __init__(self, mouser_bom_validator: MouserBOMValidator):
        self.mouser_bom_validator = mouser_bom_validator

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

            validation_results = self._initialize_validation_results(
                bom_file, len(components)
            )

            priority_set = set(priority_components or [])

            # Process components with priority items first
            sorted_components = sorted(
                components,
                key=lambda c: c.get(BOMColumns.MANUFACTURER_PART_NUMBER, "")
                in priority_set,
                reverse=True,
            )

            current_total_cost = 0.0
            updated_total_cost = 0.0

            for component in sorted_components:
                (
                    component_result,
                    current_extended_cost,
                    updated_extended_cost,
                ) = self._process_component(component, priority_set, validation_results)
                current_total_cost += current_extended_cost
                updated_total_cost += updated_extended_cost
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
                if abs(total_change_percent) >= self.SIGNIFICANT_PRICE_CHANGE_THRESHOLD:
                    validation_results["pricing_changes"]["significant_changes"] = True

            return validation_results

        except Exception as e:
            raise BOMManagerError(f"Error validating BOM: {e}") from e

    def _initialize_validation_results(
        self, bom_file: str, total_components: int
    ) -> dict:
        """Initializes the validation results dictionary."""
        return {
            "bom_file": bom_file,
            "timestamp": datetime.now().isoformat(),
            "total_components": total_components,
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

    def _process_component(
        self, component: dict, priority_set: set, validation_results: dict
    ) -> tuple[dict, float, float]:
        """Processes a single component for validation."""
        mpn = component.get(BOMColumns.MANUFACTURER_PART_NUMBER, "").strip()
        manufacturer = component.get(BOMColumns.MANUFACTURER, "").strip()
        description = component.get(BOMColumns.DESCRIPTION, "")

        try:
            quantity = int(component.get(BOMColumns.QUANTITY, 1))
        except ValueError:
            quantity = 1

        try:
            current_price = float(component.get(BOMColumns.UNIT_PRICE, 0))
        except ValueError:
            current_price = 0.0

        # Calculate current cost
        current_extended = current_price * quantity

        # Skip empty or comment rows
        if not mpn or mpn.startswith("#"):
            return (
                {
                    "mpn": mpn,
                    "error": "Empty or comment row",
                    "found": False,
                    "is_priority": mpn in priority_set,
                },
                current_extended,
                0.0,
            )

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

        updated_extended = 0.0

        # Delegate to MouserBOMValidator for single component validation
        mouser_validation_data = self.mouser_bom_validator.validate_single_component(
            mpn, manufacturer, quantity
        )

        if mouser_validation_data["found"]:
            component_result["found"] = True
            validation_results["found_components"] += 1

            component_result["availability"] = mouser_validation_data["availability"]
            stock_match = re.search(
                r"(\d+)\s+In Stock", mouser_validation_data["availability"]
            )
            if stock_match:
                component_result["stock_qty"] = int(stock_match.group(1))
            else:
                component_result["stock_qty"] = 0

            component_result["in_stock"] = component_result["stock_qty"] >= quantity
            component_result["datasheet"] = mouser_validation_data["datasheet"]
            component_result["product_url"] = mouser_validation_data["product_url"]

            pricing = mouser_validation_data["pricing"]
            if pricing:
                component_result["updated_price"] = pricing["unit_price"]
                component_result["updated_extended"] = pricing["total_price"]
                updated_extended = pricing["total_price"]

                if current_price > 0:
                    price_change = pricing["unit_price"] - current_price
                    price_change_percent = (price_change / current_price) * 100

                    component_result["price_change"] = price_change
                    component_result["price_change_percent"] = price_change_percent

                    if (
                        abs(price_change_percent)
                        >= self.SIGNIFICANT_PRICE_CHANGE_THRESHOLD
                    ):
                        validation_results["pricing_changes"]["changed_components"] += 1
                        validation_results["pricing_changes"]["changes_detected"] = True

                        if abs(
                            price_change_percent
                        ) >= self.CRITICAL_PRICE_CHANGE_THRESHOLD or (
                            is_priority
                            and abs(price_change_percent)
                            >= self.SIGNIFICANT_PRICE_CHANGE_THRESHOLD
                        ):
                            validation_results["pricing_changes"][
                                "significant_changes"
                            ] = True
        else:
            component_result["error"] = mouser_validation_data["error"]
            if mouser_validation_data.get("suggestions"):
                component_result["suggestions"] = mouser_validation_data["suggestions"]

        return component_result, current_extended, updated_extended


class BOMReporter:
    """Generates reports from BOM validation results."""

    def _generate_report_header(self, title: str) -> list[str]:
        """Generates a common report header."""
        header = []
        header.append(f"# {title}")
        header.append(
            f"*Generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*\n"
        )
        return header

    def generate_pricing_report(self, validation_results: dict):
        """Generate pricing report from validation results"""
        report = []

        report.extend(self._generate_report_header("BOM Pricing Validation Report"))

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
                and abs(component.get("price_change_percent", 0))
                >= BOMValidator.SIGNIFICANT_PRICE_CHANGE_THRESHOLD
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

    def generate_availability_report(self, validation_results: dict):
        """Generate availability report from validation results"""
        report = []

        report.extend(self._generate_report_header("Component Availability Report"))

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

        # Generate dynamic issue title if there are unavailable components
        if has_unavailable:
            title = "🚨 Component Availability Alert - Critical Parts Low Stock"
            if unavailable:
                # Use the first unavailable component to generate a specific title
                first_comp = unavailable[0]
                # Try to extract a meaningful role/name from description
                desc = first_comp.get("description", "").split(",")[0].strip()
                if not desc:
                    desc = first_comp.get("mpn", "Unknown Part")

                # Truncate if too long
                if len(desc) > 50:
                    desc = desc[:47] + "..."

                title = f"🚨 Component Availability Alert - {desc}"
                if len(unavailable) > 1:
                    title += f" (+{len(unavailable) - 1} others)"

            # Write title to file for workflow to use
            with open("availability_issue_title.txt", "w") as f:
                f.write(title)


class BOMPurchaseFileGenerator:
    """Generates purchase files from a BOM."""

    MOUSER_TEMPLATE_COLUMNS = [
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

    def __init__(self, client: MouserAPIClient):
        self.client = client

    def generate_mouser_template_file(self, bom_file: str, output_dir: str) -> str:
        """Generate BOM in official Mouser template format using dynamic lookup"""
        print("🛒 Generating Mouser template format file...")

        # Ensure output directory exists
        os.makedirs(output_dir, exist_ok=True)

        components = load_bom_components(bom_file)
        if components is None:
            return None

        print(f"📦 Processing {len(components)} components for Mouser template...")

        print(
            f"📋 Using standard Mouser template structure: {len(self.MOUSER_TEMPLATE_COLUMNS)} columns"
        )

        # Create the migrated BOM data
        template_data = []

        for i, component in enumerate(components, 1):
            print(
                f"🔍 [{i}/{len(components)}] Processing: {component[BOMColumns.DESCRIPTION][:50]}..."
            )

            manufacturer = component.get(BOMColumns.MANUFACTURER, "")
            mpn = component.get(BOMColumns.MANUFACTURER_PART_NUMBER, "")
            quantity = int(component.get(BOMColumns.QUANTITY, 1))
            current_distributor = component.get(BOMColumns.DISTRIBUTOR, "")

            # Initialize row with template structure
            row_data = {col: "" for col in self.MOUSER_TEMPLATE_COLUMNS}

            # Set basic information
            row_data["Mfr Part Number (Input)"] = mpn
            row_data["Manufacturer Part Number"] = mpn
            row_data["Manufacturer Name"] = manufacturer
            row_data["Description"] = component.get(BOMColumns.DESCRIPTION, "")
            row_data["Order Quantity"] = quantity

            # If already from Mouser, use existing data
            if (current_distributor or "").lower() == "mouser":
                mouser_part = component.get(BOMColumns.DISTRIBUTOR_PART_NUMBER, "")
                unit_price = component.get(BOMColumns.UNIT_PRICE, "0")

                row_data["Mouser Part Number"] = mouser_part
                row_data["Order Unit Price"] = unit_price

                print(f"  ✅ Already Mouser: {mouser_part}")

            else:
                # Use dynamic lookup to find Mouser equivalent
                if manufacturer and mpn:
                    try:
                        parts = self.client.search_part_number(mpn, manufacturer)
                        if parts:
                            part_result = parts[0]
                            # Get pricing for our quantity
                            price_data = self.client.get_best_price(
                                part_result, quantity
                            )

                            row_data["Mouser Part Number"] = (
                                part_result.mouser_part_number
                            )
                            row_data["Manufacturer Name"] = part_result.manufacturer
                            row_data["Description"] = part_result.description

                            if price_data:
                                row_data["Order Unit Price"] = price_data["unit_price"]
                                row_data["Quantity 1"] = price_data.get("quantity", 1)
                                row_data["Unit Price 1"] = price_data["unit_price"]

                            row_data["Availability"] = part_result.availability
                            row_data["Lead Time in Days"] = part_result.lead_time
                            row_data["Lifecycle"] = part_result.lifecycle_status
                            row_data["RoHS"] = part_result.rohs_status
                            row_data["Package Type"] = part_result.packaging
                            row_data["Datasheet URL"] = part_result.data_sheet_url

                            print(
                                f"  ✅ Found Mouser equivalent: {part_result.mouser_part_number}"
                            )
                        else:
                            row_data["Order Unit Price"] = component.get(
                                "Unit Price", "0"
                            )
                            row_data["Design Risk"] = "No Mouser equivalent found"
                            print(f"  ❌ No Mouser part found for {mpn}")
                    except MouserPartNotFoundError:
                        row_data["Order Unit Price"] = component.get("Unit Price", "0")
                        row_data["Design Risk"] = "No Mouser equivalent found"
                        print(f"  ❌ No Mouser part found for {mpn}")
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
                writer = csv.DictWriter(
                    csvfile, fieldnames=self.MOUSER_TEMPLATE_COLUMNS
                )
                writer.writeheader()
                writer.writerows(template_data)

            print(f"✅ Created Mouser template CSV: {csv_file}")
            return csv_file

    def generate_mouser_only_bom(self, bom_file: str, output_dir: str) -> str:
        """Generate a consolidated BOM with only Mouser parts"""
        print("🔄 Generating Mouser-only BOM...\n")

        components = load_bom_components(bom_file)
        if components is None:
            return None

        # Convert all components to Mouser using dynamic lookup
        mouser_components = []
        for component in components:
            mpn = component.get(BOMColumns.MANUFACTURER_PART_NUMBER, "")
            manufacturer = component.get(BOMColumns.MANUFACTURER) or ""
            new_component = component.copy()

            # Try to find Mouser equivalent using dynamic lookup
            if manufacturer and mpn:
                try:
                    parts = self.client.search_part_number(mpn, manufacturer)
                    if parts:
                        part_result = parts[0]
                        new_component[BOMColumns.DISTRIBUTOR] = "Mouser"
                        new_component[BOMColumns.DISTRIBUTOR_PART_NUMBER] = (
                            part_result.mouser_part_number
                        )
                        print(
                            f"✅ Found Mouser equivalent: {mpn} -> {part_result.mouser_part_number}"
                        )
                    else:
                        print(
                            f"⚠️ No Mouser equivalent found for: {mpn} from {manufacturer}"
                        )
                except MouserPartNotFoundError:
                    print(
                        f"⚠️ No Mouser equivalent found for: {mpn} from {manufacturer}"
                    )

            elif (component.get(BOMColumns.DISTRIBUTOR) or "").lower() == "mouser":
                # Already at Mouser, keep as-is
                print(f"✅ Keeping Mouser part: {mpn}")
            else:
                # Unknown mapping - flag for manual review
                print(
                    f"⚠️ Manual review needed for: {mpn} from {component.get(BOMColumns.DISTRIBUTOR, 'Unknown')}"
                )
                new_component[BOMColumns.DISTRIBUTOR] = "Mouser"
                new_component[BOMColumns.DISTRIBUTOR_PART_NUMBER] = f"REVIEW-{mpn}"

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

    def generate_purchase_guide(
        self, bom_file: str, validation_results: dict = None, output_dir: str = "."
    ) -> str:
        """Generate purchase guide with direct links"""
        print("📋 Generating purchase guide...\n")

        components = load_bom_components(bom_file)
        if components is None:
            return None

        # Create purchase guide
        guide = []
        guide.append("# Component Purchase Guide")
        guide.append(f"*Generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")

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
            distributor = component.get(BOMColumns.DISTRIBUTOR) or "Other"
            if distributor not in distributors:
                distributors[distributor] = []
            distributors[distributor].append(component)

        # Create section for each distributor
        for distributor, dist_components in distributors.items():
            guide.append(f"## {distributor} Components")
            guide.append("| Qty | Part Number | Description | Price | Link |")
            guide.append("|-----|------------|-------------|-------|------|")

            for component in dist_components:
                mpn = component.get(BOMColumns.MANUFACTURER_PART_NUMBER, "")
                description = component.get(BOMColumns.DESCRIPTION, "")
                quantity = component.get(BOMColumns.QUANTITY, "1")
                unit_price = component.get(BOMColumns.UNIT_PRICE, "")

                # Generate link based on distributor
                link = ""
                if distributor.lower() == "mouser":
                    part_no = component.get(BOMColumns.DISTRIBUTOR_PART_NUMBER, mpn)
                    link = f"[Buy](https://www.mouser.com/ProductDetail/{part_no})"
                elif distributor.lower() == "digikey":
                    part_no = component.get(BOMColumns.DISTRIBUTOR_PART_NUMBER, mpn)
                    link = f"[Buy](https://www.digikey.com/product-detail/{part_no})"
                elif distributor.lower() == "adafruit":
                    part_no = component.get(BOMColumns.DISTRIBUTOR_PART_NUMBER, "")
                    if part_no:
                        link = f"[Buy](https://www.adafruit.com/product/{part_no})"
                elif distributor.lower() == "sparkfun":
                    part_no = component.get(BOMColumns.DISTRIBUTOR_PART_NUMBER, mpn)
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


def _should_do_all(args: argparse.Namespace) -> bool:
    """Determines if all operations should be performed."""
    return args.all or not any(
        [
            args.validate,
            args.check_availability,
            args.update_pricing,
            args.generate_purchase_files,
            args.generate_mouser_template,
            args.generate_mouser_only,
        ]
    )


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
        "--generate-mouser-only", action="store_true", help="Generate Mouser-only BOM"
    )

    # If no action specified, do all
    parser.add_argument("--all", action="store_true", help="Perform all operations")

    args = parser.parse_args()

    do_all = _should_do_all(args)

    # Load priority components from config
    config_path = Path(__file__).parent / "config.json"
    with open(config_path) as f:
        config = json.load(f)
    priority_components = config.get("PRIORITY_COMPONENTS", [])
    if args.priority_components:
        priority_components.extend(args.priority_components)

    try:
        # Ensure output directory exists
        os.makedirs(args.output_dir, exist_ok=True)

        # Initialize clients and services
        client = MouserAPIClient(args.api_key)
        mouser_bom_validator = MouserBOMValidator(args.api_key)
        validator = BOMValidator(mouser_bom_validator)
        reporter = BOMReporter()
        updater = BOMUpdater()
        purchase_file_generator = BOMPurchaseFileGenerator(client)

        # Track results for later operations
        validation_results = None

        # Validate BOM
        if do_all or args.validate or args.check_availability:
            validation_results = validator.validate_bom(
                args.bom_file, args.priority_components
            )

            output_file = os.path.join(args.output_dir, "validation_results.json")
            with open(output_file, "w") as f:
                json.dump(validation_results, f, indent=2)
            print(f"💾 Validation results saved to {output_file}")

            reporter.generate_pricing_report(validation_results)
            reporter.generate_availability_report(validation_results)

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

        # Update BOM pricing if changes detected
        if (
            (do_all or args.update_pricing)
            and validation_results
            and validation_results["pricing_changes"]["changes_detected"]
        ):
            updater.update_bom_pricing(args.bom_file, validation_results)

        # Generate purchase files
        if (
            do_all
            or args.generate_purchase_files
            or args.generate_mouser_template
            or args.generate_mouser_only
        ):
            print("🛒 Generating comprehensive purchase files...")

            # Generate Mouser template (primary format)
            purchase_file_generator.generate_mouser_template_file(
                args.bom_file, args.output_dir
            )

            # Generate legacy Mouser-only BOM (for compatibility)
            purchase_file_generator.generate_mouser_only_bom(
                args.bom_file, args.output_dir
            )

            # Create unified purchase guide
            purchase_file_generator.generate_purchase_guide(
                args.bom_file, validation_results, args.output_dir
            )

            print(
                """
✅ Purchase files generated successfully!

📁 Generated Files:
   - BOM_MOUSER_TEMPLATE.xlsx (Official Mouser template - RECOMMENDED)
   - BOM_MOUSER_TEMPLATE.csv (CSV version for review)
   - BOM_MOUSER_ONLY.csv (Mouser-only consolidated BOM)
   - mouser_upload_consolidated_only.csv (Legacy simple upload format)
   - PURCHASE_GUIDE.md (Comprehensive purchase instructions)

🛒 Next Steps:
1. See COMPONENT_SOURCING.md for complete sourcing strategy
2. Upload BOM_MOUSER_TEMPLATE.xlsx to https://www.mouser.com/tools/bom-tool
3. Enjoy simplified single-distributor ordering!

💡 Benefits of integrated BOM manager:
   ✅ Real-time pricing via Mouser API
   ✅ Dynamic part lookup (no hardcoded mappings)
   ✅ Official Mouser template format
   ✅ Complete component data (availability, datasheets)
"""
            )

        print("✅ BOM management operations complete")
        return 0

    except BOMManagerError as e:
        print(f"❌ Operation failed: {e}")
        return 1
    except Exception as e:
        print(f"❌ An unexpected error occurred: {e}")
        return 1


if __name__ == "__main__":
    exit(main())
