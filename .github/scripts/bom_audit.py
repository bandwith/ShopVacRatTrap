#!/usr/bin/env python3
"""Offline orderability audit for the ShopVac Rat Trap BOM.

One interface, ``audit(bom_rows, esphome_dir)``, answers "can a builder order
every electrical part this firmware needs, from the SKUs in the BOM?" without
touching the network. It runs on every PR (via pytest and the CLI) so drift is
caught before the scheduled Mouser validation ever runs.

Checks:

* ``firmware-coverage``: every hardware driver the ESPHome configs load maps to
  at least one BOM row (by manufacturer part number).
* ``unclassified-driver``: every driver/top-level key found in the ESPHome
  configs is classified as hardware or software, so new drivers can't slip in
  without a sourcing decision.
* ``sku-format``: every distributor part number has the shape that
  distributor's cart upload accepts (e.g. Mouser ``NNN-...``).
* ``single-distributor``: every row is orderable from the primary distributor,
  so the whole build fits in one cart.

Known, ticketed gaps live in ``KNOWN_GAPS`` and are reported as ``waived``.
The pytest suite asserts the waiver list matches reality exactly, so fixing a
gap forces deleting its waiver (a ratchet), and a new gap fails CI.
"""

from __future__ import annotations

import argparse
import csv
import re
import sys
from dataclasses import dataclass
from pathlib import Path

PRIMARY_DISTRIBUTOR = "Mouser"

# ESPHome driver (top-level key or ``platform:`` value) -> manufacturer part
# numbers in the BOM that satisfy it. Any one MPN being present is enough.
HARDWARE_DRIVERS: dict[str, frozenset[str]] = {
    "esp32": frozenset({"5323"}),  # Adafruit ESP32-S3 Feather
    "psram": frozenset({"5323"}),
    "deep_sleep": frozenset({"5323"}),
    "apds9960": frozenset({"3595"}),
    "vl53l4cx": frozenset({"5425"}),
    "sths34pf80": frozenset({"6426"}),
    "lsm6ds": frozenset({"4438"}),
    "bme280_i2c": frozenset({"2652"}),
    "ssd1306_i2c": frozenset({"326"}),
    "esp32_camera": frozenset({"5946"}),
    "ledc": frozenset({"5639"}),  # IR illuminator PWM
    "monochromatic": frozenset({"5639"}),
    # Grove Vision AI V2 over UART (camera variant).
    "uart": frozenset({"101021112"}),
}

# Drivers/keys with no part to order: ESPHome core, logical sensors, buses
# (the bus itself is on the MCU), and derived/virtual entities.
SOFTWARE_DRIVERS: frozenset[str] = frozenset(
    {
        # top-level core / containers
        "esphome",
        "api",
        "ota",
        "logger",
        "wifi",
        "captive_portal",
        "web_server",
        "packages",
        "substitutions",
        "external_components",
        "globals",
        "script",
        "interval",
        "font",
        "i2c",
        "sensor",
        "binary_sensor",
        "text_sensor",
        "switch",
        "button",
        "number",
        "light",
        "output",
        "display",
        "motion",  # container for the lsm6ds hub and its derived entities
        "rodent_classifier",  # on-device placeholder, no hardware
        # platforms
        "template",
        "gpio",  # pin binding; physical parts are covered by the pin audit
        "restart",
        "uptime",
        "version",
        "wifi_info",
        "wifi_signal",
        "status",
        "copy",
    }
)

# Gaps that are tracked by a ticket. Key: (check, subject). Value: reason.
KNOWN_GAPS: dict[tuple[str, str], str] = {}

SKU_PATTERNS: dict[str, re.Pattern[str]] = {
    "Mouser": re.compile(r"^\d{2,3}-\S+$"),
    "DigiKey": re.compile(r"^\S+-ND$"),
}

_TOP_LEVEL_KEY = re.compile(r"^([a-z0-9_]+):", re.MULTILINE)
_PLATFORM = re.compile(r"^\s*(?:-\s*)?platform:\s*([a-z0-9_]+)", re.MULTILINE)


@dataclass(frozen=True)
class Finding:
    """One audit result. ``waived`` findings are known, ticketed gaps."""

    check: str
    subject: str
    message: str
    waived: bool = False

    def __str__(self) -> str:
        tag = "WAIVED" if self.waived else "FAIL"
        return f"[{tag}] {self.check}: {self.subject}: {self.message}"


def load_bom(path: Path) -> list[dict[str, str]]:
    """Read BOM rows as dicts keyed by the CSV header."""
    with path.open(newline="", encoding="utf-8") as fh:
        return [{k: (v or "").strip() for k, v in row.items()} for row in csv.DictReader(fh)]


def firmware_drivers(esphome_dir: Path) -> dict[str, set[str]]:
    """Map each ESPHome driver/top-level key to the files that use it.

    Scans text rather than parsing YAML because ESPHome tags (``!include``,
    ``!secret``, ``!lambda``) aren't loadable by a plain YAML loader, and the
    two patterns we need are unambiguous at the line level.
    """
    found: dict[str, set[str]] = {}
    for path in sorted(esphome_dir.rglob("*.yaml")):
        if path.name.startswith("secrets"):
            continue
        text = path.read_text(encoding="utf-8")
        rel = path.relative_to(esphome_dir).as_posix()
        for pattern in (_TOP_LEVEL_KEY, _PLATFORM):
            for name in pattern.findall(text):
                found.setdefault(name, set()).add(rel)
    return found


def _waive(check: str, subject: str, message: str) -> Finding:
    return Finding(check, subject, message, waived=(check, subject) in KNOWN_GAPS)


def audit(bom_rows: list[dict[str, str]], esphome_dir: Path) -> list[Finding]:
    """Return every orderability finding for this BOM against this firmware."""
    findings: list[Finding] = []
    mpns = {row.get("Manufacturer Part Number", "") for row in bom_rows}

    for driver, files in sorted(firmware_drivers(esphome_dir).items()):
        where = ", ".join(sorted(files))
        if driver in HARDWARE_DRIVERS:
            wanted = HARDWARE_DRIVERS[driver]
            if not wanted & mpns:
                need = ", ".join(sorted(wanted)) or "no part chosen"
                findings.append(
                    _waive(
                        "firmware-coverage",
                        driver,
                        f"used in {where} but no BOM row provides it (expected MPN: {need})",
                    )
                )
        elif driver not in SOFTWARE_DRIVERS:
            findings.append(
                _waive(
                    "unclassified-driver",
                    driver,
                    f"used in {where}; add it to HARDWARE_DRIVERS or SOFTWARE_DRIVERS",
                )
            )

    for row in bom_rows:
        ref = row.get("Reference Designator") or row.get("Manufacturer Part Number", "?")
        dist = row.get("Distributor", "")
        sku = row.get("Distributor Part Number", "")
        if dist != PRIMARY_DISTRIBUTOR:
            findings.append(
                _waive(
                    "single-distributor",
                    ref,
                    f"sourced from {dist or 'nobody'}; every part should be in the "
                    f"{PRIMARY_DISTRIBUTOR} cart",
                )
            )
        pattern = SKU_PATTERNS.get(dist)
        if pattern and not pattern.match(sku):
            findings.append(
                _waive("sku-format", ref, f"{dist} SKU {sku!r} doesn't match {pattern.pattern}")
            )
    return findings


def main(argv: list[str] | None = None) -> int:
    """CLI entry point: print findings, exit non-zero on any unwaived one."""
    root = Path(__file__).resolve().parents[2]
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--bom", type=Path, default=root / "BOM_CONSOLIDATED.csv")
    parser.add_argument("--esphome", type=Path, default=root / "esphome")
    args = parser.parse_args(argv)

    findings = audit(load_bom(args.bom), args.esphome)
    for finding in findings:
        print(finding)
    failures = [f for f in findings if not f.waived]
    print(f"{len(failures)} failure(s), {len(findings) - len(failures)} waived")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
