#!/usr/bin/env python3
"""
Nexar API BOM Validation Script for GitHub Actions
Validates parts and updates pricing using Nexar GraphQL API
"""

import os
import json
import argparse
import pandas as pd
import requests
from typing import Dict, List, Tuple, Optional
import sys
import time
import random
from datetime import datetime
from pathlib import Path

# Path configuration
REPO_ROOT = Path(__file__).parent.parent.parent
GITHUB_DIR = Path(__file__).parent.parent

# Nexar API Configuration
NEXAR_ENDPOINT = "https://api.nexar.com/graphql"


class NexarAPIError(Exception):
    """Custom exception for Nexar API errors"""

    pass


class NexarRateLimitError(NexarAPIError):
    """Exception for rate limit exceeded errors"""

    pass


class NexarQuotaExceededError(NexarAPIError):
    """Exception for quota exceeded errors"""

    pass


def exponential_backoff(
    attempt: int, base_delay: float = 1.0, max_delay: float = 60.0
) -> float:
    """Calculate exponential backoff delay with jitter"""
    delay = min(base_delay * (2**attempt), max_delay)
    # Add jitter to prevent thundering herd
    jitter = random.uniform(0.1, 0.5) * delay
    return delay + jitter


def retry_with_backoff(
    func,
    max_retries: int = 3,
    base_delay: float = 1.0,
    backoff_exceptions: tuple = (
        requests.exceptions.RequestException,
        NexarRateLimitError,
    ),
    fatal_exceptions: tuple = (NexarQuotaExceededError,),
):
    """Decorator for retrying functions with exponential backoff"""

    def wrapper(*args, **kwargs):
        last_exception = None

        for attempt in range(max_retries + 1):
            try:
                return func(*args, **kwargs)
            except fatal_exceptions as e:
                # Don't retry fatal exceptions like quota exceeded
                print(f"🚫 Fatal error (no retry): {e}")
                raise
            except backoff_exceptions as e:
                last_exception = e

                if attempt < max_retries:
                    delay = exponential_backoff(attempt, base_delay)
                    print(
                        f"⏳ Retry {attempt + 1}/{max_retries} after {delay:.1f}s: {e}"
                    )
                    time.sleep(delay)
                else:
                    print(f"❌ Max retries ({max_retries}) exceeded for: {e}")
            except Exception as e:
                # Unexpected errors - don't retry
                print(f"💥 Unexpected error (no retry): {e}")
                raise

        # If we get here, all retries failed
        if last_exception:
            raise last_exception

    return wrapper


class NexarValidator:
    def __init__(
        self,
        client_id: str,
        client_secret: str,
        supplier_prefs_file: str = None,
    ):
        self.client_id = client_id
        self.client_secret = client_secret
        self.access_token = None
        self.session = requests.Session()

        # Set default supplier preferences file path
        if supplier_prefs_file is None:
            supplier_prefs_file = str(GITHUB_DIR / "supplier_preferences.json")

        self.supplier_preferences = self.load_supplier_preferences(supplier_prefs_file)

    def load_supplier_preferences(self, prefs_file: str) -> Dict:
        """Load supplier preferences from JSON file"""
        try:
            if os.path.exists(prefs_file):
                with open(prefs_file, "r") as f:
                    return json.load(f)
            else:
                print(f"⚠️  Supplier preferences file not found: {prefs_file}")
                return self.get_default_preferences()
        except Exception as e:
            print(f"⚠️  Error loading supplier preferences: {e}")
            return self.get_default_preferences()

    def get_default_preferences(self) -> Dict:
        """Return default supplier preferences if file not found"""
        return {
            "preferred_suppliers": {
                "tier_1": ["DigiKey", "Mouser", "Arrow Electronics", "Avnet"],
                "tier_2": ["Newark", "RS Components", "Future Electronics"],
                "specialty": ["Adafruit", "SparkFun"],
            },
            "moq_requirements": {"max_moq": 1},
            "supplier_scoring": {
                "tier_1_bonus": 100,
                "tier_2_bonus": 50,
                "specialty_bonus": 75,
                "moq_1_bonus": 200,
                "price_weight": 0.5,
                "supplier_tier_weight": 0.2,
            },
        }

    @retry_with_backoff
    def authenticate(self) -> None:
        """Obtain access token from Nexar API with retry logic"""
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
                timeout=30,  # Add timeout
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
            if "401" in str(e) or "403" in str(e):
                raise NexarAPIError(f"Authentication failed - check credentials: {e}")
            else:
                raise NexarAPIError(f"Authentication request failed: {e}")

    @retry_with_backoff
    def search_parts(self, mpn: str, manufacturer: str = None) -> List[Dict]:
        """Search for parts using Nexar API with error handling and backoff"""
        # Query pattern from official mpn_pricing_to_csv.py example
        query = """
        query SearchParts($queries: [SupPartMatchQuery!]!) {
            supMultiMatch(queries: $queries) {
                hits
                parts {
                    mpn
                    name
                    id
                    manufacturer {
                        name
                    }
                    category {
                        name
                    }
                    shortDescription
                    avgAvail
                    medianPrice1000 {
                        price
                        currency
                    }
                    sellers {
                        country
                        company {
                            name
                            homepageUrl
                        }
                        offers {
                            clickUrl
                            inventoryLevel
                            moq
                            packaging
                            sku
                            updated
                            prices {
                                currency
                                price
                                quantity
                            }
                        }
                    }
                }
            }
        }
        """

        variables = {"queries": [{"mpn": mpn, "limit": 3, "start": 0}]}

        try:
            response = self.session.post(
                NEXAR_ENDPOINT,
                json={"query": query, "variables": variables},
                timeout=45,  # Longer timeout for complex queries
            )
            response.raise_for_status()

            data = response.json()

            if "errors" in data:
                errors = data["errors"]
                print(f"⚠️  GraphQL errors for {mpn}: {errors}")

                # Check for specific error types
                for error in errors:
                    error_msg = error.get("message", "").lower()

                    # Check for quota exceeded
                    if (
                        "exceeded your part limit" in error_msg
                        or "upgrade your plan" in error_msg
                    ):
                        print(f"💳 Quota exceeded for part search: {mpn}")
                        raise NexarQuotaExceededError(
                            f"Nexar part limit exceeded: {error.get('message')}"
                        )

                    # Check for rate limiting
                    elif "rate limit" in error_msg or "too many requests" in error_msg:
                        print(f"🐌 Rate limited for part search: {mpn}")
                        raise NexarRateLimitError(
                            f"Rate limit exceeded: {error.get('message')}"
                        )

                    # Check for authentication issues
                    elif "unauthorized" in error_msg or "forbidden" in error_msg:
                        print(f"🔒 Authentication error for part search: {mpn}")
                        raise NexarAPIError(
                            f"Authentication error: {error.get('message')}"
                        )

                return []

            # Extract parts from supMultiMatch response
            matches = data.get("data", {}).get("supMultiMatch", [])
            if matches:
                parts = matches[0].get("parts", [])
                # Filter by manufacturer if specified
                if manufacturer:
                    parts = [
                        p
                        for p in parts
                        if manufacturer.lower()
                        in p.get("manufacturer", {}).get("name", "").lower()
                    ]
                return parts
            return []

        except requests.exceptions.Timeout:
            print(f"⏰ Timeout searching for {mpn}")
            raise NexarRateLimitError(f"Request timeout for {mpn}")
        except requests.exceptions.ConnectionError:
            print(f"🌐 Connection error searching for {mpn}")
            raise NexarRateLimitError(f"Connection error for {mpn}")
        except requests.exceptions.HTTPError as e:
            if e.response.status_code == 429:
                print(f"🐌 HTTP 429 (Too Many Requests) for {mpn}")
                raise NexarRateLimitError(f"HTTP 429 for {mpn}")
            elif e.response.status_code in [401, 403]:
                print(f"🔒 HTTP {e.response.status_code} (Auth Error) for {mpn}")
                raise NexarAPIError(f"Authentication error for {mpn}")
            elif e.response.status_code >= 500:
                print(f"🔥 HTTP {e.response.status_code} (Server Error) for {mpn}")
                raise NexarRateLimitError(f"Server error for {mpn}")
            else:
                print(f"❌ HTTP {e.response.status_code} error for {mpn}: {e}")
                raise
        except requests.exceptions.RequestException as e:
            print(f"❌ Request failed for {mpn}: {e}")
            raise

    def score_supplier(
        self, supplier_name: str, offer: Dict, base_price: float
    ) -> float:
        """Score a supplier based on preferences, MOQ, and pricing"""
        score = 0
        prefs = self.supplier_preferences

        # Base price scoring (lower price = higher score)
        if base_price > 0:
            # Normalize price scoring (arbitrary scale)
            price_score = max(0, 100 - (base_price * 10))
            score += price_score * prefs.get("supplier_scoring", {}).get(
                "price_weight", 0.5
            )

        # Supplier tier scoring
        supplier_prefs = prefs.get("preferred_suppliers", {})
        if supplier_name in supplier_prefs.get("tier_1", []):
            score += prefs.get("supplier_scoring", {}).get("tier_1_bonus", 100)
        elif supplier_name in supplier_prefs.get("tier_2", []):
            score += prefs.get("supplier_scoring", {}).get("tier_2_bonus", 50)
        elif supplier_name in supplier_prefs.get("specialty", []):
            score += prefs.get("supplier_scoring", {}).get("specialty_bonus", 75)

        # MOQ scoring - heavily favor MOQ = 1
        moq = offer.get("moq", 1) or 1  # Handle None MOQ
        if moq == 1:
            score += prefs.get("supplier_scoring", {}).get("moq_1_bonus", 200)
        elif moq <= prefs.get("moq_requirements", {}).get("max_moq", 1):
            score += 50  # Some bonus for low MOQ
        else:
            score -= 100  # Penalty for high MOQ

        # Stock availability scoring
        stock = offer.get("inventoryLevel", 0)
        if stock > 100:
            score += 20
        elif stock > 10:
            score += 10
        elif stock > 0:
            score += 5
        else:
            score -= 50  # Penalty for no stock

        return score

    def filter_and_rank_suppliers(self, part: Dict, quantity: int = 1) -> List[Dict]:
        """Filter suppliers by MOQ and rank by preferences"""
        max_moq = self.supplier_preferences.get("moq_requirements", {}).get(
            "max_moq", 1
        )
        avoid_suppliers = self.supplier_preferences.get("preferred_suppliers", {}).get(
            "avoid", []
        )

        suppliers_with_scores = []

        sellers = part.get("sellers", [])
        for seller in sellers:
            company_name = seller.get("company", {}).get("name", "Unknown")

            # Skip avoided suppliers
            if company_name in avoid_suppliers:
                continue

            for offer in seller.get("offers", []):
                moq = offer.get("moq", 1) or 1
                stock = offer.get("inventoryLevel", 0)

                # Filter by MOQ requirement
                if moq > max_moq:
                    # Check if savings justify higher MOQ
                    allow_higher = self.supplier_preferences.get(
                        "moq_requirements", {}
                    ).get("allow_higher_moq_if_significant_savings", False)
                    if not allow_higher:
                        continue

                # Filter by stock availability
                if stock < quantity:
                    continue

                # Get best price for this offer
                prices = offer.get("prices", [])
                best_price = None

                for price_tier in sorted(prices, key=lambda p: p.get("quantity", 0)):
                    if price_tier.get("quantity", 0) <= max(quantity, moq):
                        best_price = price_tier.get("price")
                        currency = price_tier.get("currency", "USD")
                        break

                if best_price is not None:
                    score = self.score_supplier(company_name, offer, best_price)

                    suppliers_with_scores.append(
                        {
                            "name": company_name,
                            "price": best_price,
                            "currency": currency,
                            "stock": stock,
                            "moq": moq,
                            "score": score,
                            "country": seller.get("country", "Unknown"),
                            "homepage": seller.get("company", {}).get(
                                "homepageUrl", ""
                            ),
                            "offer_details": offer,
                        }
                    )

        # Sort by score (highest first)
        suppliers_with_scores.sort(key=lambda x: x["score"], reverse=True)

        return suppliers_with_scores

    def get_best_price(
        self, part: Dict, quantity: int = 1
    ) -> Optional[Tuple[float, str, str]]:
        """Get the best price for a given quantity from preferred suppliers with MOQ=1"""
        ranked_suppliers = self.filter_and_rank_suppliers(part, quantity)

        if ranked_suppliers:
            best_supplier = ranked_suppliers[0]
            return (
                best_supplier["price"],
                best_supplier["name"],
                best_supplier["currency"],
            )

        return None

    def validate_bom(self, bom_file: str) -> Dict:
        """Validate entire BOM file with rate limiting and error recovery"""
        print(f"📋 Validating BOM file: {bom_file}")

        try:
            df = pd.read_csv(bom_file)
        except Exception as e:
            raise NexarAPIError(f"Failed to read BOM file {bom_file}: {e}")

        # Standardize column names
        df.columns = df.columns.str.strip()
        column_mapping = {
            "Manufacturer Part Number": "mpn",
            "Manufacturer": "manufacturer",
            "Description": "description",
            "Quantity": "quantity",
            "Unit Price": "current_price",
            "Distributor": "distributor",
        }

        # Rename columns if they exist
        for old_col, new_col in column_mapping.items():
            if old_col in df.columns:
                df = df.rename(columns={old_col: new_col})

        validation_results = {
            "timestamp": datetime.now().isoformat(),
            "bom_file": bom_file,
            "total_components": len(df),
            "validated_components": 0,
            "pricing_updates": 0,
            "errors": 0,
            "quota_exceeded": False,
            "rate_limited": False,
            "components": [],
        }

        processed_count = 0
        quota_exceeded = False
        consecutive_failures = 0
        max_consecutive_failures = 5

        for idx, row in df.iterrows():
            # Skip comment rows
            if pd.isna(row.get("mpn")) or str(row.get("mpn")).startswith("#"):
                continue

            mpn = str(row.get("mpn", "")).strip()
            manufacturer = (
                str(row.get("manufacturer", "")).strip()
                if pd.notna(row.get("manufacturer"))
                else None
            )
            quantity = (
                int(row.get("quantity", 1)) if pd.notna(row.get("quantity")) else 1
            )
            current_price = (
                float(row.get("current_price", 0))
                if pd.notna(row.get("current_price"))
                else 0
            )

            if not mpn:
                continue

            # Check if quota exceeded earlier
            if quota_exceeded:
                print(f"⏭️  Skipping {mpn} - quota exceeded")
                component_result = {
                    "mpn": mpn,
                    "manufacturer": manufacturer,
                    "quantity": quantity,
                    "current_price": current_price,
                    "nexar_found": False,
                    "updated_price": None,
                    "price_change_percent": 0,
                    "availability": "Quota Exceeded",
                    "suppliers": [],
                    "error": "Nexar API quota exceeded",
                }
                validation_results["components"].append(component_result)
                continue

            print(f"🔍 Validating {mpn} ({manufacturer})...")

            component_result = {
                "mpn": mpn,
                "manufacturer": manufacturer,
                "quantity": quantity,
                "current_price": current_price,
                "nexar_found": False,
                "updated_price": None,
                "price_change_percent": 0,
                "availability": "Unknown",
                "suppliers": [],
            }

            try:
                # Add inter-request delay to be respectful
                if processed_count > 0:
                    time.sleep(0.5)  # 500ms between requests

                parts = self.search_parts(mpn, manufacturer)

                # Reset consecutive failures counter on success
                consecutive_failures = 0

                if parts:
                    component_result["nexar_found"] = True
                    validation_results["validated_components"] += 1

                    # Use first matching part
                    part = parts[0]

                    # Get availability info
                    avg_avail = part.get("avgAvail", 0)
                    if avg_avail > 0:
                        component_result["availability"] = f"In Stock ({avg_avail} avg)"

                    # Get pricing info from ranked suppliers
                    ranked_suppliers = self.filter_and_rank_suppliers(part, quantity)

                    if ranked_suppliers:
                        best_supplier = ranked_suppliers[0]
                        component_result["updated_price"] = best_supplier["price"]
                        component_result["availability"] = (
                            f"In Stock at {best_supplier['name']} (MOQ: {best_supplier['moq']})"
                        )

                        # Add top ranked suppliers to results
                        for supplier in ranked_suppliers[:5]:  # Top 5 suppliers
                            component_result["suppliers"].append(
                                {
                                    "name": supplier["name"],
                                    "price": supplier["price"],
                                    "currency": supplier["currency"],
                                    "stock": supplier["stock"],
                                    "moq": supplier["moq"],
                                    "score": supplier["score"],
                                    "country": supplier["country"],
                                    "homepage": supplier["homepage"],
                                }
                            )

                        # Calculate price change
                        if current_price > 0:
                            change_percent = (
                                (best_supplier["price"] - current_price) / current_price
                            ) * 100
                            component_result["price_change_percent"] = round(
                                change_percent, 2
                            )

                            if abs(change_percent) > 1:  # >1% change
                                validation_results["pricing_updates"] += 1

                    # Fallback to median price if no suitable suppliers found
                    elif part.get("medianPrice1000"):
                        median_price_info = part["medianPrice1000"]
                        component_result["updated_price"] = median_price_info.get(
                            "price"
                        )
                        component_result["availability"] = (
                            "Median Price Available (No MOQ=1 suppliers found)"
                        )
                        component_result["suppliers"].append(
                            {
                                "name": "Market Median",
                                "price": median_price_info.get("price"),
                                "currency": median_price_info.get("currency", "USD"),
                                "note": "Fallback pricing - check MOQ requirements",
                            }
                        )
                else:
                    print(f"⚠️  No results found for {mpn}")
                    component_result["availability"] = "Not Found"

            except NexarQuotaExceededError as e:
                print(f"💳 Quota exceeded at {mpn}: {e}")
                validation_results["quota_exceeded"] = True
                quota_exceeded = True
                component_result["error"] = str(e)
                component_result["availability"] = "Quota Exceeded"

            except NexarRateLimitError as e:
                print(f"🐌 Rate limited at {mpn}: {e}")
                validation_results["rate_limited"] = True
                validation_results["errors"] += 1
                component_result["error"] = str(e)
                component_result["availability"] = "Rate Limited"
                consecutive_failures += 1

                # If too many consecutive failures, take a longer break
                if consecutive_failures >= max_consecutive_failures:
                    print(
                        f"😴 Taking extended break after {consecutive_failures} consecutive failures..."
                    )
                    time.sleep(30)  # 30 second break
                    consecutive_failures = 0

            except Exception as e:
                print(f"❌ Error validating {mpn}: {e}")
                validation_results["errors"] += 1
                component_result["error"] = str(e)
                consecutive_failures += 1

            validation_results["components"].append(component_result)
            processed_count += 1

        return validation_results


def main():
    parser = argparse.ArgumentParser(description="Validate BOM pricing with Nexar API")
    parser.add_argument(
        "--bom-files",
        nargs="*",
        default=[
            str(REPO_ROOT / "BOM_BUDGET.csv"),
            str(REPO_ROOT / "BOM_OCTOPART.csv"),
        ],
        help="BOM files to validate",
    )
    parser.add_argument(
        "--supplier-prefs",
        default=str(GITHUB_DIR / "supplier_preferences.json"),
        help="Supplier preferences JSON file",
    )
    parser.add_argument(
        "--output-format",
        choices=["json", "github-actions"],
        default="json",
        help="Output format",
    )

    args = parser.parse_args()

    # Get credentials from environment
    client_id = os.getenv("NEXAR_CLIENT_ID")
    client_secret = os.getenv("NEXAR_CLIENT_SECRET")

    if not client_id or not client_secret:
        print("❌ Missing Nexar API credentials")
        print("Set NEXAR_CLIENT_ID and NEXAR_CLIENT_SECRET environment variables")
        sys.exit(1)

    try:
        validator = NexarValidator(client_id, client_secret, args.supplier_prefs)
        validator.authenticate()

        # Print supplier preferences summary
        prefs = validator.supplier_preferences
        print("🏢 Using supplier preferences:")
        print(
            f"   Tier 1: {', '.join(prefs.get('preferred_suppliers', {}).get('tier_1', []))}"
        )
        print(f"   Max MOQ: {prefs.get('moq_requirements', {}).get('max_moq', 1)}")
        print(
            f"   MOQ=1 bonus: {prefs.get('supplier_scoring', {}).get('moq_1_bonus', 200)} points"
        )

        all_results = {}

        for bom_file in args.bom_files:
            if os.path.exists(bom_file):
                results = validator.validate_bom(bom_file)
                all_results[bom_file] = results
            else:
                print(f"⚠️  BOM file not found: {bom_file}")

        # Save results
        with open("validation_results.json", "w") as f:
            json.dump(all_results, f, indent=2)

        # Generate summary for GitHub Actions
        if args.output_format == "github-actions":
            total_components = sum(r["total_components"] for r in all_results.values())
            total_validated = sum(
                r["validated_components"] for r in all_results.values()
            )
            total_pricing_updates = sum(
                r["pricing_updates"] for r in all_results.values()
            )
            total_errors = sum(r["errors"] for r in all_results.values())

            print("✅ Validation complete:")
            print(f"   📊 Total components: {total_components}")
            print(f"   ✅ Validated: {total_validated}")
            print(f"   💰 Pricing updates: {total_pricing_updates}")
            print(f"   ❌ Errors: {total_errors}")

            # Set GitHub Actions outputs
            if "GITHUB_OUTPUT" in os.environ:
                with open(os.environ["GITHUB_OUTPUT"], "a") as f:
                    f.write(f"validated_components={total_validated}\n")
                    f.write(f"pricing_updates={total_pricing_updates}\n")
                    f.write(f"validation_errors={total_errors}\n")

    except NexarAPIError as e:
        print(f"❌ Nexar API Error: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
