#!/usr/bin/env python3
"""
Generate detailed pricing reports from hybrid validation results
Supports both Nexar and Mouser API data in unified format
"""

import json
import sys


def format_currency(amount, currency="USD"):
    """Format currency amount"""
    if amount is None:
        return "N/A"
    return f"${amount:.2f} {currency}"


def format_availability(availability):
    """Format availability information"""
    if not availability:
        return "Unknown"

    if isinstance(availability, str):
        return availability

    if isinstance(availability, (int, float)):
        if availability > 1000:
            return f"{availability:,.0f} in stock"
        elif availability > 0:
            return f"{availability:.0f} in stock"
        else:
            return "Out of stock"

    return str(availability)


def generate_component_report(component, bom_name):
    """Generate report section for a single component"""
    mpn = component.get("mpn", "Unknown")
    manufacturer = component.get("manufacturer", "Unknown")
    found = component.get("found", False)
    priority = component.get("priority", "normal")
    api_used = component.get("api_used", "unknown")

    # Priority indicator
    priority_icon = "🚨" if priority == "high" else "📦"

    report = f"\n#### {priority_icon} {mpn} ({manufacturer})\n\n"

    if found:
        # Component found - show details
        pricing = component.get("pricing", {})
        availability = component.get("availability")
        sources = component.get("sources", [])

        # Status
        api_badge = {
            "nexar": "🌐 Multi-supplier (Nexar)",
            "mouser": "🛒 Mouser",
            "hybrid": "🔄 Hybrid",
        }.get(api_used, f"❓ {api_used}")

        report += f"**Status:** ✅ Found via {api_badge}\n\n"

        # Pricing information
        if pricing:
            qty = pricing.get("quantity", 1)
            unit_price = pricing.get("unit_price", 0)
            total_price = pricing.get("total_price", 0)
            currency = pricing.get("currency", "USD")
            note = pricing.get("note", "")

            report += "**Pricing:**\n"
            report += f"- Unit Price: {format_currency(unit_price, currency)}\n"
            report += f"- Quantity: {qty}\n"
            report += f"- Total: {format_currency(total_price, currency)}\n"
            if note:
                report += f"- Note: {note}\n"
            report += "\n"

        # Availability
        if availability:
            report += f"**Availability:** {format_availability(availability)}\n\n"

        # Source details
        if sources:
            report += "**Sources:**\n"
            for source in sources:
                supplier = source.get("supplier", "Unknown")

                if supplier == "Mouser":
                    mouser_part = source.get("mouser_part", "")
                    description = source.get("description", "")
                    lead_time = source.get("lead_time", "")
                    lifecycle = source.get("lifecycle", "")
                    datasheet = source.get("datasheet", "")
                    product_url = source.get("product_url", "")

                    report += f"- **{supplier}**\n"
                    if mouser_part:
                        report += f"  - Part #: {mouser_part}\n"
                    if description:
                        report += f"  - Description: {description}\n"
                    if lead_time:
                        report += f"  - Lead Time: {lead_time}\n"
                    if lifecycle:
                        report += f"  - Lifecycle: {lifecycle}\n"
                    if datasheet:
                        report += f"  - [Datasheet]({datasheet})\n"
                    if product_url:
                        report += f"  - [Product Page]({product_url})\n"

                elif "Nexar" in supplier:
                    description = source.get("description", "")
                    median_price = source.get("median_price", {})
                    sellers = source.get("sellers", [])

                    report += f"- **{supplier}**\n"
                    if description:
                        report += f"  - Description: {description}\n"
                    if median_price:
                        price = median_price.get("price", 0)
                        currency = median_price.get("currency", "USD")
                        report += f"  - Median Price (1K): {format_currency(price, currency)}\n"
                    if sellers:
                        report += f"  - Available from {len(sellers)} suppliers\n"

                report += "\n"
    else:
        # Component not found
        errors = component.get("errors", [])

        report += f"**Status:** ❌ Not found via {api_used}\n\n"

        if errors:
            report += "**Errors:**\n"
            for error in errors:
                report += f"- {error}\n"
            report += "\n"

        # Show suggestions if available
        suggestions = component.get("suggestions", [])
        if suggestions:
            report += "**Suggestions:**\n"
            for suggestion in suggestions:
                sugg_mpn = suggestion.get("mpn", "")
                sugg_mfg = suggestion.get("manufacturer", "")
                sugg_desc = suggestion.get("description", "")
                sugg_mouser = suggestion.get("mouser_part", "")

                report += f"- **{sugg_mpn}** ({sugg_mfg})\n"
                if sugg_desc:
                    report += f"  - {sugg_desc}\n"
                if sugg_mouser:
                    report += f"  - Mouser: {sugg_mouser}\n"
            report += "\n"

        report += "**Recommended Actions:**\n"
        report += "- Verify part number spelling and format\n"
        report += "- Check if part has been discontinued\n"
        report += "- Consider alternative/substitute parts\n"
        report += "- Manual search on distributor websites\n\n"

    return report


def generate_bom_summary(results):
    """Generate summary section for BOM"""
    bom_file = results.get("bom_file", "Unknown")
    total_components = results.get("total_components", 0)
    found_components = results.get("found_components", 0)
    total_cost = results.get("total_cost", 0)
    validation_strategy = results.get("validation_strategy", "unknown")
    api_usage = results.get("api_usage", {})

    success_rate = (
        (found_components / total_components * 100) if total_components > 0 else 0
    )

    summary = f"\n### 📋 {bom_file}\n\n"
    summary += f"**Validation Strategy:** {validation_strategy}\n\n"

    summary += "| Metric | Value |\n"
    summary += "|--------|-------|\n"
    summary += f"| Total Components | {total_components} |\n"
    summary += f"| Found Components | {found_components} |\n"
    summary += f"| Success Rate | {success_rate:.1f}% |\n"
    summary += f"| Estimated Total Cost | {format_currency(total_cost)} |\n"
    summary += f"| Nexar API Calls | {api_usage.get('nexar_calls', 0)} |\n"
    summary += f"| Mouser API Calls | {api_usage.get('mouser_calls', 0)} |\n"

    if api_usage.get("nexar_quota_exceeded"):
        summary += "| Nexar Quota Status | ⚠️ Exceeded |\n"

    summary += "\n"

    # Cost breakdown by category if we can infer it
    high_priority_cost = sum(
        comp.get("pricing", {}).get("total_price", 0)
        for comp in results.get("components", [])
        if comp.get("priority") == "high" and comp.get("found")
    )

    if high_priority_cost > 0:
        summary += f"**Safety-Critical Components Cost:** {format_currency(high_priority_cost)}\n\n"

    return summary


def main():
    """Main function"""
    if len(sys.argv) != 2:
        print("Usage: python generate_hybrid_report.py <validation_results.json>")
        sys.exit(1)

    results_file = sys.argv[1]

    try:
        with open(results_file, "r") as f:
            results = json.load(f)
    except FileNotFoundError:
        print(f"Error: File {results_file} not found")
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"Error: Invalid JSON in {results_file}")
        sys.exit(1)

    # Generate BOM summary
    report = generate_bom_summary(results)

    # Group components by status
    components = results.get("components", [])
    found_components = [c for c in components if c.get("found")]
    missing_components = [c for c in components if not c.get("found")]
    high_priority = [c for c in components if c.get("priority") == "high"]

    # High priority components section
    if high_priority:
        report += "\n### 🚨 Safety-Critical Components\n"
        for component in high_priority:
            report += generate_component_report(component, results.get("bom_file", ""))

    # Found components section
    if found_components:
        regular_found = [c for c in found_components if c.get("priority") != "high"]
        if regular_found:
            report += "\n### ✅ Successfully Validated Components\n"
            for component in regular_found:
                report += generate_component_report(
                    component, results.get("bom_file", "")
                )

    # Missing components section
    if missing_components:
        report += "\n### ❌ Components Requiring Attention\n"
        for component in missing_components:
            report += generate_component_report(component, results.get("bom_file", ""))

    # API usage summary
    api_usage = results.get("api_usage", {})
    if api_usage:
        report += "\n### 📡 API Usage Summary\n\n"
        report += f"- **Nexar API Calls:** {api_usage.get('nexar_calls', 0)}\n"
        report += f"- **Mouser API Calls:** {api_usage.get('mouser_calls', 0)}\n"

        if api_usage.get("nexar_quota_exceeded"):
            report += (
                "- **Nexar Status:** ⚠️ Quota exceeded - fallback to Mouser successful\n"
            )
        else:
            report += "- **Nexar Status:** ✅ Within quota limits\n"

        errors = api_usage.get("errors", [])
        if errors:
            report += f"- **Errors:** {len(errors)} API errors encountered\n"

        report += "\n"

    print(report)


if __name__ == "__main__":
    main()
