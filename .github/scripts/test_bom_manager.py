from unittest.mock import patch
from bom_manager import main


@patch("bom_manager.BOMValidator")
@patch("bom_manager.BOMReporter")
@patch("bom_manager.BOMUpdater")
@patch("bom_manager.BOMPurchaseFileGenerator")
@patch("bom_manager.MouserAPIClient")
def test_main_all(
    mock_api_client,
    mock_purchase_generator,
    mock_updater,
    mock_reporter,
    mock_validator,
):
    """Test the main function with the --all flag."""
    # Arrange
    args = ["--bom-file", "dummy_bom.csv", "--all"]

    # Act
    with patch("sys.argv", ["bom_manager.py"] + args):
        result = main()

    # Assert
    assert result == 0
    mock_validator.return_value.validate_bom.assert_called_once()
    mock_reporter.return_value.generate_pricing_report.assert_called_once()
    mock_reporter.return_value.generate_availability_report.assert_called_once()
    mock_purchase_generator.return_value.generate_mouser_template_file.assert_called_once()
    mock_purchase_generator.return_value.generate_mouser_only_bom.assert_called_once()


@patch("bom_manager.BOMValidator")
@patch("bom_manager.MouserAPIClient")
def test_main_validate_only(mock_api_client, mock_validator):
    """Test the main function with the --validate flag."""
    # Arrange
    args = ["--bom-file", "dummy_bom.csv", "--validate"]

    # Act
    with patch("sys.argv", ["bom_manager.py"] + args):
        result = main()

    # Assert
    assert result == 0
    mock_validator.return_value.validate_bom.assert_called_once()
