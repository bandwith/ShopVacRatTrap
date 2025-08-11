#!/usr/bin/env python3
"""
Migrate BOM_CONSOLIDATED.csv to Mouser BOM Template format
Uses the refactored BOM manager with dynamic lookup functionality
"""

import os
import sys
import csv
import pandas as pd
from pathlib import Path

# Add the scripts directory to the path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from bom_manager import BOMManager


def migrate_to_mouser_template(input_bom: str, template_file: str, output_file: str):
    """
    Migrate existing BOM to Mouser template format with dynamic part lookup
    """
    print("🔄 Migrating BOM to Mouser template format...")

    # Initialize BOM manager
    bom_manager = BOMManager()

    # Read the template to get the column structure
    template_df = pd.read_excel(template_file, engine="xlrd")
    mouser_columns = template_df.columns.tolist()

    print(f"📋 Mouser template columns: {len(mouser_columns)} fields")

    # Read the current BOM
    current_bom = []
    with open(input_bom, "r", newline="", encoding="utf-8") as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            current_bom.append(row)

    print(f"📦 Processing {len(current_bom)} components...")

    # Create the migrated BOM data
    migrated_data = []

    for i, component in enumerate(current_bom, 1):
        print(
            f"\n🔍 [{i}/{len(current_bom)}] Processing: {component['Description'][:50]}..."
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
            print(f"  🔍 Searching Mouser for {manufacturer} {mpn}...")

            if manufacturer and mpn:
                # Try to get Mouser part number using vendor prefix
                mouser_part = bom_manager.get_mouser_part_number(manufacturer, mpn)

                if mouser_part:
                    # Search for detailed part information
                    part_result = bom_manager.search_part(mouser_part)

                    if part_result.get("found"):
                        # Get pricing for our quantity
                        price_data = bom_manager.get_best_price(part_result, quantity)

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
                        row_data["Lifecycle"] = part_result.get("lifecycle", "Unknown")
                        row_data["RoHS"] = part_result.get("rohs", "Unknown")
                        row_data["Package Type"] = part_result.get("package", "Unknown")
                        row_data["Datasheet URL"] = part_result.get("datasheet_url", "")

                        print(
                            f"  ✅ Found Mouser equivalent: {mouser_part} - ${price_data['unit_price'] if price_data else 'N/A'}"
                        )
                    else:
                        print(f"  ❌ No Mouser part found for {mouser_part}")
                        # Keep original information but mark as not found
                        row_data["Order Unit Price"] = component.get("Unit Price", "0")
                        row_data["Design Risk"] = "No Mouser equivalent found"
                else:
                    # Try direct search with manufacturer and MPN
                    part_result = bom_manager.search_part(mpn, manufacturer)

                    if part_result.get("found"):
                        mouser_part = part_result.get("mouser_part", "")
                        price_data = bom_manager.get_best_price(part_result, quantity)

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
                        row_data["Lifecycle"] = part_result.get("lifecycle", "Unknown")
                        row_data["RoHS"] = part_result.get("rohs", "Unknown")
                        row_data["Package Type"] = part_result.get("package", "Unknown")
                        row_data["Datasheet URL"] = part_result.get("datasheet_url", "")

                        print(
                            f"  ✅ Found by search: {mouser_part} - ${price_data['unit_price'] if price_data else 'N/A'}"
                        )
                    else:
                        print(
                            f"  ❌ No Mouser equivalent found for {manufacturer} {mpn}"
                        )
                        # Keep original information
                        row_data["Order Unit Price"] = component.get("Unit Price", "0")
                        row_data["Design Risk"] = (
                            f"No Mouser equivalent found for {manufacturer} {mpn}"
                        )
            else:
                print("  ⚠️ Missing manufacturer or part number information")
                row_data["Order Unit Price"] = component.get("Unit Price", "0")
                row_data["Design Risk"] = "Incomplete manufacturer/part number data"

        migrated_data.append(row_data)

    # Create output DataFrame and save
    output_df = pd.DataFrame(migrated_data)

    # Save as Excel file to match Mouser template format
    output_excel = output_file.replace(".csv", ".xlsx")
    output_df.to_excel(output_excel, index=False, engine="openpyxl")

    # Also save as CSV for easy viewing
    output_df.to_csv(output_file, index=False)

    print("\n✅ Migration complete!")
    print(f"📁 Excel output: {output_excel}")
    print(f"📁 CSV output: {output_file}")

    # Generate summary report
    total_components = len(migrated_data)
    with_mouser_parts = len([row for row in migrated_data if row["Mouser Part Number"]])
    missing_equivalents = len(
        [
            row
            for row in migrated_data
            if "No Mouser equivalent" in row.get("Design Risk", "")
        ]
    )

    print("\n📊 Migration Summary:")
    print(f"  Total components: {total_components}")
    print(
        f"  With Mouser parts: {with_mouser_parts} ({with_mouser_parts / total_components * 100:.1f}%)"
    )
    print(
        f"  Missing equivalents: {missing_equivalents} ({missing_equivalents / total_components * 100:.1f}%)"
    )

    return output_excel, output_file


def main():
    """Main migration function"""
    workspace_root = Path(__file__).parent.parent.parent

    input_bom = workspace_root / "BOM_CONSOLIDATED.csv"
    template_file = workspace_root / "BomTemplate.xls"
    output_file = workspace_root / "BOM_MOUSER_TEMPLATE.csv"

    if not input_bom.exists():
        print(f"❌ Input BOM not found: {input_bom}")
        return

    if not template_file.exists():
        print(f"❌ Mouser template not found: {template_file}")
        return

    try:
        excel_file, csv_file = migrate_to_mouser_template(
            str(input_bom), str(template_file), str(output_file)
        )

        print("\n🎉 Successfully migrated BOM to Mouser template format!")
        print(f"Use {excel_file} for uploading to Mouser")

    except Exception as e:
        print(f"❌ Migration failed: {e}")
        import traceback

        traceback.print_exc()


if __name__ == "__main__":
    main()
