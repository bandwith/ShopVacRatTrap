# Code Style Guide

This document outlines the coding standards and style guidelines for the ShopVac Rat Trap project.

## Python

### General Principles

- **PEP 8 Compliance**: Follow [PEP 8](https://pep8.org/) style guide
- **Type Hints**: Required for all function signatures
- **Docstrings**: Required for all public functions, classes, and modules
- **Line Length**: 100 characters (configured in ruff)

### Formatting

We use `ruff` for both linting and formatting:

```bash
# Format code
ruff format .

# Check for issues
ruff check .

# Auto-fix issues
ruff check --fix .
```

### Type Hints

```python
# Good
def calculate_power(voltage: float, current: float) -> float:
    """Calculate power consumption.

    Args:
        voltage: Supply voltage in volts
        current: Current draw in amps

    Returns:
        Power in watts
    """
    return voltage * current

# Bad - no type hints or docstring
def calculate_power(voltage, current):
    return voltage * current
```

### Docstrings

Use Google-style docstrings:

```python
def validate_bom(bom_file: str, priority_components: list[str] = None) -> dict:
    """Validate Bill of Materials against Mouser API.

    Checks component availability, pricing, and lifecycle status.
    Priority components generate alerts if unavailable.

    Args:
        bom_file: Path to BOM CSV file
        priority_components: List of critical part numbers

    Returns:
        Dictionary containing validation results:
            - available: List of available components
            - unavailable: List of unavailable components
            - price_changes: Dict of components with price changes

    Raises:
        BOMManagerError: If BOM file is invalid or API fails

    Example:
        >>> results = validate_bom("BOM.csv", ["ESP32-S3"])
        >>> print(results['available'])
    """
    # Implementation
```

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Module | snake_case | `bom_manager.py` |
| Class | PascalCase | `BOMValidator` |
| Function | snake_case | `validate_component()` |
| Variable | snake_case | `part_number` |
| Constant | UPPER_SNAKE_CASE | `MAX_RETRIES` |
| Private | _leading_underscore | `_internal_method()` |

### Imports

```python
# Standard library first
import os
import sys
from pathlib import Path

# Third-party packages
import pandas as pd
import requests

# Local modules
from bom_manager import BOMValidator
from mouser_api import MouserAPIClient
```

## YAML

### ESPHome Configuration

```yaml
# Use descriptive names
sensor:
  - platform: template
    name: "ESP32 Temperature"  # Clear, human-readable
    id: esp32_temp              # snake_case for IDs

# Group related items
binary_sensor:
  # Detection sensors
  - platform: template
    name: "PIR Motion"
    id: pir_detection

  - platform: template
    name: "ToF Detection"
    id: tof_detection

  # Safety sensors
  - platform: gpio
    name: "Emergency Stop"
    id: emergency_stop

# Comment complex logic inline
lambda: |-
  // Check if 2 of 3 sensors are triggered
  int active_sensors = 0;
  if (id(apds_detection).state) active_sensors++;
  if (id(tof_detection).state) active_sensors++;
  if (id(pir_detection).state) active_sensors++;
  return active_sensors >= 2;  // Trigger threshold
```

### Formatting

- **Indentation**: 2 spaces (no tabs)
- **Line Length**: 120 characters
- **Comments**: Use `#` for YAML, `//` for lambda C++

## OpenSCAD

### Naming Conventions

```openscad
// Constants: UPPER_SNAKE_CASE
TUBE_DIAMETER = 101.6;
WALL_THICKNESS = 4;

// Parameters: snake_case
tube_outer_diameter = 101.6;
flange_thickness = 5;

// Modules: snake_case
module trap_body_main() {
    // Implementation
}

// Local variables: snake_case
local_offset_x = 25;
```

### Structure

```openscad
// 1. Header comment
// ShopVac Rat Trap - Component Name
// Description of what this file creates

// 2. Includes
include <trap_modules.scad>

// 3. Parameters (grouped logically)
// [Dimensions]
body_length = 250;
body_diameter = 102;

// [Features]
include_sensor_mount = true;
alignment_pins = true;

// 4. Modules (reusable functions)
module alignment_pin(diameter, length) {
    cylinder(d=diameter, h=length, $fn=20);
}

// 5. Main geometry
module trap_component() {
    // Build the component
}

// 6. Assembly call
trap_component();
```

### Documentation

```openscad
// Module documentation
// Creates a flanged connection joint
//
// Parameters:
//   outer_diameter - Flange diameter in mm
//   thickness - Flange thickness in mm
//   screw_holes - Number of mounting holes (default: 4)
module flange(outer_diameter, thickness, screw_holes=4) {
    // Implementation
}
```

### Best Practices

- **Modularity**: Break complex designs into reusable modules
- **Parametric**: Use variables, not magic numbers
- **$fn**: Set explicitly for cylinders (`$fn=100` for final, `$fn=20` for draft)
- **Comments**: Explain **why**, not what
- **Units**: Always millimeters, note in comments if different

## Markdown

### Documentation Files

```markdown
# Title (H1 - one per document)

Brief description paragraph.

## Section (H2 - major sections)

### Subsection (H3 - topics)

#### Detail (H4 - specifics)

**Bold** for emphasis, *italic* for terms

`code` for inline code/commands

- List items
- Use hyphens

1. Numbered lists
2. For sequences

> **⚠️ Warning**
> Important safety information

[Link text](relative/path.md)

![Image caption](/absolute/path/image.png)
```

### Line Length

- **Hard limit**: 120 characters
- **Paragraphs**: Break at sentence boundaries
- **Lists**: Keep items concise

### Links

```markdown
# Good
See [Component Sourcing](../hardware/sourcing.md)

# Bad (absolute paths)
See [Component Sourcing](/docs/hardware/sourcing.md)

# Bad (bare URLs)
See https://github.com/...
```

## Git Commits

### Commit Messages

```
type(scope): Brief description

Longer explanation if needed. Wrap at 72 characters.
Explain what and why, not how.

Fixes #123
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Formatting (no code change)
- `refactor`: Code restructure (no behavior change)
- `test`: Adding tests
- `chore`: Build/tooling changes

**Examples:**

```
feat(3d-models): Split trap body for standard build plates

The trap_body_main was 250mm, exceeding common 220x220mm build
plates. Split into trap_body_front and trap_body_rear with
flanged joint, alignment pins, and O-ring seal.

Fixes #45
```

```
docs(readme): Streamline to project gateway

Moved detailed content to Read the Docs site. README now
serves as quick overview with prominent docs link.
```

## Pre-commit Hooks

All code quality checks run automatically via pre-commit:

```bash
# Install hooks
pre-commit install

# Run manually
pre-commit run --all-files

# Update hooks
pre-commit autoupdate
```

**Configured checks:**
- `ruff-check` - Python linting
- `ruff-format` - Python formatting
- `yamllint` - YAML linting
- `yamlfmt` - YAML formatting
- `markdownlint` - Markdown linting
- `detect-secrets` - Prevent credential commits
- `trailing-whitespace` - Clean whitespace
- `end-of-file-fixer` - Ensure newlines

## Testing

### Python Tests

```python
import pytest
from bom_manager import BOMValidator

def test_validate_component_success():
    """Test successful component validation."""
    validator = BOMValidator()
    result = validator.validate("ESP32-S3")
    assert result["available"] is True
    assert result["price"] > 0

def test_validate_component_not_found():
    """Test handling of missing component."""
    validator = BOMValidator()
    with pytest.raises(ComponentNotFoundError):
        validator.validate("INVALID-PART")
```

**Guidelines:**
- One assertion per test (when possible)
- Descriptive test names
- Test edge cases and errors
- Use fixtures for common setup

## Documentation Standards

### README Files

Every directory with code should have a README.md explaining:
- Purpose of the directory
- Key files and their roles
- How to use/build
- Dependencies

### Code Comments

```python
# Good - explains why
# Use Mouser API instead of Nexar for better pricing accuracy
price = mouser_api.get_price(part_number)

# Bad - states the obvious
# Get the price
price = mouser_api.get_price(part_number)
```

### TODO Comments

```python
# TODO(username): Description of what needs to be done
# TODO(bandwith): Add retry logic for API failures
```

## Enforcement

- **Pre-commit hooks**: Block commits that violate standards
- **CI/CD**: Run all checks on pull requests
- **Code review**: Maintainers verify compliance

## Resources

- [PEP 8](https://pep8.org/) - Python style guide
- [Google Python Style Guide](https://google.github.io/styleguide/pyguide.html)
- [ruff Documentation](https://docs.astral.sh/ruff/)
- [ESPHome Style Guide](https://esphome.io/guides/contributing.html#code-style)

---

When in doubt, follow the existing code style in the project!
