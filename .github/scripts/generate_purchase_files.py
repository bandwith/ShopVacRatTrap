#!/usr/bin/env python3
"""
Generate Purchase Files
Creates purchase guide and Mouser upload files from BOM data
"""

import os
import json
import csv
import argparse
from datetime import datetime


def generate_purchase_guide(bom_file, validation_results=None):
    """Generate purchase guide with links to buy components"""
    print("📋 Generating purchase guide...")

    # Load validation results if provided
    results_data = None
    if validation_results and os.path.exists(validation_results):
        try:
            with open(validation_results, "r") as f:
                results_data = json.load(f)
        except Exception as e:
            print(f"⚠️ Unable to load validation results: {e}")

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
    if results_data:
        guide.append("## 📊 Validation Summary")
        guide.append(
            f"**Total Components:** {results_data.get('total_components', len(components))}"
        )
        guide.append(f"**Components Found:** {results_data.get('found_components', 0)}")
        guide.append(
            f"**Success Rate:** {(results_data.get('found_components', 0) / results_data.get('total_components', len(components)) * 100):.1f}%"
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
            # We use manufacturer in future extensions
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

    return "\n".join(guide)


def generate_mouser_upload_file(bom_file, output_dir):
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


def main():
    parser = argparse.ArgumentParser(description="Generate purchase files from BOM")
    parser.add_argument("--bom-file", required=True, help="BOM file to process")
    parser.add_argument("--output-dir", default="purchasing", help="Output directory")
    parser.add_argument("--validation-results", help="Validation results JSON file")

    args = parser.parse_args()

    try:
        # Create output directory if it doesn't exist
        os.makedirs(args.output_dir, exist_ok=True)

        # Generate purchase guide
        guide = generate_purchase_guide(args.bom_file, args.validation_results)
        if guide:
            guide_path = os.path.join(args.output_dir, "PURCHASE_GUIDE.md")
            with open(guide_path, "w") as f:
                f.write(guide)

            # Also create a copy in the main directory for easier access
            with open("PURCHASE_GUIDE.md", "w") as f:
                f.write(guide)

            print(f"✅ Created purchase guide: {guide_path}")

        # Generate Mouser upload file
        generate_mouser_upload_file(args.bom_file, args.output_dir)

        print("✅ Purchase files generation complete")
        return 0
    except Exception as e:
        print(f"❌ Error generating purchase files: {e}")
        return 1


if __name__ == "__main__":
    exit(main())
