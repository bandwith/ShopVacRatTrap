import pytest
from unittest.mock import MagicMock, patch, mock_open
from bom_validator import BOMValidator
from mouser_api import MouserAPIClient


@pytest.fixture
def mock_mouser_api_client():
    """Pytest fixture to provide a mocked MouserAPIClient."""
    return MagicMock(spec=MouserAPIClient)


def test_validate_bom_success(mock_mouser_api_client):
    """Test a successful BOM validation."""
    # Arrange
    bom_file = "dummy_bom.csv"
    bom_data = "Manufacturer Part Number,Quantity\npart1,1"
    mock_mouser_api_client.search_part_number.return_value = [MagicMock()]
    validator = BOMValidator(mock_mouser_api_client)

    with patch("builtins.open", mock_open(read_data=bom_data)):
        # Act
        results = validator.validate_bom(bom_file)

    # Assert
    assert results["total_components"] == 1
    assert results["found_components"] == 1


def test_validate_bom_part_not_found(mock_mouser_api_client):
    """Test BOM validation where a part is not found."""
    # Arrange
    bom_file = "dummy_bom.csv"
    bom_data = "Manufacturer Part Number,Quantity\npart1,1"
    mock_mouser_api_client.search_part_number.return_value = []
    validator = BOMValidator(mock_mouser_api_client)

    with patch("builtins.open", mock_open(read_data=bom_data)):
        # Act
        results = validator.validate_bom(bom_file)

    # Assert
    assert results["total_components"] == 1
    assert results["found_components"] == 0
