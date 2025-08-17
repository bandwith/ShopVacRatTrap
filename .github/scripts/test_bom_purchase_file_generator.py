import pytest
from unittest.mock import MagicMock, mock_open, patch
from bom_purchase_file_generator import BOMPurchaseFileGenerator
from mouser_api import MouserAPIClient


@pytest.fixture
def mock_mouser_api_client():
    """Pytest fixture to provide a mocked MouserAPIClient."""
    return MagicMock(spec=MouserAPIClient)


def test_generate_mouser_template_file(mock_mouser_api_client):
    """Test the generation of the Mouser template file."""
    # Arrange
    bom_file = "dummy_bom.csv"
    bom_data = "Manufacturer Part Number,Quantity\npart1,1"
    mock_mouser_api_client.search_part_number.return_value = [MagicMock()]
    generator = BOMPurchaseFileGenerator(mock_mouser_api_client)

    with (
        patch("builtins.open", mock_open(read_data=bom_data)),
        patch("pandas.DataFrame.to_excel") as mock_to_excel,
    ):
        # Act
        generator.generate_mouser_template_file(bom_file, ".")

    # Assert
    mock_to_excel.assert_called_once()


def test_generate_mouser_only_bom(mock_mouser_api_client):
    """Test the generation of the Mouser-only BOM."""
    # Arrange
    bom_file = "dummy_bom.csv"
    bom_data = "Manufacturer Part Number,Quantity\npart1,1"
    mock_mouser_api_client.search_part_number.return_value = [MagicMock()]
    generator = BOMPurchaseFileGenerator(mock_mouser_api_client)

    with patch("builtins.open", mock_open(read_data=bom_data)) as mock_file:
        # Act
        generator.generate_mouser_only_bom(bom_file, ".")

    # Assert
    mock_file.assert_called_with(
        "./BOM_MOUSER_ONLY.csv", "w", newline="", encoding="utf-8"
    )
