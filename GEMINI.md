> **⚠️ Work in Progress ⚠️**
>
> This project is under active development. The documentation, features, and hardware recommendations are subject to change. Please check back for updates.

# Project Overview: ShopVac Rat Trap

This project implements a professional-grade, IoT-based rodent control system. It features a hybrid sensor detection system, an integrated status display, and is designed for simplified assembly.

## Key Technologies:
*   **Hardware:** ESP32-S3 Feather, various STEMMA QT sensors (APDS9960, VL53L0X, PIR, OV5640 camera), OLED display.
*   **Firmware:** ESPHome for ESP32 configuration and logic.
*   **Software:** Python for Bill of Materials (BOM) management, component sourcing automation, and other utility scripts.
*   **3D Modeling:** OpenSCAD for designing 3D printable enclosures and trap components.
*   **Automation:** GitHub Actions for continuous integration, BOM validation, and automated pricing updates.

## Architecture:
The system employs a multi-sensor detection logic ("2 of 3" sensor confirmation) to minimize false positives. The ESPHome configuration is modularized for maintainability. The electrical design adheres to NEC/IEC safety standards. Automated workflows handle BOM validation, component availability checks, and pricing updates, including creating GitHub issues for critical changes.

# Building and Running

## Prerequisites:
*   Electrical safety knowledge (for AC wiring).
*   Access to a 3D printer.
*   ESPHome development environment.
*   Basic electronics assembly skills.

## Python Environment Setup:
The project uses Python for various scripts, particularly for BOM management.
1.  **Create a virtual environment:**
    ```bash
    uv venv
    ```
2.  **Activate the virtual environment:**
    *   On Linux/macOS:
        ```bash
        source .venv/bin/activate
        ```
    *   On Windows:
        ```bash
        .venv\Scripts\activate
        ```
3.  **Install dependencies:**
    ```bash
    uv pip install -r requirements.txt
    ```

## ESPHome Firmware:
The ESPHome configurations define the device's behavior and sensor logic.
*   **Standard Configuration:** `esphome/rat-trap-.yaml`
*   **Camera Variant Configuration:** `esphome/rat-trap-stemma-camera.yaml`
To build and flash the firmware, you will need to use the ESPHome command-line tool or dashboard, following standard ESPHome procedures.

## Testing:
*   **Python Tests:** Unit tests for Python scripts are written using `pytest`.
    To run all Python tests from the project root:
    ```bash
    pytest
    ```
*   **Automated Testing:** GitHub Actions workflows (e.g., `bom-validation.yml`) automatically run tests as part of the CI/CD pipeline.

# Development Conventions

## Code Quality and Formatting:
The project enforces code quality and formatting using pre-commit hooks:
*   **Python:** `ruff-check` (linting) and `ruff-format` (formatting), adhering to PEP 8, type hinting, and requiring docstrings.
*   **YAML:** `yamllint` and `yamlfmt` for linting and formatting YAML files. ESPHome YAML files are specifically excluded from generic YAML checks due to their unique syntax.
*   **General:** Hooks for trailing whitespace, end-of-file newlines, and checking JSON/TOML files.
*   **OpenSCAD:** Emphasis on modularity, parameterization, clear comments, and descriptive naming for 3D models.
*   **Python Syntax:** `pyupgrade` ensures Python 3.11+ syntax.

## Security:
*   The `detect-secrets` pre-commit hook is used to prevent sensitive information from being committed to the repository.

## Dependency Management:
*   `uv compile` pre-commit hooks are used to manage and synchronize `requirements.txt` with `requirements.in`.

## Automated Processes:
*   **GitHub Actions:** Extensive use of GitHub Actions for:
    *   Scheduled BOM validation and monitoring.
    *   Automated pricing updates for components via Mouser API.
    *   Generation of purchase files.
    *   Creation of GitHub issues for component availability and significant price changes.

## Contribution Workflow:
Contributions are welcomed via a standard fork-and-pull request model. Contributors are expected to:
1.  Fork the repository and clone it locally.
2.  Create a new branch for their changes.
3.  Make changes and commit with clear, descriptive messages.
4.  Push the branch to their fork.
5.  Open a pull request, explaining the changes and referencing any relevant issues.
6.  Add corresponding tests for new Python functionality.
