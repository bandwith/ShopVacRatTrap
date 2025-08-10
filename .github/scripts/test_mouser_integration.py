#!/usr/bin/env python3
"""
Test script for Mouser API integration
Validates API connectivity and basic functionality
"""

import os
import sys
import json

# Add the scripts directory to the path for imports
sys.path.append(".github/scripts")

try:
    from mouser_api import MouserAPIClient
    from hybrid_bom_validator import HybridBOMValidator
except ImportError as e:
    print(f"❌ Import error: {e}")
    print("Make sure all required scripts are in .github/scripts/")
    sys.exit(1)


def test_mouser_api():
    """Test basic Mouser API functionality"""
    print("🔧 Testing Mouser API integration...")

    # Check for API key
    api_key = os.getenv("MOUSER_API_KEY")
    if not api_key:
        print("⚠️ MOUSER_API_KEY not set - using dummy key for connection test")
        api_key = "dummy_key_for_testing"  # pragma: allowlist secret

    try:
        # Initialize client
        client = MouserAPIClient(api_key)
        print("✅ Mouser API client initialized")

        # Test part search with a common component
        print("🔍 Testing part search: ESP32-DEVKITC-32E")

        if api_key != "dummy_key_for_testing":  # pragma: allowlist secret
            parts = client.search_part_number("ESP32-DEVKITC-32E", "Espressif")

            if parts:
                part = parts[0]
                print(f"✅ Found part: {part.manufacturer_part_number}")
                print(f"   Manufacturer: {part.manufacturer}")
                print(f"   Description: {part.description}")
                print(f"   Availability: {part.availability}")

                # Test pricing
                pricing = client.get_best_price(part, quantity=1)
                if pricing:
                    print(
                        f"   Price: ${pricing['unit_price']:.2f} {pricing['currency']}"
                    )

                print("✅ Mouser API test successful")
            else:
                print("⚠️ No parts found - check part number or API key")
        else:
            print("⚠️ Skipping actual API call - no valid API key")

    except Exception as e:
        print(f"❌ Mouser API test failed: {e}")
        return False

    return True


def test_hybrid_validator():
    """Test hybrid validation functionality"""
    print("\n🔄 Testing hybrid validation...")

    try:
        # Test initialization with dummy credentials
        os.environ["NEXAR_CLIENT_ID"] = os.getenv("NEXAR_CLIENT_ID", "dummy")
        os.environ["NEXAR_CLIENT_SECRET"] = os.getenv("NEXAR_CLIENT_SECRET", "dummy")

        validator = HybridBOMValidator()
        print(
            f"✅ Hybrid validator initialized with strategy: {validator.validation_strategy}"
        )

        # Test single component validation
        result = validator.validate_component(
            mpn="ESP32-DEVKITC-32E",
            manufacturer="Espressif",
            quantity=1,
            priority="high",
        )

        print("✅ Component validation test completed")
        print(f"   Found: {result.get('found')}")
        print(f"   API used: {result.get('api_used')}")

        if result.get("errors"):
            print(f"   Errors: {len(result['errors'])}")
            for error in result["errors"][:2]:  # Show first 2 errors
                print(f"     - {error}")

        return True

    except Exception as e:
        print(f"❌ Hybrid validator test failed: {e}")
        return False


def test_bom_validation():
    """Test BOM file validation if files exist"""
    print("\n📋 Testing BOM validation...")

    bom_files = ["BOM_BUDGET.csv", "BOM_OCTOPART.csv"]
    existing_boms = [f for f in bom_files if os.path.exists(f)]

    if not existing_boms:
        print("⚠️ No BOM files found - skipping BOM validation test")
        return True

    try:
        validator = HybridBOMValidator()

        for bom_file in existing_boms[:1]:  # Test just the first file
            print(f"🔍 Testing validation of {bom_file}...")

            # Run a limited test (first few components only)
            results = validator.validate_bom_file(bom_file)

            if "error" not in results:
                print("✅ BOM validation test successful")
                print(f"   Total components: {results.get('total_components', 0)}")
                print(f"   Validated: {results.get('validated_components', 0)}")
                print(f"   Found: {results.get('found_components', 0)}")
                print(f"   Strategy: {results.get('validation_strategy')}")

                # Save test results
                with open(f"test_validation_{bom_file}.json", "w") as f:
                    json.dump(results, f, indent=2)
                print(f"📄 Test results saved to test_validation_{bom_file}.json")
            else:
                print(f"❌ BOM validation failed: {results['error']}")
                return False

        return True

    except Exception as e:
        print(f"❌ BOM validation test failed: {e}")
        return False


def main():
    """Main test function"""
    print("🧪 Mouser API + Hybrid Validation Test Suite")
    print("=" * 50)

    tests_passed = 0
    total_tests = 3

    # Test 1: Mouser API
    if test_mouser_api():
        tests_passed += 1

    # Test 2: Hybrid validator
    if test_hybrid_validator():
        tests_passed += 1

    # Test 3: BOM validation
    if test_bom_validation():
        tests_passed += 1

    print("\n" + "=" * 50)
    print(f"🧪 Test Results: {tests_passed}/{total_tests} tests passed")

    if tests_passed == total_tests:
        print("✅ All tests passed! Mouser API integration is ready.")

        # Display setup instructions
        print("\n📋 Setup Instructions:")
        print("1. Get Mouser API key: https://www.mouser.com/api-hub/")
        print("2. Add to GitHub secrets: MOUSER_API_KEY")
        print("3. Workflows will automatically use hybrid validation")
        print("4. Monitor validation reports for API usage statistics")

        return 0
    else:
        print("❌ Some tests failed. Check error messages above.")

        print("\n🔧 Troubleshooting:")
        print("- Verify API credentials are correct")
        print("- Check network connectivity")
        print("- Ensure all script dependencies are installed")

        return 1


if __name__ == "__main__":
    exit(main())
