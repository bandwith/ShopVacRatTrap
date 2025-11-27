# Contributing

Thank you for your interest in contributing to the ShopVac Rat Trap project! This guide will help you get started with contributing code, documentation, or hardware designs.

## Ways to Contribute

<div class="grid cards" markdown>

-   :material-bug:{ .lg .middle } __Report Bugs__

    ---

    Found a problem? Let us know!

    [:octicons-arrow-right-24: Report Issue](https://github.com/bandwith/ShopVacRatTrap/issues/new)

-   :material-lightbulb:{ .lg .middle } __Suggest Features__

    ---

    Have an idea for improvement?

    [:octicons-arrow-right-24: Request Feature](https://github.com/bandwith/ShopVacRatTrap/discussions)

-   :material-code-braces:{ .lg .middle } __Contribute Code__

    ---

    Fix bugs or add features

    [:octicons-arrow-right-24: Pull Requests](https://github.com/bandwith/ShopVacRatTrap/pulls)

-   :material-book-edit:{ .lg .middle } __Improve Docs__

    ---

    Help make documentation better

    [:octicons-arrow-right-24: Edit Documentation](https://github.com/bandwith/ShopVacRatTrap/tree/main/docs)

</div>

## Quick Start

1. **Fork the Repository**
   ```bash
   # On GitHub, click "Fork" button
   git clone https://github.com/YOUR_USERNAME/ShopVacRatTrap.git
   cd ShopVacRatTrap
   ```

2. **Create a Branch**
   ```bash
   git checkout -b feature/my-new-feature
   ```

3. **Make Changes**
   - Edit code, docs, or hardware designs
   - Follow code style guidelines
   - Add tests if applicable

4. **Test Your Changes**
   ```bash
   # Python tests
   pytest

   # ESPHome validation
   esphome config esphome/rat-trap.yaml

   # Pre-commit hooks
   pre-commit run --all-files
   ```

5. **Submit Pull Request**
   ```bash
   git push origin feature/my-new-feature
   # Then create PR on GitHub
   ```

## Development Setup

See [Development Setup](development.md) for detailed instructions on:

- Setting up Python environment
- Installing ESPHome
- Configuring pre-commit hooks
- Running tests locally

## Code Style

The project uses automated code formatting and lint King:

### Python
- **Formatter**: `ruff format`
- **Linter**: `ruff check`
- **Standards**: PEP 8, type hints required, docstrings required

### YAML
- **Formatter**: `yamlfmt`
- **Linter**: `yamllint`
- **Note**: ESPHome YAML excluded from generic checks

### Markdown
- **Linter**: `markdownlint`
- **Line length**: 120 characters recommended

### OpenSCAD
- Modular, parameterized designs
- Clear comments
- Descriptive naming

**All checks run automatically via pre-commit hooks.**

## Pull Request Guidelines

### Good PR Checklist

- [ ] Descriptive title
- [ ] Clear description of changes
- [ ] Links to related issues
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] Pre-commit hooks pass
- [ ] No merge conflicts

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Hardware design change

## Testing
How were these changes tested?

## Checklist
- [ ] Code follows style guidelines
- [ ] Tests pass
- [ ] Documentation updated
```

## Areas for Contribution

### Hardware

- Alternative sensor configurations
- Improved 3D printable designs
- Power supply optimizations
- International voltage support
- Professional enclosure options

### Software

- ESPHome configuration improvements
- Home Assistant dashboard examples
- New automation ideas
- Testing procedures
- Camera variant enhancements

### Documentation

- Tutorial videos
- Wiring diagrams
- Troubleshooting guides
- Translation to other languages
- Build logs and experiences

### Testing

- Hardware compatibility testing
- ESPHome version compatibility
- Performance benchmarking
- Safety validation

## Getting Help

- **Questions**: [GitHub Discussions](https://github.com/bandwith/ShopVacRatTrap/discussions)
- **Chat**: [ESPHome Discord](https://discord.gg/KhAMKrd)
- **Email**: Open an issue for contact

## Code of Conduct

Be respectful and inclusive. We're all here to learn and build something cool together.

## License

By contributing, you agree that your contributions will be licensed under Apache 2.0.

---

Ready to contribute? Check out [open issues](https://github.com/bandwith/ShopVacRatTrap/issues) or start with the [development setup](development.md)!
