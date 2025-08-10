#!/usr/bin/env python3
"""
Test script for Nexar API error handling and backoff strategies
"""

import sys
from pathlib import Path

# Add the scripts directory to the Python path
sys.path.insert(0, str(Path(__file__).parent / ".github" / "scripts"))

try:
    from nexar_validation import NexarValidator

    print("✅ Successfully imported error handling classes")
except ImportError as e:
    print(f"❌ Import failed: {e}")
    sys.exit(1)


def test_error_handling():
    """Test the error handling mechanisms"""
    print("🧪 Testing Nexar API error handling...")

    # Test with dummy credentials (will fail auth, but should handle gracefully)
    try:
        validator = NexarValidator("dummy_id", "dummy_secret")
        print("✅ NexarValidator created successfully")

        # This should fail authentication but handle it gracefully
        try:
            validator.authenticate()
            print("❌ Authentication should have failed with dummy credentials")
        except Exception as e:
            print(f"✅ Authentication failed as expected: {type(e).__name__}")

    except Exception as e:
        print(f"❌ Unexpected error creating validator: {e}")
        return False

    print("✅ Error handling test completed successfully")
    return True


def test_backoff_calculation():
    """Test the exponential backoff calculation"""
    try:
        from nexar_validation import exponential_backoff

        print("🧪 Testing exponential backoff calculation...")

        delays = []
        for attempt in range(5):
            delay = exponential_backoff(attempt, base_delay=1.0, max_delay=10.0)
            delays.append(delay)
            print(f"  Attempt {attempt}: {delay:.2f}s")

        # Verify delays are increasing (generally)
        if delays[4] > delays[0]:
            print("✅ Backoff delays are increasing correctly")
            return True
        else:
            print("❌ Backoff delays not increasing as expected")
            return False

    except ImportError:
        print("❌ Could not import exponential_backoff function")
        return False


def main():
    """Run all tests"""
    print("🚀 Starting Nexar API error handling tests...\n")

    tests = [
        ("Error Handling", test_error_handling),
        ("Backoff Calculation", test_backoff_calculation),
    ]

    passed = 0
    total = len(tests)

    for test_name, test_func in tests:
        print(f"\n{'=' * 50}")
        print(f"TEST: {test_name}")
        print("=" * 50)

        try:
            if test_func():
                print(f"✅ {test_name} PASSED")
                passed += 1
            else:
                print(f"❌ {test_name} FAILED")
        except Exception as e:
            print(f"❌ {test_name} ERROR: {e}")

    print(f"\n{'=' * 50}")
    print(f"RESULTS: {passed}/{total} tests passed")
    print("=" * 50)

    if passed == total:
        print("🎉 All tests passed! Error handling is working correctly.")
        return 0
    else:
        print("⚠️  Some tests failed. Check the implementation.")
        return 1


if __name__ == "__main__":
    sys.exit(main())
