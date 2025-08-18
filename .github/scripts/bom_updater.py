import csv


class BOMUpdater:
    """Updates a BOM file with new data."""

    def _find_column_indices(
        self, header: list[str]
    ) -> tuple[int | None, int | None, int | None]:
        """Finds the column indices for unit price, MPN, and extended price."""
        header_map = {col: idx for idx, col in enumerate(header)}

        unit_price_col = next(
            (idx for col, idx in header_map.items() if "unit price" in col.lower()),
            None,
        )
        mpn_col = next(
            (idx for col, idx in header_map.items() if "part number" in col.lower()),
            None,
        )
        ext_price_col = next(
            (idx for col, idx in header_map.items() if "extended price" in col.lower()),
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
                print("❌ Could not find required columns in BOM file")
                return False

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
            print(f"❌ Error updating BOM pricing: {e}")
            return False
