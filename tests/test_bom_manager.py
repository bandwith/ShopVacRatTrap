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
    BOMUpdater,
    BOMValidator,
    GitHubOutputAdapter,
    ValidationSummary,
    load_bom_components,
    summarize_validation,
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
    csv_content = "Manufacturer Part Number,Quantity,Unit Price\nPART1,10,1.50\nPART2,5,2.00"
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


# ---------------------------------------------------------------------------
# Pure validation-core tests (Candidate 4): the pricing/availability decision
# is now testable directly, with no filesystem, environment, or network.
# ---------------------------------------------------------------------------


def _results(components, pricing=None):
    """Build a minimal validation_results dict for summarize_validation."""
    return {
        "total_components": len(components),
        "found_components": sum(1 for c in components if c.get("found")),
        "components": components,
        "pricing_changes": pricing
        or {
            "changes_detected": False,
            "significant_changes": False,
            "total_change_percent": 0.0,
            "changed_components": 0,
        },
        "availability_issues": {},
    }


def test_summarize_counts_unavailable_and_low_stock():
    components = [
        {"found": True, "stock_qty": 0, "quantity": 5},  # unavailable
        {"found": True, "stock_qty": 3, "quantity": 10},  # low stock
        {"found": True, "stock_qty": 50, "quantity": 10},  # fine
        {"found": False, "stock_qty": 0, "quantity": 1},  # not found -> ignored
    ]
    summary = summarize_validation(_results(components))
    assert summary.unavailable_components == 1
    assert summary.low_stock_components == 1
    assert summary.has_unavailable is True
    assert summary.critical_availability is True


def test_summarize_no_availability_issues():
    components = [{"found": True, "stock_qty": 100, "quantity": 1}]
    summary = summarize_validation(_results(components))
    assert summary.unavailable_components == 0
    assert summary.low_stock_components == 0
    assert summary.has_unavailable is False
    assert summary.critical_availability is False


def test_summarize_carries_pricing_flags():
    pricing = {
        "changes_detected": True,
        "significant_changes": True,
        "total_change_percent": 12.3,
        "changed_components": 4,
    }
    summary = summarize_validation(_results([], pricing))
    assert summary.changes_detected is True
    assert summary.significant_changes is True
    assert summary.changed_components == 4
    assert summary.total_change_percent == 12.3


def test_as_github_outputs_maps_booleans_to_strings():
    summary = ValidationSummary(
        changes_detected=True,
        significant_changes=False,
        unavailable_components=2,
    )
    outputs = summary.as_github_outputs()
    assert outputs == {
        "changes_detected": "true",
        "significant_changes": "false",
        "unavailable_components": "true",
    }


def test_github_output_adapter_writes_only_when_enabled(tmp_path):
    out = tmp_path / "gh_output.txt"
    adapter = GitHubOutputAdapter(output_path=str(out))
    assert adapter.enabled is True
    adapter.write(ValidationSummary(changes_detected=True))
    content = out.read_text()
    assert "changes_detected=true" in content
    assert "significant_changes=false" in content
    assert "unavailable_components=false" in content


def test_github_output_adapter_disabled_is_noop(monkeypatch):
    monkeypatch.delenv("GITHUB_OUTPUT", raising=False)
    adapter = GitHubOutputAdapter(output_path=None)
    assert adapter.enabled is False
    # Must not raise even though there is nowhere to write.
    adapter.write(ValidationSummary())

    # Default with unset env var is also disabled
    default_adapter = GitHubOutputAdapter()
    assert default_adapter.enabled is False


def test_bom_updater_handles_first_column_index_zero(tmp_path):
    """Ensure BOMUpdater works when MPN or Unit Price is at column index 0."""
    bom_csv = tmp_path / "bom.csv"
    bom_csv.write_text(
        "Manufacturer Part Number,Unit Price,Quantity,Extended Price\n5323,15.00,2,30.00\n",
        encoding="utf-8",
    )
    validation_results = {
        "components": [
            {
                "mpn": "5323",
                "found": True,
                "updated_price": 17.50,
                "quantity": 2,
            }
        ]
    }
    updater = BOMUpdater()
    assert updater.update_bom_pricing(str(bom_csv), validation_results) is True
    lines = bom_csv.read_text(encoding="utf-8").splitlines()
    assert lines[1] == "5323,17.50,2,35.00"


def test_bom_validator_computes_total_cost_and_priority(tmp_path):
    """Ensure BOMValidator records total_cost and priority flags."""
    bom_csv = tmp_path / "bom.csv"
    bom_csv.write_text(
        "Manufacturer,Manufacturer Part Number,Description,Quantity,Unit Price\n"
        "Adafruit,5323,ESP32-S3 Feather,2,15.00\n",
        encoding="utf-8",
    )
    mock_mouser_validator = MagicMock()
    mock_mouser_validator.validate_single_component.return_value = {
        "found": True,
        "availability": "50 In Stock",
        "datasheet": "https://example.com/ds.pdf",
        "product_url": "https://example.com/part",
        "pricing": {
            "unit_price": 17.50,
            "total_price": 35.00,
        },
    }
    validator = BOMValidator(mock_mouser_validator)
    results = validator.validate_bom(str(bom_csv), priority_components=["5323"])
    assert results["total_cost"] == 35.00
    assert results["components"][0]["is_priority"] is True
    assert results["pricing_changes"]["changes_detected"] is True
