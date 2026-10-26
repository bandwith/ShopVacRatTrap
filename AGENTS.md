# Agent Instructions

## Package Manager
- Use **uv**: `uv sync` (add `--group firmware` for ESPHome or `--group docs` for MkDocs).

## Commands
| Task | Command |
|------|---------|
| Test Python file | `uv run pytest path/to/test_file.py` |
| Test 3D models | `uv run pytest tests/test_3d_models.py` |
| Test C++ detection logic | `g++ -std=c++17 -I esphome/packages tests/firmware/test_detection_logic.cpp -o /tmp/test_det && /tmp/test_det` |
| Test C++ rodent classifier | `g++ -std=c++17 -I tests/firmware/stubs -I esphome/components/rodent_classifier tests/firmware/test_rodent_classifier.cpp -o /tmp/test_rc && /tmp/test_rc` |
| Lint Python file | `uv run ruff check --fix path/to/file.py` |
| Format Python file | `uv run ruff format path/to/file.py` |
| Run git hooks on file | `uv run prek run --files path/to/file` |
| Render single SCAD to STL | `python .github/scripts/build.py --build 3d_models/part.scad` |
| Validate ESPHome config | `uv run --group firmware esphome config esphome/rat-trap.yaml` |

## External References
| Need | File |
|------|------|
| Setup & workflow | `docs/contributing/development.md` |
| Code style | `docs/contributing/code-style.md` |
| System overview | `docs/getting-started/overview.md` |
| Electrical safety | `docs/getting-started/safety.md` |
| Electrical & AC/DC wiring | `docs/hardware/electrical.md` |
| Sensor detection logic | `docs/hardware/sensor-logic.md` |
| BOM & component sourcing | `docs/hardware/sourcing.md` |
| 3D model specs & assembly | `3d_models/README.md` |
| ESPHome firmware architecture | `docs/software/esphome-config.md` |
| Automation scripts | `.github/scripts/README.md` |

## Key Conventions
- Generated STL files (`3d_models/*.stl`) and `3d_models/build_report.md`: regenerate with `python .github/scripts/build.py --build <file.scad>` whenever a `.scad` file changes; do not edit `.stl` files by hand.
- Shared OpenSCAD libraries (`3d_models/trap_modules.scad`, `3d_models/helpers.scad`) must define only modules/constants and produce no top-level geometry.
- Printable parts in `3d_models/` must be single watertight 2-manifold solids resting on `z = 0` in their supportless print orientation and assemble horizontally along `+X` in `3d_models/assembly.scad`.
- Dependency changes: edit `pyproject.toml` and run `uv lock`; commit `pyproject.toml` and `uv.lock` together.
- Stage newly created files (`git add`) before running `uv run prek run --all-files` so hooks inspect them.
- GitHub CLI (`gh`) commands must pass `--repo bandwith/ShopVacRatTrap` explicitly because the repository is a fork of `shellster/ShopVacRatTrap`.
