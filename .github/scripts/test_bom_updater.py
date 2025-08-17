import pytest
from unittest.mock import mock_open, patch
from bom_updater import BOMUpdater


@pytest.fixture
def validation_results():
    """Pytest fixture to provide sample validation results."""
    return {
        "components": [
            {
                "mpn": "part1",
                "found": True,
                "updated_price": 1.23,
                "quantity": 1,
            }
        ]
    }


def test_update_bom_pricing(validation_results):
    """Test the BOM pricing update functionality."""
    updater = BOMUpdater()
    bom_file = "dummy_bom.csv"
    bom_data = "Manufacturer Part Number,Unit Price\npart1,1.00"

    with patch("builtins.open", mock_open(read_data=bom_data)) as mock_file:
        updater.update_bom_pricing(bom_file, validation_results)
        mock_file.assert_called_with(bom_file, "w", newline="")
