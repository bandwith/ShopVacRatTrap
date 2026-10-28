"""Tests for the offline BOM orderability audit (.github/scripts/bom_audit.py)."""

import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).parent.parent
sys.path.append(str(ROOT / ".github" / "scripts"))

from bom_audit import KNOWN_GAPS, audit, load_bom, main  # noqa: E402

HEADER = (
    "Manufacturer,Manufacturer Part Number,Description,Quantity,"
    "Reference Designator,Distributor,Distributor Part Number,Unit Price,Extended Price\n"
)


def _bom(tmp_path: Path, *rows: str) -> list[dict[str, str]]:
    path = tmp_path / "bom.csv"
    path.write_text(HEADER + "".join(r + "\n" for r in rows), encoding="utf-8")
    return load_bom(path)


def _firmware(tmp_path: Path, text: str) -> Path:
    esphome = tmp_path / "esphome"
    (esphome / "packages").mkdir(parents=True)
    (esphome / "packages" / "sensors.yaml").write_text(text, encoding="utf-8")
    return esphome


def _unwaived(findings):
    return {(f.check, f.subject) for f in findings if not f.waived}


APDS_ROW = "Adafruit,3595,APDS9960,1,U8,Mouser,485-3595,7.50,7.50"
APDS_FIRMWARE = "apds9960:\n  address: 0x39\nsensor:\n  - platform: apds9960\n"


def test_clean_bom_and_firmware_has_no_findings(tmp_path):
    assert audit(_bom(tmp_path, APDS_ROW), _firmware(tmp_path, APDS_FIRMWARE)) == []


def test_hardware_driver_without_bom_row_fails(tmp_path):
    findings = audit(_bom(tmp_path), _firmware(tmp_path, APDS_FIRMWARE))
    assert ("firmware-coverage", "apds9960") in _unwaived(findings)


def test_unknown_driver_must_be_classified(tmp_path):
    esphome = _firmware(tmp_path, "sensor:\n  - platform: shiny_new_sensor\n")
    assert ("unclassified-driver", "shiny_new_sensor") in _unwaived(audit([], esphome))


def test_software_drivers_need_no_part(tmp_path):
    esphome = _firmware(tmp_path, "wifi:\n  ssid: x\nsensor:\n  - platform: template\n")
    assert audit([], esphome) == []


@pytest.mark.parametrize(
    "sku",
    ["4N35-X007", "DF11.2078.0010.01", "6600.3100", ""],
)
def test_unprefixed_mouser_sku_fails(tmp_path, sku):
    rows = _bom(tmp_path, f"Vishay,4N35-X007,Opto,1,U7,Mouser,{sku},0.79,0.79")
    assert ("sku-format", "U7") in _unwaived(audit(rows, _firmware(tmp_path, "")))


def test_off_primary_distributor_fails(tmp_path):
    rows = _bom(tmp_path, "Adafruit,5425,ToF,1,U2,DigiKey,1528-4497-ND,14.95,14.95")
    findings = _unwaived(audit(rows, _firmware(tmp_path, "")))
    assert ("single-distributor", "U2") in findings
    assert ("sku-format", "U2") not in findings  # DigiKey SKU shape is valid


def test_secrets_files_are_ignored(tmp_path):
    esphome = _firmware(tmp_path, "")
    (esphome / "secrets.yaml.example").write_text("wifi_ssid: x\n", encoding="utf-8")
    (esphome / "secrets.yaml").write_text("mystery_key: x\n", encoding="utf-8")
    assert audit([], esphome) == []


# ---------------------------------------------------------------------------
# The real repository: CI gate.
# ---------------------------------------------------------------------------


def _repo_findings():
    return audit(load_bom(ROOT / "BOM_CONSOLIDATED.csv"), ROOT / "esphome")


def test_repository_bom_is_orderable():
    failures = [str(f) for f in _repo_findings() if not f.waived]
    assert not failures, "\n".join(failures)


def test_known_gaps_are_still_real():
    """Ratchet: a fixed gap must have its waiver deleted from KNOWN_GAPS."""
    live = {(f.check, f.subject) for f in _repo_findings() if f.waived}
    stale = set(KNOWN_GAPS) - live
    assert not stale, f"remove resolved waivers from KNOWN_GAPS: {sorted(stale)}"


def test_cli_exit_code(tmp_path, capsys):
    bom = tmp_path / "bom.csv"
    bom.write_text(HEADER, encoding="utf-8")
    esphome = _firmware(tmp_path, APDS_FIRMWARE)
    assert main(["--bom", str(bom), "--esphome", str(esphome)]) == 1
    assert "firmware-coverage: apds9960" in capsys.readouterr().out
