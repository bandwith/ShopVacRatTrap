# Contributing to the ShopVac Rat Trap 2025 Project

First off, thank you for considering contributing to this project! We welcome any contributions that improve the design, functionality, and documentation.

This document provides guidelines for contributing to the project. Please read it carefully to ensure a smooth and effective contribution process.

## How to Contribute

We welcome contributions in several forms:
- **Bug Reports**: If you find a bug in the design, code, or documentation, please [create an issue](https://github.com/your-repo/link/issues).
- **Feature Requests**: If you have an idea for a new feature or an improvement to an existing one, please [create an issue](https://github.com/your-repo/link/issues) to discuss it first.
- **Pull Requests**: If you've fixed a bug or implemented a new feature, we welcome pull requests.

## Getting Started

To get started, you'll need to fork the repository and clone it to your local machine:
```bash
git clone https://github.com/your-username/ShopVac-Rat-Trap-2025.git
cd ShopVac-Rat-Trap-2025
```

### Development Environment

The project has two main parts: the OpenSCAD 3D models and the Python scripts for automation.

#### OpenSCAD
- **Installation**: Download and install [OpenSCAD](https://openscad.org/downloads.html) for your operating system.
- **Usage**: You can open the `.scad` files in the `3D Models/` directory to view and modify the designs. The main assembly files are `Complete_System_Assembly.scad` (for visualization) and `Complete_Trap_Tube_Assembly.scad` (for the main printable part).

#### Python Scripts
The Python scripts are used for BOM management and other automation tasks.
- **Virtual Environment**: We recommend using a Python virtual environment to manage dependencies.
  ```bash
  python -m venv .venv
  source .venv/bin/activate  # On Windows, use `.venv\Scripts\activate`
  ```
- **Dependencies**: Install the required dependencies using `pip`:
  ```bash
  python -m pip install --upgrade pip
  pip install -r requirements.txt
  ```

## Coding Conventions

### OpenSCAD
- **Modularity**: Strive to create small, reusable modules. Complex components should be broken down into smaller parts.
- **Parameterization**: Use variables for dimensions, tolerances, and other key parameters. This makes the designs easier to customize and maintain.
- **Comments**: Add comments to explain complex geometric operations or design choices.
- **Naming**: Use descriptive names for variables and modules (e.g., `latch_arm_thickness` instead of `lat`).

### Python
- **Style**: Follow the [PEP 8](https://www.python.org/dev/peps/pep-0008/) style guide.
- **Type Hinting**: Use type hints for function arguments and return values.
- **Docstrings**: Add docstrings to all modules, classes, and functions to explain their purpose.

## Running Tests

The project uses `pytest` for testing the Python scripts.
- **Run Tests**: To run the tests, simply run `pytest` from the root directory:
  ```bash
  pytest
  ```
- **Adding Tests**: If you add new functionality to a Python script, please add corresponding tests in the relevant `test_*.py` file.

## Submitting Pull Requests

When you are ready to submit a pull request, please follow these steps:
1.  **Create a new branch** for your changes:
    ```bash
    git checkout -b feature/my-new-feature
    ```
2.  **Make your changes** and commit them with a clear and descriptive commit message.
3.  **Push your branch** to your fork:
    ```bash
    git push origin feature/my-new-feature
    ```
4.  **Open a pull request** from your fork to the main repository.
5.  **In the pull request description**, explain the changes you've made and why. If your pull request addresses an open issue, please reference it (e.g., "Fixes #123").

Thank you for your contributions!
