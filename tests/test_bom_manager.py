import sys
from pathlib import Path
from unittest.mock import MagicMock, mock_open, patch

import pytest

# Add scripts directory to path for BOM manager imports
scripts_path = Path(__file__).parent.parent / ".github" / "scripts"
sys.path.append(str(scripts_path))

from bom_manager import (  # noqa: E402
    BOMColumns,
    BOMManagerError,
    BOMValidator,
    load_bom_components,
)


def test_bom_columns_constants():
    """Verify BOMColumns constants are correct."""
    assert BOMColumns.UNIT_PRICE == "Unit Price"
    assert BOMColumns.MANUFACTURER_PART_NUMBER == "Manufacturer Part Number"
    assert BOMColumns.QUANTITY == "Quantity"


def test_bom_manager_error():
    """Verify BOMManagerError can be raised."""
    with pytest.raises(BOMManagerError):
        raise BOMManagerError("Test error")


def test_load_bom_components_success():
    """Test loading BOM components successfully."""
    csv_content = (
        "Manufacturer Part Number,Quantity,Unit Price\nPART1,10,1.50\nPART2,5,2.00"
    )
    with patch("builtins.open", mock_open(read_data=csv_content)):
        components = load_bom_components("dummy.csv")
        assert len(components) == 2
        assert components[0]["Manufacturer Part Number"] == "PART1"
        assert components[0]["Quantity"] == "10"


def test_load_bom_components_file_not_found():
    """Test loading BOM components with missing file."""
    with pytest.raises(BOMManagerError):
        load_bom_components("nonexistent.csv")


@patch("bom_manager.MouserBOMValidator")
def test_bom_validator_initialization(mock_validator_cls):
    """Test BOMValidator initialization."""
    mock_validator = MagicMock()
    validator = BOMValidator(mock_validator)
    assert validator.mouser_bom_validator == mock_validator
