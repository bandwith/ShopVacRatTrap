#!/usr/bin/env python3
"""
Generate pricing report from Nexar validation results
"""

import json
import os
from datetime import datetime
from typing import Dict, List


def format_currency(amount: float, currency: str = "USD") -> str:
    """Format currency amount"""
    return f"${amount:.2f}" if currency == "USD" else f"{amount:.2f} {currency}"


def calculate_total_cost(components: List[Dict]) -> float:
    """Calculate total BOM cost"""
    total = 0
    for component in components:
        price = component.get("updated_price") or component.get("current_price", 0)
        quantity = component.get("quantity", 1)
        total += price * quantity
    return total


def generate_pricing_report():
    """Generate markdown pricing report from validation results"""

    if not os.path.exists("validation_results.json"):
        print("❌ No validation results found")
        return

    with open("validation_results.json", "r") as f:
        results = json.load(f)

    report = []
    report.append("## 💰 BOM Pricing Validation Report")
    report.append(f"**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}")
    report.append("")

    significant_changes = False
    total_cost_change = 0

    for bom_file, data in results.items():
        if "error" in data:
            report.append(f"### ❌ {bom_file} - Validation Failed")
            report.append(f"**Error**: {data['error']}")
            report.append("")
            continue

        components = data.get("components", [])
        total_components = data.get("total_components", 0)
        validated_components = data.get("validated_components", 0)
        pricing_updates = data.get("pricing_updates", 0)
        errors = data.get("errors", 0)

        report.append(f"### 📋 {bom_file}")
        report.append("")
        report.append("**Summary:**")
        report.append(f"- 📊 Total Components: {total_components}")
        report.append(f"- ✅ Successfully Validated: {validated_components}")
        report.append(f"- 💰 Pricing Updates: {pricing_updates}")
        report.append(f"- ❌ Validation Errors: {errors}")

        if total_components > 0:
            success_rate = (validated_components / total_components) * 100
            report.append(f"- 📈 Validation Success Rate: {success_rate:.1f}%")

        report.append("")

        # Calculate cost changes
        current_total = calculate_total_cost(
            [c for c in components if c.get("current_price", 0) > 0]
        )
        updated_total = calculate_total_cost(
            [c for c in components if c.get("updated_price")]
        )

        if current_total > 0 and updated_total > 0:
            cost_change = updated_total - current_total
            cost_change_percent = (cost_change / current_total) * 100
            total_cost_change += abs(cost_change_percent)

            report.append("**Cost Analysis:**")
            report.append(f"- Previous Total: {format_currency(current_total)}")
            report.append(f"- Updated Total: {format_currency(updated_total)}")
            report.append(
                f"- Cost Change: {format_currency(cost_change)} ({cost_change_percent:+.1f}%)"
            )

            if abs(cost_change_percent) > 5:
                significant_changes = True
                report.append("- ⚠️  **Significant cost change detected!**")

            report.append("")

        # Component details with significant changes
        significant_component_changes = []
        for component in components:
            if component.get("price_change_percent", 0) != 0:
                change = component["price_change_percent"]
                if abs(change) > 10:  # >10% change
                    significant_component_changes.append(component)

        if significant_component_changes:
            report.append("**🔍 Significant Price Changes (>10%):**")
            report.append("")
            report.append("| Component | Manufacturer | Current | Updated | Change |")
            report.append("|-----------|--------------|---------|---------|--------|")

            for component in significant_component_changes:
                mpn = component.get("mpn", "Unknown")
                mfg = component.get("manufacturer", "Unknown")
                current = format_currency(component.get("current_price", 0))
                updated = format_currency(component.get("updated_price", 0))
                change = component.get("price_change_percent", 0)
                change_str = f"{change:+.1f}%"

                # Add warning emoji for large increases
                if change > 20:
                    change_str = f"⚠️ {change_str}"
                elif change < -20:
                    change_str = f"✅ {change_str}"

                report.append(
                    f"| {mpn} | {mfg} | {current} | {updated} | {change_str} |"
                )

            report.append("")
            significant_changes = True

        # Availability issues
        unavailable_components = [
            c for c in components if c.get("availability") == "Not Found"
        ]
        if unavailable_components:
            report.append("**❌ Components Not Found in Nexar:**")
            report.append("")
            for component in unavailable_components:
                mpn = component.get("mpn", "Unknown")
                mfg = component.get("manufacturer", "Unknown")
                report.append(f"- {mpn} ({mfg})")
            report.append("")
            report.append(
                "*Consider finding alternative parts or updating part numbers.*"
            )
            report.append("")

    # Overall assessment
    report.append("## 📊 Overall Assessment")
    report.append("")

    if significant_changes or total_cost_change > 5:
        report.append("⚠️  **Action Required**: Significant pricing changes detected")
        report.append("")
        report.append("**Recommended Actions:**")
        report.append("1. Review components with major price increases")
        report.append("2. Consider alternative suppliers or components")
        report.append("3. Update project cost estimates")
        report.append(
            "4. Update ELECTRICAL_DESIGN.md if total cost changed significantly"
        )
    else:
        report.append("✅ **No significant changes** - BOM pricing is stable")

    report.append("")
    report.append("---")
    report.append(
        "*This report was automatically generated by the Nexar API pricing validation system.*"
    )

    # Write report
    with open("pricing_report.md", "w") as f:
        f.write("\n".join(report))

    # Generate pricing changes summary for GitHub Actions
    changes_data = {
        "changes_detected": len(
            [
                c
                for bom in results.values()
                for c in bom.get("components", [])
                if c.get("price_change_percent", 0) != 0
            ]
        )
        > 0,
        "significant_changes": significant_changes,
        "total_cost_change_percent": total_cost_change,
    }

    with open("pricing_changes.json", "w") as f:
        json.dump(changes_data, f, indent=2)

    print("✅ Pricing report generated: pricing_report.md")
    print(f"📊 Changes detected: {changes_data['changes_detected']}")
    print(f"⚠️  Significant changes: {changes_data['significant_changes']}")


if __name__ == "__main__":
    generate_pricing_report()
