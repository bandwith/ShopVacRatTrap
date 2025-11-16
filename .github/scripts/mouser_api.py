#!/usr/bin/env python3
"""
Mouser API Integration for ShopVac Rat Trap BOM Validation
Alternative to Nexar API with higher quotas and comprehensive pricing data

Mouser Search API Endpoints:
- Part Search: https://api.mouser.com/api/v1/search/partnumber
- Keyword Search: https://api.mouser.com/api/v1/search/keyword
- Part Details: https://api.mouser.com/api/v1/search/partnumber/details

API Key required from: https://www.mouser.com/api-hub/

Rate Limits: 1000 requests/hour, 10 requests/second
"""

import os
import json
import time
import requests
import pandas as pd
from dataclasses import dataclass
from datetime import datetime
import logging
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

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


# Mouser API Configuration
@dataclass
class PriceBreak:
    quantity: int
    price: float
    currency: str


@dataclass
class MouserPart:
    """Data class for Mouser part information"""

    mouser_part_number: str
    manufacturer: str
    manufacturer_part_number: str
    description: str
    availability: str
    price_breaks: list[PriceBreak]  # Updated to use PriceBreak
    data_sheet_url: str
    product_detail_url: str
    image_url: str
    category: str
    lead_time: str
    lifecycle_status: str
    rohs_status: str
    packaging: str
    min_order_qty: int
    order_multiple: int


class MouserAPIError(Exception):
    """Base exception for Mouser API errors"""

    pass




    pass


class MouserQuotaExceededError(MouserAPIError):
    """Raised when API quota is exceeded"""

    pass


class MouserPartNotFoundError(MouserAPIError):
    """Raised when part is not found"""

    pass


class MouserBOMValidationError(MouserAPIError):
    """Raised when there's an error during BOM validation."""

    pass


def retry_with_backoff(max_retries: int = 3, base_delay: float = 1.0):
    """Decorator for exponential backoff retry logic with jitter"""

    def decorator(func):
        def wrapper(*args, **kwargs):
            import random

            for attempt in range(max_retries + 1):
                try:
                    return func(*args, **kwargs)
                except MouserRateLimitError:
                    if attempt < max_retries:
                        # Exponential backoff with jitter
                        delay = base_delay * (2**attempt) + random.uniform(0, 1)
                        logger.warning(
                            f"Rate limited, retrying in {delay:.1f}s (attempt {attempt + 1}/{max_retries + 1})"
                        )
                        time.sleep(delay)
                    else:
                        raise
                except (MouserAPIError, requests.exceptions.RequestException) as e:
                    if attempt < max_retries:
                        delay = base_delay * (2**attempt)
                        logger.warning(f"API error: {e}, retrying in {delay:.1f}s")
                        time.sleep(delay)
                    else:
                        raise
            raise  # Re-raise the last exception if all retries fail

        return wrapper

    return decorator


class MouserAPIClient:
    """Mouser API client with rate limiting and error handling"""

    MOUSER_API_BASE = "https://api.mouser.com/api/v1.0"
    MOUSER_SEARCH_ENDPOINT = f"{MOUSER_API_BASE}/search/partnumber"

    REQUESTS_PER_HOUR = 1000
    REQUESTS_PER_SECOND = 10

    def __init__(self, api_key: str = None):
        """Initialize Mouser API client"""
        self.api_key = api_key or os.getenv("MOUSER_API_KEY")
        if not self.api_key:
            raise MouserAPIError(
                "Mouser API key required. Set MOUSER_API_KEY environment variable."
            )

        self.session = requests.Session()
        self.session.headers.update(
            {
                "Content-Type": "application/json",
                "Accept": "application/json",
            }
        )

        # Rate limiting tracking
        self.request_times = []
        self.hourly_request_count = 0
        self.hourly_reset_time = time.time() + 3600

        logger.info("🔧 Mouser API client initialized")

    def _check_rate_limits(self):
        """Check and enforce rate limits"""
        current_time = time.time()

        # Reset hourly counter if needed
        if current_time > self.hourly_reset_time:
            self.hourly_request_count = 0
            self.hourly_reset_time = current_time + 3600

        # Check hourly limit
        if self.hourly_request_count >= self.REQUESTS_PER_HOUR:
            raise MouserRateLimitError(
                f"Hourly request limit ({self.REQUESTS_PER_HOUR}) exceeded"
            )

        # Check per-second limit
        self.request_times = [t for t in self.request_times if current_time - t < 1.0]
        if len(self.request_times) >= self.REQUESTS_PER_SECOND:
            sleep_time = 1.0 - (current_time - self.request_times[0])
            if sleep_time > 0:
                logger.info(f"🐌 Rate limiting: sleeping {sleep_time:.1f}s")
                time.sleep(sleep_time)

        # Record this request
        self.request_times.append(current_time)
        self.hourly_request_count += 1

    @retry_with_backoff(max_retries=3, base_delay=1.0)
    def _make_request(self, endpoint: str, data: dict) -> dict:
        """Make API request with error handling"""
        self._check_rate_limits()

        # Add API key as query parameter for Mouser API
        url_with_key = f"{endpoint}?apiKey={self.api_key}"

        try:
            response = self.session.post(url_with_key, json=data, timeout=30)

            # Handle specific HTTP status codes
            if response.status_code == 429:
                raise MouserRateLimitError("Rate limit exceeded (HTTP 429)")
            elif response.status_code == 401:
                raise MouserAPIError("Authentication failed - check API key")
            elif response.status_code == 403:
                raise MouserQuotaExceededError("API quota exceeded")
            elif response.status_code >= 500:
                raise MouserAPIError(f"Server error: HTTP {response.status_code}")

            response.raise_for_status()
            data = response.json()

            # Check for API-level errors
            if "Errors" in data and data["Errors"]:
                error_msg = "; ".join(
                    [err.get("Message", "") for err in data["Errors"]]
                )
                if "quota" in error_msg.lower() or "limit" in error_msg.lower():
                    raise MouserQuotaExceededError(f"API quota error: {error_msg}")
                else:
                    raise MouserAPIError(f"API error: {error_msg}")

            return data

        except requests.exceptions.Timeout:
            raise MouserAPIError("Request timeout")
        except requests.exceptions.ConnectionError:
            raise MouserAPIError("Connection error")

    def search_part_number(
        self, part_number: str, manufacturer: str = None
    ) -> list[MouserPart]:
        """Search for exact part number match"""
        # Mouser API requires POST with JSON payload
        payload = {
            "SearchByPartRequest": {
                "mouserPartNumber": part_number,
                "partSearchOptions": "PartNumber",
            }
        }

        logger.info(f"🔍 Searching Mouser for part: {part_number}")

        try:
            data = self._make_request(
                self.MOUSER_SEARCH_ENDPOINT, payload
            )  # Updated usage

            # Check for results in Mouser API response format
            if "SearchResults" not in data or not data["SearchResults"].get("Parts"):
                logger.warning(f"⚠️ No results found for {part_number}")
                return []

            parts = []
            for part_data in data["SearchResults"]["Parts"]:
                # Filter by manufacturer if specified
                if (
                    manufacturer
                    and manufacturer.lower()
                    not in part_data.get("Manufacturer", "").lower()
                ):
                    continue

                part = self._parse_part_data(part_data)
                parts.append(part)

            logger.info(f"✅ Found {len(parts)} results for {part_number}")
            return parts

        except MouserAPIError as e:
            logger.error(f"❌ API error searching for {part_number}: {e}")
            return []

    def search_keyword(
        self, keyword: str, manufacturer: str = None, max_results: int = 10
    ) -> list[MouserPart]:
        """Search by keyword/description"""
        params = {
            "keyword": keyword,
            "records": min(max_results, 50),  # Mouser max is 50
            "includeDetail": "true",
        }

        if manufacturer:
            params["manufacturerFilter"] = manufacturer

        logger.info(f"🔍 Keyword search on Mouser: {keyword}")

        try:
            data = self._make_request(
                f"{self.MOUSER_SEARCH_ENDPOINT}/keyword", params
            )  # Updated usage

            if "SearchResults" not in data or not data["SearchResults"].get("Parts"):
                logger.warning(f"⚠️ No keyword results found for {keyword}")
                return []

            parts = []
            for part_data in data["SearchResults"]["Parts"]:
                part = self._parse_part_data(part_data)
                parts.append(part)

            logger.info(f"✅ Found {len(parts)} keyword results for {keyword}")
            return parts

        except MouserAPIError as e:
            logger.error(f"❌ API error in keyword search for {keyword}: {e}")
            return []

    def _parse_part_data(self, part_data: dict) -> MouserPart:
        """Parse Mouser API response into MouserPart object"""
        price_breaks = self._parse_price_breaks(part_data.get("PriceBreaks", []))

        return MouserPart(
            mouser_part_number=part_data.get("MouserPartNumber", ""),
            manufacturer=part_data.get("Manufacturer", ""),
            manufacturer_part_number=part_data.get("ManufacturerPartNumber", ""),
            description=part_data.get("Description", ""),
            availability=part_data.get("Availability", ""),
            price_breaks=price_breaks,
            data_sheet_url=part_data.get("DataSheetUrl", ""),
            product_detail_url=part_data.get("ProductDetailUrl", ""),
            image_url=part_data.get("ImagePath", ""),
            category=part_data.get("Category", ""),
            lead_time=part_data.get("LeadTime", ""),
            lifecycle_status=part_data.get("LifecycleStatus", ""),
            rohs_status=part_data.get("RohsStatus", ""),
            packaging=part_data.get("UnitOfMeasure", ""),
            min_order_qty=int(part_data.get("MinOrderQty", 1)),
            order_multiple=int(part_data.get("Mult", 1)),
        )

    def get_best_price(self, part: MouserPart, quantity: int = 1) -> dict | None:
        """Get best price for specified quantity"""
        if not part.price_breaks:
            return None

        # Find the best applicable price break
        applicable_breaks = [
            pb
            for pb in part.price_breaks
            if pb.quantity <= quantity  # Access quantity directly
        ]
        if not applicable_breaks:
            # Use minimum quantity if requested quantity is too low
            min_break = min(
                part.price_breaks, key=lambda x: x.quantity
            )  # Access quantity directly
            return {
                "quantity": min_break.quantity,
                "unit_price": min_break.price,
                "total_price": min_break.price * min_break.quantity,
                "currency": min_break.currency,
                "note": f"Minimum order quantity: {min_break.quantity}",
            }

        best_break = max(
            applicable_breaks, key=lambda x: x.quantity
        )  # Access quantity directly
        return {
            "quantity": quantity,
            "unit_price": best_break.price,
            "total_price": best_break.price * quantity,
            "currency": best_break.currency,
            "price_break_qty": best_break.quantity,
        }

    def _parse_price_breaks(self, raw_price_breaks: list[dict]) -> list[PriceBreak]:
        """Parse raw price break data into a list of PriceBreak objects."""
        parsed_price_breaks = []
        for price_break in raw_price_breaks:
            parsed_price_breaks.append(
                PriceBreak(
                    quantity=int(price_break.get("Quantity", 0)),
                    price=float(
                        price_break.get("Price", "0").replace("$", "").replace(",", "")
                    ),
                    currency=price_break.get("Currency", "USD"),
                )
            )
        return parsed_price_breaks


class MouserBOMColumns:
    MANUFACTURER = "Manufacturer"
    MANUFACTURER_PART_NUMBER = "Manufacturer Part Number"
    QUANTITY = "Quantity"


class MouserBOMValidator:
    """BOM validation using Mouser API"""

    def __init__(self, api_key: str = None):
        """Initialize BOM validator"""
        self.client = MouserAPIClient(api_key)
        self.results = []

    def validate_bom_file(
        self, bom_file: str, quantity_column: str = "Quantity"
    ) -> dict:
        """Validate entire BOM file"""
        logger.info(f"📋 Validating BOM file: {bom_file}")

        try:
            # Read BOM file
            if bom_file.endswith(".csv"):
                df = pd.read_csv(bom_file)
            elif bom_file.endswith(".xlsx"):
                df = pd.read_excel(bom_file)
            else:
                raise MouserBOMValidationError(
                    "Unsupported file format. Use CSV or Excel."
                )

            required_columns = [
                MouserBOMColumns.MANUFACTURER,
                MouserBOMColumns.MANUFACTURER_PART_NUMBER,
            ]
            missing_columns = [col for col in required_columns if col not in df.columns]
            if missing_columns:
                raise MouserBOMValidationError(
                    f"Missing required columns: {missing_columns}"
                )

            # Validate each component
            validation_results = {
                "total_components": len(df),
                "found_components": 0,
                "not_found_components": 0,
                "total_cost": 0.0,
                "components": [],
                "errors": [],
            }

            for index, row in df.iterrows():
                try:
                    mpn = row[MouserBOMColumns.MANUFACTURER_PART_NUMBER]
                    manufacturer = row[MouserBOMColumns.MANUFACTURER]
                    quantity = int(row.get(quantity_column, MouserBOMColumns.QUANTITY))

                    logger.info(f"🔍 Validating {mpn} ({manufacturer})...")

                    # Search for the part
                    parts = self.client.search_part_number(mpn, manufacturer)

                    if parts:
                        best_part = parts[0]  # Take the first (best) match
                        pricing = self.client.get_best_price(best_part, quantity)

                        component_result = {
                            "index": index,
                            "mpn": mpn,
                            "manufacturer": manufacturer,
                            "found": True,
                            "mouser_part": best_part.mouser_part_number,
                            "description": best_part.description,
                            "availability": best_part.availability,
                            "pricing": pricing,
                            "datasheet": best_part.data_sheet_url,
                            "product_url": best_part.product_detail_url,
                            "lead_time": best_part.lead_time,
                            "lifecycle": best_part.lifecycle_status,
                            "rohs": best_part.rohs_status,
                        }

                        validation_results["found_components"] += 1
                        if pricing:
                            validation_results["total_cost"] += pricing["total_price"]

                    else:
                        # Try keyword search as fallback
                        keyword_parts = self.client.search_keyword(
                            mpn, manufacturer, max_results=3
                        )

                        component_result = {
                            "index": index,
                            "mpn": mpn,
                            "manufacturer": manufacturer,
                            "found": False,
                            "keyword_matches": len(keyword_parts),
                            "suggestions": (
                                [
                                    {
                                        "mpn": p.manufacturer_part_number,
                                        "manufacturer": p.manufacturer,
                                        "description": p.description,
                                        "mouser_part": p.mouser_part_number,
                                    }
                                    for p in keyword_parts[:3]
                                ]
                                if keyword_parts
                                else []
                            ),
                        }

                        validation_results["not_found_components"] += 1

                    validation_results["components"].append(component_result)

                except Exception as e:
                    error_msg = f"Error validating row {index} ({mpn}): {e}"
                    logger.error(f"❌ {error_msg}")
                    validation_results["errors"].append(error_msg)

            # Generate summary
            success_rate = (
                validation_results["found_components"]
                / validation_results["total_components"]
            ) * 100
            logger.info(f"✅ Validation complete: {success_rate:.1f}% success rate")
            logger.info(
                f"💰 Total estimated cost: ${validation_results['total_cost']:.2f}"
            )

            return validation_results

        except (MouserBOMValidationError, MouserAPIError) as e:
            logger.error(f"❌ BOM validation failed: {e}")
            raise  # Re-raise the specific exception
        except Exception as e:
            logger.error(f"❌ An unexpected error occurred during BOM validation: {e}")
            raise MouserBOMValidationError(
                f"An unexpected error occurred during BOM validation: {e}"
            ) from e

    def save_results(self, results: dict, output_file: str):
        """Save validation results to file"""
        timestamp = datetime.now().isoformat()

        output_data = {
            "validation_timestamp": timestamp,
            "mouser_api": True,
            "summary": {
                "total_components": results["total_components"],
                "found_components": results["found_components"],
                "success_rate": f"{(results['found_components'] / results['total_components']) * 100:.1f}%",
                "total_estimated_cost": f"${results['total_cost']:.2f}",
            },
            "results": results,
        }

        with open(output_file, "w") as f:
            json.dump(output_data, f, indent=2)

        logger.info(f"💾 Results saved to {output_file}")

    def validate_single_component(
        self, mpn: str, manufacturer: str, quantity: int
    ) -> dict:
        """Validates a single component against the Mouser API."""
        component_result = {
            "mpn": mpn,
            "manufacturer": manufacturer,
            "quantity": quantity,
            "found": False,
            "mouser_part": None,
            "description": None,
            "availability": None,
            "pricing": None,
            "datasheet": None,
            "product_url": None,
            "lead_time": None,
            "lifecycle": None,
            "rohs": None,
            "error": None,
        }

        try:
            parts = self.client.search_part_number(mpn, manufacturer)

            if parts:
                best_part = parts[0]
                pricing = self.client.get_best_price(best_part, quantity)

                component_result.update(
                    {
                        "found": True,
                        "mouser_part": best_part.mouser_part_number,
                        "description": best_part.description,
                        "availability": best_part.availability,
                        "pricing": pricing,
                        "datasheet": best_part.data_sheet_url,
                        "product_url": best_part.product_detail_url,
                        "lead_time": best_part.lead_time,
                        "lifecycle": best_part.lifecycle_status,
                        "rohs": best_part.rohs_status,
                    }
                )
            else:
                # Try keyword search as fallback
                keyword_parts = self.client.search_keyword(
                    mpn, manufacturer, max_results=3
                )
                if keyword_parts:
                    component_result["error"] = (
                        "Part not found by exact MPN, but keyword matches found."
                    )
                    component_result["keyword_matches"] = len(keyword_parts)
                    component_result["suggestions"] = [
                        {
                            "mpn": p.manufacturer_part_number,
                            "manufacturer": p.manufacturer,
                            "description": p.description,
                            "mouser_part": p.mouser_part_number,
                        }
                        for p in keyword_parts[:3]
                    ]
                else:
                    component_result["error"] = "Part not found."

        except MouserAPIError as e:
            component_result["error"] = str(e)
        except Exception as e:
            component_result["error"] = f"Unexpected error: {e}"

        return component_result


def main():
    """Main function for CLI usage"""
    import argparse

    parser = argparse.ArgumentParser(description="Validate BOM using Mouser API")
    parser.add_argument(
        "--bom-files", nargs="+", required=True, help="BOM files to validate"
    )
    parser.add_argument(
        "--api-key", help="Mouser API key (or set MOUSER_API_KEY env var)"
    )
    parser.add_argument(
        "--output-dir", default=".", help="Output directory for results"
    )
    parser.add_argument(
        "--quantity-column", default="Quantity", help="Quantity column name"
    )

    args = parser.parse_args()

    try:
        validator = MouserBOMValidator(args.api_key)

        for bom_file in args.bom_files:
            logger.info(f"🔍 Processing {bom_file}")

            results = validator.validate_bom_file(bom_file, args.quantity_column)

            if "error" not in results:
                # Save results
                output_file = os.path.join(
                    args.output_dir,
                    f"mouser_validation_{os.path.basename(bom_file)}.json",
                )
                validator.save_results(results, output_file)

                # Print summary
                print(f"\n📊 Summary for {bom_file}:")
                print(f"   Total components: {results['total_components']}")
                print(f"   Found: {results['found_components']}")
                print(f"   Not found: {results['not_found_components']}")
                print(
                    f"   Success rate: {(results['found_components'] / results['total_components']) * 100:.1f}%"
                )
                print(f"   Estimated cost: ${results['total_cost']:.2f}")

                if results["errors"]:
                    print(f"   Errors: {len(results['errors'])}")

    except (MouserBOMValidationError, MouserAPIError) as e:
        logger.error(f"❌ Validation failed: {e}")
        return 1
    except Exception as e:
        logger.error(f"❌ An unexpected error occurred: {e}")
        return 1

    return 0


if __name__ == "__main__":
    exit(main())
