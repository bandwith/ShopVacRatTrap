from datetime import datetime
import os


class BOMReporter:
    """Generates reports from BOM validation results."""

    def generate_pricing_report(self, validation_results: dict):
        """Generate pricing report from validation results"""
        report = []

        report.append("# BOM Pricing Validation Report")
        report.append(
            f"*Generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*\n"
        )

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
                and abs(component.get("price_change_percent", 0)) >= 5.0
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

        report.append("# Component Availability Report")
        report.append(
            f"*Generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*\n"
        )

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
