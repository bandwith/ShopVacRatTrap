import pytest
from unittest.mock import MagicMock, patch
from mouser_api import MouserAPIClient, MouserPart, MouserAPIError


@pytest.fixture
def mock_mouser_api_client():
    """Pytest fixture to provide a mocked MouserAPIClient."""
    with patch("mouser_api.requests.Session") as mock_session:
        mock_client = MouserAPIClient(api_key="test_key")
        mock_client.session = mock_session
        yield mock_client


def test_search_part_number_success(mock_mouser_api_client):
    """Test a successful part number search."""
    mock_response = MagicMock()
    mock_response.status_code = 200
    mock_response.json.return_value = {
        "SearchResults": {
            "Parts": [
                {
                    "MouserPartNumber": "279-C3216X7R1H105K",
                    "ManufacturerPartNumber": "C3216X7R1H105K160AA",
                    "Manufacturer": "TDK",
                    "Description": "Capacitor",
                    "Availability": "1000 In Stock",
                    "PriceBreaks": [],
                    "DataSheetUrl": "",
                    "ProductDetailUrl": "",
                    "ImagePath": "",
                    "Category": "",
                    "LeadTime": "",
                    "LifecycleStatus": "",
                    "RohsStatus": "",
                    "UnitOfMeasure": "",
                    "MinOrderQty": 1,
                    "Mult": 1,
                }
            ]
        }
    }
    mock_mouser_api_client.session.post.return_value = mock_response

    parts = mock_mouser_api_client.search_part_number("C3216X7R1H105K160AA", "TDK")

    assert len(parts) == 1
    assert isinstance(parts[0], MouserPart)
    assert parts[0].mouser_part_number == "279-C3216X7R1H105K"


def test_search_part_number_not_found(mock_mouser_api_client):
    """Test a search for a part that is not found."""
    mock_response = MagicMock()
    mock_response.status_code = 200
    mock_response.json.return_value = {"SearchResults": {"Parts": []}}
    mock_mouser_api_client.session.post.return_value = mock_response

    parts = mock_mouser_api_client.search_part_number(
        "non_existent_part", "some_manufacturer"
    )

    assert len(parts) == 0


def test_search_part_number_api_error(mock_mouser_api_client):
    """Test handling of an API error during part search."""
    mock_response = MagicMock()
    mock_response.status_code = 500
    mock_mouser_api_client.session.post.return_value = mock_response

    with pytest.raises(MouserAPIError):
        mock_mouser_api_client.search_part_number("any_part", "any_manufacturer")
