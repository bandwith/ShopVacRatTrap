import pytest
import pandas as pd
from unittest.mock import MagicMock, mock_open, patch
from bom_manager import (
    load_bom,
    validate_part_numbers,
    check_availability,
    update_pricing,
    generate_mouser_template,
)

# Sample BOM data as a string for mocking file reads
SAMPLE_BOM_CSV = """Designator,Part Number,Description,Quantity
C1,C3216X7R1H105K160AA,Capacitor,1
R1,RMCF0805JT10K0,Resistor,1
U1,ESP32-S3-FEATHER,ESP32-S3 Feather,1
"""

@pytest.fixture
def sample_bom_df():
    """Pytest fixture to provide a sample BOM DataFrame."""
    from io import StringIO
    return pd.read_csv(StringIO(SAMPLE_BOM_CSV))

def test_load_bom(mocker):
    """Test that the BOM is loaded correctly from a CSV file."""
    mocker.patch("builtins.open", mock_open(read_data=SAMPLE_BOM_CSV))
    mocker.patch("os.path.exists", return_value=True)

    bom_df = load_bom("dummy_path.csv")
    assert not bom_df.empty
    assert "Part Number" in bom_df.columns
    assert len(bom_df) == 3
    assert bom_df.iloc[0]["Part Number"] == "C3216X7R1H105K160AA"

def test_load_bom_file_not_found(mocker):
    """Test that a FileNotFoundError is raised if the BOM file does not exist."""
    mocker.patch("os.path.exists", return_value=False)
    with pytest.raises(FileNotFoundError):
        load_bom("non_existent_file.csv")

@pytest.fixture
def mock_mouser_api_success():
    """Fixture to mock a successful Mouser API response."""
    mock_response = MagicMock()
    mock_response.status_code = 200
    mock_response.json.return_value = {
        "SearchResults": {
            "Parts": [
                {
                    "MouserPartNumber": "279-C3216X7R1H105K",
                    "ManufacturerPartNumber": "C3216X7R1H105K160AA",
                    "PriceBreaks": [{"Price": "0.10", "Quantity": 1}],
                    "Availability": "1000 In Stock",
                    "ProductDetailUrl": "http://example.com/part"
                }
            ]
        }
    }
    return mock_response

def test_validate_part_numbers_success(mocker, sample_bom_df, mock_mouser_api_success):
    """Test part number validation with a successful API response."""
    mocker.patch("requests.post", return_value=mock_mouser_api_success)

    validated_data, errors = validate_part_numbers(sample_bom_df, "dummy_key")

    assert not errors
    assert len(validated_data) == 1 # Only one part should be validated in this mocked scenario
    assert validated_data[0]["MouserPartNumber"] == "279-C3216X7R1H105K"

def test_check_availability(mocker, sample_bom_df, mock_mouser_api_success):
    """Test component availability checking."""
    mocker.patch("requests.post", return_value=mock_mouser_api_success)

    availability_results = check_availability(sample_bom_df, "dummy_key")

    assert len(availability_results) == 1
    assert availability_results[0]["Availability"] == "1000 In Stock"
    assert availability_results[0]["Status"] == "In Stock"

@patch('pandas.DataFrame.to_excel')
def test_generate_mouser_template(mock_to_excel, sample_bom_df):
    """Test the generation of the Mouser-compatible Excel template."""

    # Create a dummy DataFrame that would be the result of validation
    validated_df = sample_bom_df.copy()
    validated_df["Mouser Part Number"] = ["279-C3216X7R1H105K", "603-RMCF0805JT10K0", ""]

    generate_mouser_template(validated_df, "test_template.xlsx")

    # Check that the to_excel method was called
    mock_to_excel.assert_called_once()

    # Check the structure of the DataFrame passed to to_excel
    args, kwargs = mock_to_excel.call_args
    df_to_excel = args[1] # The DataFrame is the second argument

    assert "Mouser Part Number" in df_to_excel.columns
    assert "Quantity" in df_to_excel.columns
    assert len(df_to_excel.columns) == 2
    assert len(df_to_excel) == 2 # Should not include parts with no Mouser P/N

def test_update_pricing(mocker, sample_bom_df):
    """Test the pricing update functionality."""

    # Mock the validation results
    validation_results = [
        {
            "ManufacturerPartNumber": "C3216X7R1H105K160AA",
            "Price": "0.12",
            "Currency": "USD"
        }
    ]

    mocker.patch("builtins.open", mock_open(read_data=SAMPLE_BOM_CSV))

    # The bom_manager.py script writes the updated BOM to a file, so we need to mock that
    mock_file = mock_open()
    mocker.patch("builtins.open", mock_file)

    update_pricing("dummy_bom.csv", validation_results)

    # We can't easily check the content of the written file without more complex mocking,
    # but we can check that a file was opened for writing.
    mock_file.assert_called_with("dummy_bom.csv", "w", newline="", encoding="utf-8")

# You can add more tests here for other functions and edge cases.
# For example:
# - Test API failure scenarios (status code != 200)
# - Test what happens when a part is not found
# - Test the logic for creating reports
