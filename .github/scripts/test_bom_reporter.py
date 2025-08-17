import pytest
from unittest.mock import mock_open, patch
from bom_reporter import BOMReporter


@pytest.fixture
def validation_results():
    """Pytest fixture to provide sample validation results."""
    return {
        "total_components": 1,
        "found_components": 1,
        "pricing_changes": {
            "changed_components": 0,
            "total_change_percent": 0.0,
            "significant_changes": False,
        },
        "availability_issues": {
            "unavailable_components": 0,
            "low_stock_components": 0,
            "critical_availability": False,
        },
        "components": [],
    }


def test_generate_pricing_report(validation_results):
    """Test the generation of the pricing report."""
    reporter = BOMReporter()
    with patch("builtins.open", mock_open()) as mock_file:
        reporter.generate_pricing_report(validation_results)
        mock_file.assert_called_with("pricing_report.md", "w")


def test_generate_availability_report(validation_results):
    """Test the generation of the availability report."""
    reporter = BOMReporter()
    with patch("builtins.open", mock_open()) as mock_file:
        reporter.generate_availability_report(validation_results)
        mock_file.assert_called_with("availability_report.md", "w")
