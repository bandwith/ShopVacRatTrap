#!/usr/bin/env python3
"""
Update BOM files with current pricing from Nexar validation results
"""

import json
import os
import pandas as pd
import sys
from datetime import datetime


def update_bom_pricing():
    """Update BOM files with validated pricing data"""

    if not os.path.exists("validation_results.json"):
        print("❌ No validation results found")
        sys.exit(1)

    with open("validation_results.json", "r") as f:
        results = json.load(f)

    for bom_file, data in results.items():
        if "error" in data:
            print(f"⚠️  Skipping {bom_file} due to validation errors")
            continue

        if not os.path.exists(bom_file):
            print(f"⚠️  BOM file not found: {bom_file}")
            continue

        print(f"📝 Updating {bom_file}...")

        try:
            # Read the current BOM
            df = pd.read_csv(bom_file)

            # Create a mapping of component results by MPN
            component_map = {}
            for component in data.get("components", []):
                mpn = component.get("mpn")
                if mpn and component.get("updated_price"):
                    component_map[mpn] = component

            # Update pricing in the dataframe
            updates_made = 0

            # Find the price column
            price_columns = [
                col
                for col in df.columns
                if "price" in col.lower() or "cost" in col.lower()
            ]
            mpn_columns = [
                col
                for col in df.columns
                if "part number" in col.lower() or col.lower() in ["mpn"]
            ]

            if not price_columns:
                print(f"⚠️  No price column found in {bom_file}")
                continue

            if not mpn_columns:
                print(f"⚠️  No MPN column found in {bom_file}")
                continue

            price_col = price_columns[0]
            mpn_col = mpn_columns[0]

            for idx, row in df.iterrows():
                mpn = str(row[mpn_col]).strip() if pd.notna(row[mpn_col]) else ""

                if mpn in component_map:
                    new_price = component_map[mpn]["updated_price"]
                    old_price = row[price_col] if pd.notna(row[price_col]) else 0

                    # Only update if there's a meaningful difference
                    if abs(new_price - old_price) > 0.01:  # More than 1 cent difference
                        df.at[idx, price_col] = round(new_price, 2)
                        updates_made += 1
                        print(f"   💰 {mpn}: ${old_price:.2f} → ${new_price:.2f}")

            if updates_made > 0:
                # Save the updated BOM
                df.to_csv(bom_file, index=False)
                timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                print(f"✅ Updated {updates_made} prices in {bom_file} at {timestamp}")
            else:
                print(f"ℹ️  No price updates needed for {bom_file}")

        except Exception as e:
            print(f"❌ Error updating {bom_file}: {e}")

    print("✅ BOM pricing update complete")


if __name__ == "__main__":
    update_bom_pricing()
