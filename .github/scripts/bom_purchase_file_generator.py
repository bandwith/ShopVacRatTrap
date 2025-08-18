import csv
import os
from datetime import datetime
from mouser_api import MouserAPIClient, MouserPartNotFoundError


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

    def _load_bom_components(self, bom_file: str) -> list[dict] | None:
        """Loads BOM components from a CSV file."""
        components = []
        try:
            with open(bom_file, newline="", encoding="utf-8") as csvfile:
                reader = csv.DictReader(csvfile)
                for row in reader:
                    components.append(row)
            return components
        except Exception as e:
            print(f"❌ Error reading BOM file: {e}")
            return None

    def generate_mouser_template_file(self, bom_file: str, output_dir: str) -> str:
        """Generate BOM in official Mouser template format using dynamic lookup"""
        print("🛒 Generating Mouser template format file...")

        # Ensure output directory exists
        os.makedirs(output_dir, exist_ok=True)

        components = self._load_bom_components(bom_file)
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
                f"🔍 [{i}/{len(components)}] Processing: {component['Description'][:50]}..."
            )

            manufacturer = component.get("Manufacturer", "")
            mpn = component.get("Manufacturer Part Number", "")
            quantity = int(component.get("Quantity", 1))
            current_distributor = component.get("Distributor", "")

            # Initialize row with template structure
            row_data = {col: "" for col in self.MOUSER_TEMPLATE_COLUMNS}

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

        components = self._load_bom_components(bom_file)
        if components is None:
            return None

        # Convert all components to Mouser using dynamic lookup
        mouser_components = []
        for component in components:
            mpn = component.get("Manufacturer Part Number", "")
            manufacturer = component.get("Manufacturer", "")
            new_component = component.copy()

            # Try to find Mouser equivalent using dynamic lookup
            if manufacturer and mpn:
                try:
                    parts = self.client.search_part_number(mpn, manufacturer)
                    if parts:
                        part_result = parts[0]
                        new_component["Distributor"] = "Mouser"
                        new_component["Distributor Part Number"] = (
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

    def generate_purchase_guide(
        self, bom_file: str, validation_results: dict = None, output_dir: str = "."
    ) -> str:
        """Generate purchase guide with direct links"""
        print("📋 Generating purchase guide...\n")

        components = self._load_bom_components(bom_file)
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
