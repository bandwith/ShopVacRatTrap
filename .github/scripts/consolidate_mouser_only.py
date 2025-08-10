#!/usr/bin/env python3
"""
Consolidate BOM to use Mouser only for ShopVac Rat Trap 2025
Since Mouser distributes Adafruit products, we can source everything from one place.

This script:
1. Reads the current BOM_CONSOLIDATED.csv
2. Maps Adafruit and SparkFun components to their Mouser equivalents
3. Generates a Mouser-only BOM
4. Creates upload files for testing
"""

import csv
import sys
from pathlib import Path

# Component mapping: Adafruit/SparkFun to Mouser part numbers
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


def read_consolidated_bom(bom_file):
    """Read the consolidated BOM CSV file"""
    components = []
    try:
        with open(bom_file, "r", newline="", encoding="utf-8") as file:
            reader = csv.DictReader(file)
            for row in reader:
                components.append(row)
        return components
    except FileNotFoundError:
        print(f"❌ Error: BOM file not found: {bom_file}")
        return None
    except Exception as e:
        print(f"❌ Error reading BOM: {e}")
        return None


def consolidate_to_mouser(components):
    """Convert all components to Mouser sourcing"""
    mouser_components = []

    for component in components:
        mfg_part = component["Manufacturer Part Number"]
        new_component = component.copy()

        # Check if we have a Mouser mapping for this part
        if mfg_part in MOUSER_COMPONENT_MAPPING:
            new_component["Distributor"] = "Mouser"
            new_component["Distributor Part Number"] = MOUSER_COMPONENT_MAPPING[
                mfg_part
            ]
            print(f"✅ Mapped {mfg_part} -> {MOUSER_COMPONENT_MAPPING[mfg_part]}")
        elif component["Distributor"] == "Mouser":
            # Already at Mouser, keep as-is
            print(f"✅ Keeping Mouser part: {mfg_part}")
        else:
            # Unknown mapping - flag for manual review
            print(
                f"⚠️  Manual review needed for: {mfg_part} from {component['Distributor']}"
            )
            new_component["Distributor"] = "Mouser"
            new_component["Distributor Part Number"] = f"REVIEW-{mfg_part}"

        mouser_components.append(new_component)

    return mouser_components


def write_mouser_bom(components, output_file):
    """Write the Mouser-only BOM"""
    try:
        with open(output_file, "w", newline="", encoding="utf-8") as file:
            if components:
                fieldnames = components[0].keys()
                writer = csv.DictWriter(file, fieldnames=fieldnames)
                writer.writeheader()
                writer.writerows(components)
        return True
    except Exception as e:
        print(f"❌ Error writing BOM: {e}")
        return False


def generate_mouser_upload_csv(components, output_file):
    """Generate Mouser BOM upload CSV format"""
    try:
        with open(output_file, "w", newline="", encoding="utf-8") as file:
            writer = csv.writer(file)
            # Mouser BOM upload format
            writer.writerow(
                [
                    "Mouser Part Number",
                    "Quantity",
                    "Customer Part Number",
                    "Description",
                ]
            )

            for component in components:
                if not component["Distributor Part Number"].startswith("REVIEW-"):
                    writer.writerow(
                        [
                            component["Distributor Part Number"],
                            component["Quantity"],
                            component["Reference Designator"],
                            component["Description"],
                        ]
                    )
        return True
    except Exception as e:
        print(f"❌ Error writing Mouser upload CSV: {e}")
        return False


def calculate_total_cost(components):
    """Calculate total project cost"""
    total = 0.0
    for component in components:
        try:
            extended_price = float(component["Extended Price"])
            total += extended_price
        except (ValueError, KeyError):
            pass
    return total


def main():
    # File paths
    project_root = Path(__file__).parent.parent.parent
    bom_file = project_root / "BOM_CONSOLIDATED.csv"
    output_dir = project_root / "purchasing"

    print("🛒 Consolidating BOM to Mouser-only sourcing...")
    print(f"📁 Project root: {project_root}")
    print(f"📋 Reading BOM: {bom_file}")
    print("")

    # Read current BOM
    components = read_consolidated_bom(bom_file)
    if not components:
        return 1

    print(f"📦 Found {len(components)} components in BOM")
    print("")

    # Consolidate to Mouser
    print("🔄 Mapping components to Mouser...")
    mouser_components = consolidate_to_mouser(components)
    print("")

    # Calculate costs
    original_total = calculate_total_cost(components)
    mouser_total = calculate_total_cost(mouser_components)

    print("💰 Cost Analysis:")
    print(f"   Original total: ${original_total:.2f}")
    print(f"   Mouser total:   ${mouser_total:.2f}")
    if mouser_total != original_total:
        savings = original_total - mouser_total
        print(f"   Difference:     ${savings:+.2f}")
    print("")

    # Write outputs
    output_dir.mkdir(exist_ok=True)

    # Mouser-only BOM
    mouser_bom_file = output_dir / "BOM_MOUSER_ONLY.csv"
    if write_mouser_bom(mouser_components, mouser_bom_file):
        print(f"✅ Generated: {mouser_bom_file}")

    # Mouser upload CSV
    mouser_upload_file = output_dir / "mouser_upload_consolidated_only.csv"
    if generate_mouser_upload_csv(mouser_components, mouser_upload_file):
        print(f"✅ Generated: {mouser_upload_file}")

    print("")
    print("🛒 Mouser-only BOM consolidation complete!")
    print("")
    print("📁 Generated Files:")
    print(f"   - {mouser_bom_file} (Complete Mouser BOM)")
    print(f"   - {mouser_upload_file} (Mouser bulk upload)")
    print("")
    print("🔗 Next Steps:")
    print(
        "1. Upload mouser_upload_consolidated_only.csv to https://www.mouser.com/tools/bom-tool"
    )
    print("2. Review any components marked 'REVIEW-' for manual verification")
    print(
        "3. Compare pricing and availability with original multi-distributor approach"
    )

    return 0


if __name__ == "__main__":
    sys.exit(main())
