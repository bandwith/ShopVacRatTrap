> **⚠️ Work in Progress ⚠️**
>
> This project is under active development. The documentation, features, and hardware recommendations are subject to change. Please check back for updates.

# GitHub Scripts for ShopVac Rat Trap

This directory contains automation scripts for the ShopVac Rat Trap project.

## STL Generation (`build.py`)

Generates STL files and the build report (`3d_models/build_report.md`) from OpenSCAD sources in `3d_models/`.

**Usage:**

```bash
# Build all printable 3D models and regenerate 3d_models/build_report.md
python .github/scripts/build.py --build

# Build specific SCAD files
python .github/scripts/build.py --build 3d_models/bait_cap.scad

# Query changed or missing SCAD files (JSON output used by CI)
python .github/scripts/build.py --get-changed-files
python .github/scripts/build.py --get-missing-files
python .github/scripts/build.py --get-all-files

# Regenerate 3d_models/build_report.md only
python .github/scripts/build.py --generate-report
```

## BOM Management (`bom_manager.py` & `mouser_api.py`)

Consolidated tooling for Bill of Materials (BOM) validation, pricing updates, and purchase file generation via the Mouser API:

- **`bom_manager.py`**: Validates component pricing/availability, updates `BOM_CONSOLIDATED.csv`, emits structured validation summaries (`purchasing/validation_summary.json`), and generates Mouser upload templates and `PURCHASE_GUIDE.md`.
- **`mouser_api.py`**: Mouser Electronics Search API v1 client with retry/backoff, part number normalization, and price break selection.
- **`backup_bom.sh`**: Retains the 5 most recent timestamped backups of `BOM_CONSOLIDATED.csv` in `pricing_backup/`.
- **`config.json`**: Vendor prefix mappings and priority component MPNs.

**Usage:**

```bash
# Full validation, pricing update, and purchase file generation
python .github/scripts/bom_manager.py --bom-file BOM_CONSOLIDATED.csv --output-dir purchasing --all

# Individual operations
python .github/scripts/bom_manager.py --bom-file BOM_CONSOLIDATED.csv --validate --check-availability
python .github/scripts/bom_manager.py --bom-file BOM_CONSOLIDATED.csv --update-pricing
python .github/scripts/bom_manager.py --bom-file BOM_CONSOLIDATED.csv --generate-purchase-files
python .github/scripts/bom_manager.py --bom-file BOM_CONSOLIDATED.csv --generate-mouser-template
python .github/scripts/bom_manager.py --bom-file BOM_CONSOLIDATED.csv --generate-mouser-only
```

## Workflow Integration

- **STL Generation (`.github/workflows/stl-generation.yml`)**: Triggered when `3d_models/*.scad` files change without corresponding `.stl` updates, or via manual dispatch. Rebuilds affected `.stl` files, validates manifold geometry and print orientation via `pytest tests/test_3d_models.py`, and opens a pull request.
- **BOM Validation & Monitoring (`.github/workflows/bom-validation.yml`)**: Runs weekly on Mondays at 9 AM UTC, on BOM changes pushed to `main`, or via manual dispatch. Validates pricing and stock levels, opens/updates GitHub issues for critical alerts, and opens a pull request when BOM pricing changes.

## Local Development

1. **Install dependencies with `uv`:**
   ```bash
   uv sync
   source .venv/bin/activate
   ```
2. **Configure Mouser API key (for live BOM queries):**
   ```bash
   cp .env.example .env
   # Set MOUSER_API_KEY in .env
   ```
3. **Run unit tests:**
   ```bash
   pytest
   ```
