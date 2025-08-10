#!/usr/bin/env python3
"""
Generate Mouser-compatible BOM upload files from consolidated BOM
Creates CSV files that can be directly uploaded to Mouser for bulk ordering
"""

import csv
import argparse
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


def read_consolidated_bom(bom_file):
    """Read the consolidated BOM CSV file"""
    components = []

    with open(bom_file, "r", newline="", encoding="utf-8") as csvfile:
        reader = csv.DictReader(csvfile)

        for row in reader:
            # Map BOM fields to component data
            component = {
                "manufacturer": row.get("Manufacturer", ""),
                "mpn": row.get("Manufacturer Part Number", ""),
                "description": row.get("Description", ""),
                "quantity": int(row.get("Quantity", "1")),
                "reference": row.get("Reference Designator", ""),
                "distributor": row.get("Distributor", ""),
                "distributor_part": row.get("Distributor Part Number", ""),
                "unit_price": float(row.get("Unit Price", "0"))
                if row.get("Unit Price")
                else 0,
                "extended_price": float(row.get("Extended Price", "0"))
                if row.get("Extended Price")
                else 0,
            }
            components.append(component)

    return components


def generate_mouser_upload_csv(components, output_file):
    """Generate Mouser-compatible CSV for bulk upload"""
    mouser_components = []

    for comp in components:
        # Only include components with Mouser part numbers
        if (
            comp["distributor"].lower() == "mouser"
            or "mouser" in comp["distributor"].lower()
        ):
            mouser_part = comp["distributor_part"]

            # Clean up Mouser part number (remove any prefixes)
            if mouser_part:
                # Remove common prefixes
                mouser_part = mouser_part.replace("709-", "").replace("Mouser ", "")

                mouser_components.append(
                    {
                        "Mouser Part Number": mouser_part,
                        "Quantity": comp["quantity"],
                        "Description": comp["description"],
                        "Manufacturer Part Number": comp["mpn"],
                        "Manufacturer": comp["manufacturer"],
                        "Customer Part Number": comp["reference"],
                    }
                )

    if mouser_components:
        with open(output_file, "w", newline="", encoding="utf-8") as csvfile:
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
            writer.writerows(mouser_components)

        return len(mouser_components)

    return 0


def generate_adafruit_order_list(components, output_file):
    """Generate Adafruit order list with direct URLs"""
    adafruit_components = []
    cart_items = []

    for comp in components:
        if (
            comp["distributor"].lower() == "adafruit"
            or "adafruit" in comp["distributor"].lower()
        ):
            adafruit_part = comp["distributor_part"]

            if adafruit_part and adafruit_part.isdigit():
                product_url = f"https://www.adafruit.com/product/{adafruit_part}"
                cart_items.append(f"add[]={adafruit_part}&qty[]={comp['quantity']}")

                adafruit_components.append(
                    {
                        "Adafruit Product ID": adafruit_part,
                        "Quantity": comp["quantity"],
                        "Description": comp["description"],
                        "Unit Price": f"${comp['unit_price']:.2f}"
                        if comp["unit_price"] > 0
                        else "TBD",
                        "Total Price": f"${comp['extended_price']:.2f}"
                        if comp["extended_price"] > 0
                        else "TBD",
                        "Product URL": product_url,
                    }
                )

    if adafruit_components:
        # Generate CSV
        with open(output_file, "w", newline="", encoding="utf-8") as csvfile:
            fieldnames = [
                "Adafruit Product ID",
                "Quantity",
                "Description",
                "Unit Price",
                "Total Price",
                "Product URL",
            ]
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(adafruit_components)

        # Generate cart URL
        if cart_items:
            cart_data = "&".join(cart_items)
            cart_url = f"https://www.adafruit.com/shopping_cart?{cart_data}"

            # Save cart URL to separate file
            cart_file = str(output_file).replace(".csv", "_cart_url.txt")
            with open(cart_file, "w") as f:
                f.write(f"Adafruit Cart URL:\n{cart_url}\n\n")
                f.write(
                    "Click this link to add all Adafruit components to your cart automatically.\n"
                )

        return len(adafruit_components)

    return 0


def generate_sparkfun_order_list(components, output_file):
    """Generate SparkFun order list with direct URLs"""
    sparkfun_components = []
    cart_items = []

    for comp in components:
        if (
            comp["distributor"].lower() == "sparkfun"
            or "sparkfun" in comp["distributor"].lower()
        ):
            sparkfun_part = comp["distributor_part"]

            if sparkfun_part and sparkfun_part.startswith("COM-"):
                sku = sparkfun_part.replace("COM-", "")
                product_url = f"https://www.sparkfun.com/products/{sku}"
                cart_items.append(f"products[{sku}]={comp['quantity']}")

                sparkfun_components.append(
                    {
                        "SparkFun SKU": sparkfun_part,
                        "Quantity": comp["quantity"],
                        "Description": comp["description"],
                        "Unit Price": f"${comp['unit_price']:.2f}"
                        if comp["unit_price"] > 0
                        else "TBD",
                        "Total Price": f"${comp['extended_price']:.2f}"
                        if comp["extended_price"] > 0
                        else "TBD",
                        "Product URL": product_url,
                    }
                )

    if sparkfun_components:
        # Generate CSV
        with open(output_file, "w", newline="", encoding="utf-8") as csvfile:
            fieldnames = [
                "SparkFun SKU",
                "Quantity",
                "Description",
                "Unit Price",
                "Total Price",
                "Product URL",
            ]
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(sparkfun_components)

        # Generate cart URL
        if cart_items:
            cart_data = "&".join(cart_items)
            cart_url = f"https://www.sparkfun.com/cart?{cart_data}"

            # Save cart URL to separate file
            cart_file = str(output_file).replace(".csv", "_cart_url.txt")
            with open(cart_file, "w") as f:
                f.write(f"SparkFun Cart URL:\n{cart_url}\n\n")
                f.write(
                    "Click this link to add all SparkFun components to your cart automatically.\n"
                )

        return len(sparkfun_components)

    return 0


def generate_purchase_summary(components, output_file):
    """Generate comprehensive purchase summary with links and instructions"""

    # Calculate totals
    total_cost = sum(comp["extended_price"] for comp in components)
    total_components = len(components)

    # Group by distributor
    distributors = {}
    for comp in components:
        dist = comp["distributor"]
        if dist not in distributors:
            distributors[dist] = {"components": [], "cost": 0}
        distributors[dist]["components"].append(comp)
        distributors[dist]["cost"] += comp["extended_price"]

    with open(output_file, "w") as f:
        f.write("# ShopVac Rat Trap 2025 - Purchase Guide\n\n")
        f.write(
            f"*Generated on {__import__('datetime').datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*\n\n"
        )

        f.write("## 📊 Project Cost Summary\n\n")
        f.write(f"**Total Project Cost:** ${total_cost:.2f}\n")
        f.write(f"**Total Components:** {total_components}\n\n")

        f.write("### Cost by Distributor\n\n")
        f.write("| Distributor | Components | Cost | Percentage |\n")
        f.write("|-------------|------------|------|------------|\n")

        for dist, data in sorted(
            distributors.items(), key=lambda x: x[1]["cost"], reverse=True
        ):
            if data["cost"] > 0:
                percentage = (data["cost"] / total_cost * 100) if total_cost > 0 else 0
                f.write(
                    f"| {dist} | {len(data['components'])} | ${data['cost']:.2f} | {percentage:.1f}% |\n"
                )

        f.write("\n## 🛒 Quick Purchase Links\n\n")

        # Mouser section
        mouser_parts = [c for c in components if "mouser" in c["distributor"].lower()]
        if mouser_parts:
            f.write("### Mouser Electronics\n")
            f.write("- **Professional electronic components and power supplies**\n")
            f.write("- **Fast shipping and excellent technical support**\n")
            f.write("- **Bulk pricing available for 10+ units**\n\n")
            f.write("**Upload File:** `mouser_upload_consolidated.csv`\n")
            f.write("**Upload URL:** https://www.mouser.com/tools/bom-tool\n\n")

            # Generate individual part links
            f.write("**Individual Part Links:**\n")
            for comp in mouser_parts:
                part_num = comp["distributor_part"]
                if part_num:
                    url = f"https://www.mouser.com/ProductDetail/{part_num}"
                    f.write(
                        f"- [{comp['mpn']}]({url}) - {comp['description']} (Qty: {comp['quantity']})\n"
                    )
            f.write("\n")

        # Adafruit section
        adafruit_parts = [
            c for c in components if "adafruit" in c["distributor"].lower()
        ]
        if adafruit_parts:
            f.write("### Adafruit\n")
            f.write("- **Maker-friendly modules and sensors**\n")
            f.write("- **STEMMA QT ecosystem components**\n")
            f.write("- **Excellent documentation and tutorials**\n\n")
            f.write("**Order File:** `adafruit_order_consolidated.csv`\n")
            f.write("**Cart URL File:** `adafruit_order_consolidated_cart_url.txt`\n\n")

            # Generate individual part links
            f.write("**Individual Part Links:**\n")
            for comp in adafruit_parts:
                part_num = comp["distributor_part"]
                if part_num and part_num.isdigit():
                    url = f"https://www.adafruit.com/product/{part_num}"
                    f.write(
                        f"- [{comp['mpn']}]({url}) - {comp['description']} (Qty: {comp['quantity']})\n"
                    )
            f.write("\n")

        # SparkFun section
        sparkfun_parts = [
            c for c in components if "sparkfun" in c["distributor"].lower()
        ]
        if sparkfun_parts:
            f.write("### SparkFun\n")
            f.write("- **Open-source hardware designs**\n")
            f.write("- **Qwiic-compatible modules**\n")
            f.write("- **Comprehensive project tutorials**\n\n")
            f.write("**Order File:** `sparkfun_order_consolidated.csv`\n")
            f.write("**Cart URL File:** `sparkfun_order_consolidated_cart_url.txt`\n\n")

            # Generate individual part links
            f.write("**Individual Part Links:**\n")
            for comp in sparkfun_parts:
                part_num = comp["distributor_part"]
                if part_num and part_num.startswith("COM-"):
                    sku = part_num.replace("COM-", "")
                    url = f"https://www.sparkfun.com/products/{sku}"
                    f.write(
                        f"- [{comp['mpn']}]({url}) - {comp['description']} (Qty: {comp['quantity']})\n"
                    )
            f.write("\n")

        f.write("## 📋 Purchase Instructions\n\n")
        f.write("### Recommended Order Sequence\n")
        f.write(
            "1. **Safety-Critical Components First** (Power supplies, relays, fuses, breakers)\n"
        )
        f.write("2. **Electronics Components** (ESP32, sensors, displays, cables)\n")
        f.write("3. **Mechanical Components** (Enclosure, mounting hardware)\n\n")

        f.write("### Bulk Ordering Tips\n")
        f.write("- Use generated upload files for efficient ordering\n")
        f.write("- Contact suppliers directly for 100+ unit quotes\n")
        f.write("- Consider lead times for safety-critical components\n")
        f.write("- Order 10% extra small components (cables, connectors)\n\n")

        f.write("### Alternative Sources\n")
        f.write("- **McMaster-Carr:** Mechanical hardware and fasteners\n")
        f.write("- **Amazon Business:** Common components with fast shipping\n")
        f.write("- **Local electrical supply:** AC components and wire\n")
        f.write("- **Allied Electronics:** Professional component distribution\n\n")

        f.write("### Quality Assurance\n")
        f.write("- Verify all safety-critical components are UL/CE listed\n")
        f.write("- Check component specifications match BOM requirements\n")
        f.write("- Inspect packages for damage upon delivery\n")
        f.write("- Test components before installation when possible\n\n")

        f.write("---\n\n")
        f.write(
            "*💡 For technical support and component questions, refer to the [COMPONENT_SOURCING.md](COMPONENT_SOURCING.md) guide.*\n"
        )


def main():
    """Main function"""
    parser = argparse.ArgumentParser(
        description="Generate purchase files from consolidated BOM"
    )
    parser.add_argument(
        "--bom-file", default="BOM_CONSOLIDATED.csv", help="Consolidated BOM file"
    )
    parser.add_argument("--output-dir", default="purchasing", help="Output directory")

    args = parser.parse_args()

    # Read components from consolidated BOM
    try:
        components = read_consolidated_bom(args.bom_file)
        print(f"📋 Loaded {len(components)} components from {args.bom_file}")
    except FileNotFoundError:
        print(f"❌ Error: BOM file {args.bom_file} not found")
        return 1
    except Exception as e:
        print(f"❌ Error reading BOM file: {e}")
        return 1

    output_dir = Path(args.output_dir)

    # Generate Mouser upload file
    mouser_file = output_dir / "mouser_upload_consolidated.csv"
    mouser_count = generate_mouser_upload_csv(components, mouser_file)
    if mouser_count > 0:
        print(
            f"✅ Generated Mouser upload file: {mouser_file} ({mouser_count} components)"
        )
    else:
        print("⚠️  No Mouser components found for upload file")

    # Generate Adafruit order list
    adafruit_file = output_dir / "adafruit_order_consolidated.csv"
    adafruit_count = generate_adafruit_order_list(components, adafruit_file)
    if adafruit_count > 0:
        print(
            f"✅ Generated Adafruit order file: {adafruit_file} ({adafruit_count} components)"
        )
    else:
        print("⚠️  No Adafruit components found for order file")

    # Generate SparkFun order list
    sparkfun_file = output_dir / "sparkfun_order_consolidated.csv"
    sparkfun_count = generate_sparkfun_order_list(components, sparkfun_file)
    if sparkfun_count > 0:
        print(
            f"✅ Generated SparkFun order file: {sparkfun_file} ({sparkfun_count} components)"
        )
    else:
        print("⚠️  No SparkFun components found for order file")

    # Generate comprehensive purchase summary
    summary_file = output_dir / "PURCHASE_GUIDE.md"
    generate_purchase_summary(components, summary_file)
    print(f"✅ Generated purchase guide: {summary_file}")

    print("\n📊 Summary:")
    print(f"   Total components: {len(components)}")
    print(f"   Mouser components: {mouser_count}")
    print(f"   Adafruit components: {adafruit_count}")
    print(f"   SparkFun components: {sparkfun_count}")

    total_cost = sum(comp["extended_price"] for comp in components)
    print(f"   Total project cost: ${total_cost:.2f}")

    return 0


if __name__ == "__main__":
    exit(main())
