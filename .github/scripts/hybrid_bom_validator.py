#!/usr/bin/env python3
"""
Hybrid BOM Validation using both Nexar and Mouser APIs
Automatically falls back to Mouser when Nexar quota is exceeded

This script provides the best of both worlds:
- Nexar: Comprehensive multi-supplier data
- Mouser: High quotas and detailed pricing

Usage:
    python hybrid_bom_validator.py --bom-files BOM_BUDGET.csv BOM_OCTOPART.csv
"""

import os
import json
import time
import logging
from typing import Dict, List, Optional
from datetime import datetime
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

# Import our custom API clients
try:
    from mouser_api import MouserAPIClient, MouserBOMValidator, MouserAPIError
except ImportError:
    MouserAPIClient = MouserBOMValidator = MouserAPIError = None

try:
    from nexar_validation import (
        NexarValidator,
        NexarQuotaExceededError,
        NexarRateLimitError,
    )
except ImportError:
    NexarValidator = NexarQuotaExceededError = NexarRateLimitError = None

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


class HybridBOMValidator:
    """BOM validator that uses both Nexar and Mouser APIs intelligently"""

    def __init__(
        self,
        nexar_client_id: str = None,
        nexar_client_secret: str = None,
        mouser_api_key: str = None,
    ):
        """Initialize hybrid validator with both API clients"""
        self.nexar_validator = None
        self.mouser_validator = None
        self.validation_strategy = "hybrid"  # hybrid, nexar-only, mouser-only

        # Initialize Nexar if credentials available
        if NexarValidator and (nexar_client_id or os.getenv("NEXAR_CLIENT_ID")):
            try:
                self.nexar_validator = NexarValidator()
                logger.info("✅ Nexar API client initialized")
            except Exception as e:
                logger.warning(f"⚠️ Nexar API initialization failed: {e}")

        # Initialize Mouser if API key available
        if MouserBOMValidator and (mouser_api_key or os.getenv("MOUSER_API_KEY")):
            try:
                self.mouser_validator = MouserBOMValidator(mouser_api_key)
                logger.info("✅ Mouser API client initialized")
            except Exception as e:
                logger.warning(f"⚠️ Mouser API initialization failed: {e}")

        # Determine optimal strategy
        if self.nexar_validator and self.mouser_validator:
            self.validation_strategy = "hybrid"
            logger.info("🔄 Using hybrid validation strategy (Nexar + Mouser fallback)")
        elif self.nexar_validator:
            self.validation_strategy = "nexar-only"
            logger.info("🔍 Using Nexar-only validation strategy")
        elif self.mouser_validator:
            self.validation_strategy = "mouser-only"
            logger.info("🛒 Using Mouser-only validation strategy")
        else:
            raise ValueError(
                "No API credentials provided. Set NEXAR_CLIENT_ID/SECRET or MOUSER_API_KEY"
            )

    def validate_component(
        self, mpn: str, manufacturer: str, quantity: int = 1, priority: str = "normal"
    ) -> Dict:
        """Validate a single component using the best available strategy"""
        logger.info(f"🔍 Validating {mpn} ({manufacturer}) - Priority: {priority}")

        result = {
            "mpn": mpn,
            "manufacturer": manufacturer,
            "quantity": quantity,
            "priority": priority,
            "found": False,
            "sources": [],
            "pricing": None,
            "availability": None,
            "best_source": None,
            "validation_timestamp": datetime.now().isoformat(),
            "api_used": None,
            "errors": [],
        }

        # Strategy 1: Try Nexar first for comprehensive multi-supplier data
        if self.validation_strategy in ["hybrid", "nexar-only"]:
            try:
                nexar_result = self._validate_with_nexar(mpn, manufacturer)
                if nexar_result and nexar_result.get("found"):
                    result.update(nexar_result)
                    result["api_used"] = "nexar"
                    logger.info(f"✅ Found {mpn} via Nexar")
                    return result
                elif nexar_result and nexar_result.get("errors"):
                    result["errors"].extend(nexar_result["errors"])

            except NexarQuotaExceededError as e:
                logger.warning(f"💳 Nexar quota exceeded for {mpn}: {e}")
                result["errors"].append(f"Nexar quota exceeded: {e}")
                # Continue to Mouser fallback
            except (NexarRateLimitError, Exception) as e:
                logger.warning(f"⚠️ Nexar error for {mpn}: {e}")
                result["errors"].append(f"Nexar error: {e}")
                # Continue to Mouser fallback

        # Strategy 2: Try Mouser as fallback or primary
        if self.validation_strategy in ["hybrid", "mouser-only"]:
            try:
                mouser_result = self._validate_with_mouser(mpn, manufacturer, quantity)
                if mouser_result and mouser_result.get("found"):
                    # If we already have Nexar data, merge; otherwise use Mouser
                    if result.get("found"):
                        # Merge Mouser pricing with existing Nexar data
                        result["sources"].append(
                            {"supplier": "Mouser", "data": mouser_result}
                        )
                        logger.info(f"📈 Added Mouser pricing for {mpn}")
                    else:
                        # Use Mouser as primary source
                        result.update(mouser_result)
                        result["api_used"] = "mouser"
                        logger.info(f"✅ Found {mpn} via Mouser")
                    return result
                elif mouser_result and mouser_result.get("errors"):
                    result["errors"].extend(mouser_result["errors"])

            except MouserAPIError as e:
                logger.warning(f"⚠️ Mouser error for {mpn}: {e}")
                result["errors"].append(f"Mouser error: {e}")

        # Component not found in any API
        if not result["found"]:
            logger.warning(f"❌ Component not found: {mpn}")
            result["api_used"] = f"failed_{self.validation_strategy}"

        return result

    def _validate_with_nexar(self, mpn: str, manufacturer: str) -> Optional[Dict]:
        """Validate component using Nexar API"""
        if not self.nexar_validator:
            return None

        try:
            # Use existing Nexar validation logic
            parts = self.nexar_validator.search_parts(mpn, manufacturer)

            if parts:
                # Process Nexar results into standardized format
                best_part = parts[0]

                return {
                    "found": True,
                    "sources": [
                        {
                            "supplier": "Multi-supplier (Nexar)",
                            "part_id": best_part.get("id"),
                            "description": best_part.get("shortDescription", ""),
                            "availability": best_part.get("avgAvail", 0),
                            "median_price": best_part.get("medianPrice1000", {}),
                            "sellers": best_part.get("sellers", []),
                        }
                    ],
                    "pricing": self._extract_nexar_pricing(best_part),
                    "availability": best_part.get("avgAvail", 0),
                }

            return {"found": False}

        except Exception as e:
            return {"found": False, "errors": [str(e)]}

    def _validate_with_mouser(
        self, mpn: str, manufacturer: str, quantity: int
    ) -> Optional[Dict]:
        """Validate component using Mouser API"""
        if not self.mouser_validator:
            return None

        try:
            # Search Mouser for the part
            parts = self.mouser_validator.client.search_part_number(mpn, manufacturer)

            if parts:
                best_part = parts[0]
                pricing = self.mouser_validator.client.get_best_price(
                    best_part, quantity
                )

                return {
                    "found": True,
                    "sources": [
                        {
                            "supplier": "Mouser",
                            "mouser_part": best_part.mouser_part_number,
                            "description": best_part.description,
                            "availability": best_part.availability,
                            "lead_time": best_part.lead_time,
                            "lifecycle": best_part.lifecycle_status,
                            "datasheet": best_part.data_sheet_url,
                            "product_url": best_part.product_detail_url,
                        }
                    ],
                    "pricing": pricing,
                    "availability": best_part.availability,
                }

            return {"found": False}

        except Exception as e:
            return {"found": False, "errors": [str(e)]}

    def _extract_nexar_pricing(self, nexar_part: Dict) -> Optional[Dict]:
        """Extract pricing information from Nexar part data"""
        try:
            median_price = nexar_part.get("medianPrice1000", {})
            if median_price:
                return {
                    "quantity": 1000,
                    "unit_price": median_price.get("price", 0),
                    "currency": median_price.get("currency", "USD"),
                    "note": "Median price for 1000 units",
                }

            # Try to get pricing from sellers
            sellers = nexar_part.get("sellers", [])
            for seller in sellers:
                offers = seller.get("offers", [])
                for offer in offers:
                    prices = offer.get("prices", [])
                    if prices:
                        price = prices[0]  # Take first price break
                        return {
                            "quantity": price.get("quantity", 1),
                            "unit_price": price.get("price", 0),
                            "currency": price.get("currency", "USD"),
                            "supplier": seller.get("company", {}).get(
                                "name", "Unknown"
                            ),
                        }

        except Exception as e:
            logger.warning(f"Error extracting Nexar pricing: {e}")

        return None

    def validate_bom_file(
        self, bom_file: str, priority_components: List[str] = None
    ) -> Dict:
        """Validate entire BOM file with intelligent API usage"""
        logger.info(f"📋 Starting hybrid validation of {bom_file}")

        # Load supplier preferences for component prioritization
        try:
            with open(".github/supplier_preferences.json", "r") as f:
                preferences = json.load(f)
                safety_critical = preferences.get("safety_critical_components", [])
        except FileNotFoundError:
            safety_critical = []

        priority_components = priority_components or safety_critical

        try:
            # Use CSV parsing without pandas to avoid dependency
            import csv

            components = []
            with open(bom_file, "r") as f:
                reader = csv.DictReader(f)
                for row in reader:
                    components.append(row)

            results = {
                "bom_file": bom_file,
                "validation_strategy": self.validation_strategy,
                "total_components": len(components),
                "validated_components": 0,
                "found_components": 0,
                "total_cost": 0.0,
                "components": [],
                "api_usage": {
                    "nexar_calls": 0,
                    "mouser_calls": 0,
                    "nexar_quota_exceeded": False,
                    "errors": [],
                },
                "validation_timestamp": datetime.now().isoformat(),
            }

            # Process safety-critical components first
            all_components = []
            priority_mpns = set(priority_components)

            for component in components:
                mpn = component.get("Manufacturer Part Number", "")
                manufacturer = component.get("Manufacturer", "")
                quantity = int(component.get("Quantity", 1))

                priority = "high" if mpn in priority_mpns else "normal"
                all_components.append(
                    (component, mpn, manufacturer, quantity, priority)
                )

            # Sort by priority (high priority first)
            all_components.sort(key=lambda x: x[4] == "high", reverse=True)

            for component, mpn, manufacturer, quantity, priority in all_components:
                try:
                    component_result = self.validate_component(
                        mpn, manufacturer, quantity, priority
                    )

                    if component_result["found"]:
                        results["found_components"] += 1
                        if component_result.get("pricing"):
                            results["total_cost"] += component_result["pricing"].get(
                                "total_price", 0
                            )

                    results["components"].append(component_result)
                    results["validated_components"] += 1

                    # Track API usage
                    if component_result["api_used"] == "nexar":
                        results["api_usage"]["nexar_calls"] += 1
                    elif component_result["api_used"] == "mouser":
                        results["api_usage"]["mouser_calls"] += 1

                    if "quota exceeded" in str(component_result.get("errors", [])):
                        results["api_usage"]["nexar_quota_exceeded"] = True

                    # Be respectful with API calls
                    time.sleep(0.2)

                except Exception as e:
                    logger.error(f"❌ Error validating {mpn}: {e}")
                    results["api_usage"]["errors"].append(f"{mpn}: {e}")

            # Calculate final statistics
            success_rate = (
                results["found_components"] / results["total_components"]
            ) * 100

            logger.info("✅ Validation complete:")
            logger.info(f"   Strategy: {self.validation_strategy}")
            logger.info(f"   Success rate: {success_rate:.1f}%")
            logger.info(f"   Total cost: ${results['total_cost']:.2f}")
            logger.info(
                f"   API calls: Nexar={results['api_usage']['nexar_calls']}, Mouser={results['api_usage']['mouser_calls']}"
            )

            return results

        except Exception as e:
            logger.error(f"❌ BOM validation failed: {e}")
            return {"error": str(e)}


def main():
    """Main CLI interface"""
    import argparse

    parser = argparse.ArgumentParser(
        description="Hybrid BOM validation using Nexar and Mouser APIs"
    )
    parser.add_argument(
        "--bom-files", nargs="+", required=True, help="BOM files to validate"
    )
    parser.add_argument("--output-dir", default=".", help="Output directory")
    parser.add_argument("--nexar-client-id", help="Nexar client ID")
    parser.add_argument("--nexar-client-secret", help="Nexar client secret")
    parser.add_argument("--mouser-api-key", help="Mouser API key")
    parser.add_argument(
        "--priority-components", nargs="*", help="High priority component MPNs"
    )

    args = parser.parse_args()

    try:
        validator = HybridBOMValidator(
            nexar_client_id=args.nexar_client_id,
            nexar_client_secret=args.nexar_client_secret,
            mouser_api_key=args.mouser_api_key,
        )

        for bom_file in args.bom_files:
            results = validator.validate_bom_file(bom_file, args.priority_components)

            if "error" not in results:
                # Save results
                output_file = os.path.join(
                    args.output_dir,
                    f"hybrid_validation_{os.path.basename(bom_file).replace('.csv', '')}.json",
                )

                with open(output_file, "w") as f:
                    json.dump(results, f, indent=2)

                logger.info(f"💾 Results saved to {output_file}")

                # Print summary
                print(f"\n📊 Summary for {bom_file}:")
                print(f"   Strategy: {results['validation_strategy']}")
                print(f"   Total: {results['total_components']}")
                print(f"   Found: {results['found_components']}")
                print(
                    f"   Success: {(results['found_components'] / results['total_components']) * 100:.1f}%"
                )
                print(f"   Cost: ${results['total_cost']:.2f}")
                print(f"   Nexar calls: {results['api_usage']['nexar_calls']}")
                print(f"   Mouser calls: {results['api_usage']['mouser_calls']}")

        return 0

    except Exception as e:
        logger.error(f"❌ Validation failed: {e}")
        return 1


if __name__ == "__main__":
    exit(main())
