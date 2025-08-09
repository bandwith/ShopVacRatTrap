#!/usr/bin/env python3
"""
Check component availability using Nexar API
Focus on safety-critical and lead-time sensitive components
"""

import os
import json
import argparse
import pandas as pd
import requests
from datetime import datetime
import sys

# Nexar API Configuration
NEXAR_ENDPOINT = "https://api.nexar.com/graphql"

# Safety-critical components that require special monitoring
CRITICAL_COMPONENTS = [
    "D2425-10",  # SSR (safety critical)
    "SCT-013-020",  # Current transformer
    "LRS-15-5",  # Power supply
    "6200.4210",  # IEC inlet with fuse
    "0218012.MXP",  # Fuses
    "ESP32-DEVKITC-32E",  # Main controller
]


class AvailabilityChecker:
    def __init__(self, client_id: str, client_secret: str):
        self.client_id = client_id
        self.client_secret = client_secret
        self.access_token = None
        self.session = requests.Session()

    def authenticate(self) -> None:
        """Obtain access token from Nexar API"""
        print("🔐 Authenticating with Nexar API...")

        auth_data = {
            "grant_type": "client_credentials",
            "client_id": self.client_id,
            "client_secret": self.client_secret,
        }

        try:
            response = requests.post(
                "https://identity.nexar.com/connect/token",
                data=auth_data,
                headers={"Content-Type": "application/x-www-form-urlencoded"},
            )
            response.raise_for_status()

            token_data = response.json()
            self.access_token = token_data["access_token"]

            self.session.headers.update(
                {
                    "Authorization": f"Bearer {self.access_token}",
                    "Content-Type": "application/json",
                }
            )

            print("✅ Authentication successful")

        except requests.exceptions.RequestException as e:
            print(f"❌ Authentication failed: {e}")
            sys.exit(1)

    def check_availability(self, mpn: str, manufacturer: str = None) -> dict:
        """Check availability for a specific part"""
        query = """
        query CheckAvailability($mpn: String!, $manufacturer: String) {
            supSearchMpn(q: $mpn, manufacturer: $manufacturer, limit: 3) {
                results {
                    part {
                        mpn
                        manufacturer {
                            name
                        }
                    }
                    sellers {
                        company {
                            name
                        }
                        offers {
                            inventoryLevel
                            moq
                            packaging {
                                name
                            }
                            updated
                            factoryLeadDays
                            prices {
                                quantity
                                price
                                currency
                            }
                        }
                    }
                }
            }
        }
        """

        variables = {"mpn": mpn, "manufacturer": manufacturer}

        try:
            response = self.session.post(
                NEXAR_ENDPOINT, json={"query": query, "variables": variables}
            )
            response.raise_for_status()

            data = response.json()

            if "errors" in data:
                return {"error": data["errors"]}

            results = data.get("data", {}).get("supSearchMpn", {}).get("results", [])

            # Analyze availability across all sellers
            availability_summary = {
                "mpn": mpn,
                "manufacturer": manufacturer,
                "found": len(results) > 0,
                "total_stock": 0,
                "suppliers_with_stock": 0,
                "best_lead_time": None,
                "availability_status": "Unknown",
                "suppliers": [],
            }

            for result in results:
                sellers = result.get("sellers", [])

                for seller in sellers:
                    company_name = seller.get("company", {}).get("name", "Unknown")

                    for offer in seller.get("offers", []):
                        inventory = offer.get("inventoryLevel", 0)
                        lead_time = offer.get("factoryLeadDays")
                        moq = offer.get("moq", 1)

                        if inventory > 0:
                            availability_summary["suppliers_with_stock"] += 1
                            availability_summary["total_stock"] += inventory

                            if availability_summary["best_lead_time"] is None or (
                                lead_time
                                and lead_time < availability_summary["best_lead_time"]
                            ):
                                availability_summary["best_lead_time"] = lead_time

                        availability_summary["suppliers"].append(
                            {
                                "name": company_name,
                                "inventory": inventory,
                                "moq": moq,
                                "lead_time": lead_time,
                                "updated": offer.get("updated"),
                            }
                        )

            # Determine availability status
            if availability_summary["total_stock"] == 0:
                availability_summary["availability_status"] = "Out of Stock"
            elif availability_summary["total_stock"] < 10:
                availability_summary["availability_status"] = "Low Stock"
            elif availability_summary["suppliers_with_stock"] < 2:
                availability_summary["availability_status"] = "Limited Suppliers"
            else:
                availability_summary["availability_status"] = "Available"

            return availability_summary

        except requests.exceptions.RequestException as e:
            return {"error": str(e)}

    def check_bom_availability(
        self, bom_file: str, critical_only: bool = False
    ) -> dict:
        """Check availability for components in BOM file"""
        print(f"📋 Checking availability for {bom_file}...")

        try:
            df = pd.read_csv(bom_file)
        except Exception as e:
            return {"error": f"Failed to read BOM file: {e}"}

        # Standardize column names
        df.columns = df.columns.str.strip()

        results = {
            "timestamp": datetime.now().isoformat(),
            "bom_file": bom_file,
            "critical_only": critical_only,
            "total_checked": 0,
            "out_of_stock": 0,
            "low_stock": 0,
            "limited_suppliers": 0,
            "components": [],
        }

        for idx, row in df.iterrows():
            # Get component info
            mpn_cols = [
                col
                for col in df.columns
                if "part number" in col.lower() or col.lower() in ["mpn"]
            ]
            mfg_cols = [col for col in df.columns if "manufacturer" in col.lower()]

            if not mpn_cols:
                continue

            mpn = str(row[mpn_cols[0]]).strip() if pd.notna(row[mpn_cols[0]]) else ""
            manufacturer = (
                str(row[mfg_cols[0]]).strip()
                if mfg_cols and pd.notna(row[mfg_cols[0]])
                else None
            )

            # Skip comment rows or empty MPNs
            if not mpn or mpn.startswith("#"):
                continue

            # If checking critical only, skip non-critical components
            if critical_only and mpn not in CRITICAL_COMPONENTS:
                continue

            print(f"🔍 Checking {mpn}...")

            availability = self.check_availability(mpn, manufacturer)
            results["components"].append(availability)
            results["total_checked"] += 1

            # Count issues
            status = availability.get("availability_status", "Unknown")
            if status == "Out of Stock":
                results["out_of_stock"] += 1
            elif status == "Low Stock":
                results["low_stock"] += 1
            elif status == "Limited Suppliers":
                results["limited_suppliers"] += 1

        return results


def generate_availability_report(results: dict):
    """Generate availability report"""
    report = []
    report.append("## 📦 Component Availability Report")
    report.append(f"**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}")
    report.append("")

    for bom_file, data in results.items():
        if "error" in data:
            report.append(f"### ❌ {bom_file} - Check Failed")
            report.append(f"**Error**: {data['error']}")
            continue

        report.append(f"### 📋 {bom_file}")
        report.append("")

        total_checked = data.get("total_checked", 0)
        out_of_stock = data.get("out_of_stock", 0)
        low_stock = data.get("low_stock", 0)
        limited_suppliers = data.get("limited_suppliers", 0)

        report.append("**Summary:**")
        report.append(f"- 📊 Components Checked: {total_checked}")
        report.append(f"- ❌ Out of Stock: {out_of_stock}")
        report.append(f"- ⚠️ Low Stock (<10 units): {low_stock}")
        report.append(f"- 🏪 Limited Suppliers (<2): {limited_suppliers}")
        report.append("")

        # Critical issues
        critical_issues = [
            c
            for c in data.get("components", [])
            if c.get("availability_status") in ["Out of Stock", "Low Stock"]
        ]

        if critical_issues:
            report.append("**🚨 Critical Availability Issues:**")
            report.append("")
            report.append(
                "| Component | Manufacturer | Status | Total Stock | Suppliers |"
            )
            report.append(
                "|-----------|--------------|--------|-------------|-----------|"
            )

            for component in critical_issues:
                mpn = component.get("mpn", "Unknown")
                mfg = component.get("manufacturer", "Unknown")
                status = component.get("availability_status", "Unknown")
                stock = component.get("total_stock", 0)
                suppliers = component.get("suppliers_with_stock", 0)

                status_emoji = "❌" if status == "Out of Stock" else "⚠️"
                report.append(
                    f"| {mpn} | {mfg} | {status_emoji} {status} | {stock} | {suppliers} |"
                )

            report.append("")

    # Write report
    with open("availability_report.md", "w") as f:
        f.write("\n".join(report))

    print("✅ Availability report generated: availability_report.md")


def main():
    parser = argparse.ArgumentParser(description="Check component availability")
    parser.add_argument(
        "--critical-only",
        type=bool,
        default=True,
        help="Check only critical components",
    )
    parser.add_argument(
        "--bom-files",
        nargs="*",
        default=["BOM_BUDGET.csv", "BOM_OCTOPART.csv"],
        help="BOM files to check",
    )

    args = parser.parse_args()

    # Get credentials
    client_id = os.getenv("NEXAR_CLIENT_ID")
    client_secret = os.getenv("NEXAR_CLIENT_SECRET")

    if not client_id or not client_secret:
        print("❌ Missing Nexar API credentials")
        sys.exit(1)

    checker = AvailabilityChecker(client_id, client_secret)
    checker.authenticate()

    all_results = {}

    for bom_file in args.bom_files:
        if os.path.exists(bom_file):
            results = checker.check_bom_availability(bom_file, args.critical_only)
            all_results[bom_file] = results

    # Save results
    with open("availability_results.json", "w") as f:
        json.dump(all_results, f, indent=2)

    # Generate report
    generate_availability_report(all_results)

    # Check if we have availability issues for GitHub Actions
    has_issues = any(
        data.get("out_of_stock", 0) > 0 or data.get("low_stock", 0) > 0
        for data in all_results.values()
        if "error" not in data
    )

    if "GITHUB_OUTPUT" in os.environ:
        with open(os.environ["GITHUB_OUTPUT"], "a") as f:
            f.write(f"unavailable_components={'true' if has_issues else 'false'}\n")

    print(f"🎯 Availability check complete - Issues detected: {has_issues}")


if __name__ == "__main__":
    main()
