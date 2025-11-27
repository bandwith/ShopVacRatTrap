# ShopVac Rat Trap

> **⚠️ Work in Progress ⚠️**
>
> This project is under active development. Documentation, features, and hardware## ✨ Project Status

**Current:** Ready for production printing (2025-11-27)

**Recent Updates:**
- ✅ Flat ramp entrance (no supports needed)
- ✅ Integrated cable channels (rodent-proof routing)
- ✅ BOM validated (14 components verified)
- ✅ Complete assembly visualization

## 🎯 Overview

This project provides complete design files for a professional-grade, IoT-enabled rodent trap system that connects to a standard shop vacuum. Features automated detection using multiple sensors and safe high-voltage switching.

**Key Features:**
- Multi-sensor detection (VL53L0X ToF, APDS9960 proximity, PIR motion)
- ESPHome-based ESP32-S3 control
- Solid-state relay for safe AC switching
- Integrated cable protection (no external conduit needed)
- 3D printable components (PETG/ASA)
- Optional camera integration (OV5640)tion

**Complete documentation:** [Read the Docs](https://shopvac-rat-trap.readthedocs.io) _(coming soon)_

**Local preview:**
```bash
{{ ... }}
```

### Quick Links

- [🚨 Safety First](docs/getting-started/safety.md) - **Read before starting**
- [⚡ Quick Start](docs/getting-started/quick-start.md) - Build in 5 steps
- [🛒 Components](docs/hardware/bom.md) - Bill of Materials (~$150)
- [🔧 Assembly](docs/hardware/assembly.md) - Step-by-step guide
- [🏠 Home Assistant](docs/software/home-assistant.md) - Integration examples

## ✨ Features

- **🎯 Hybrid Detection**: APDS9960 + VL53L0X + PIR ("2 of 3" confirmation)
- **📸 5MP Camera**: Optional OV5640 with autofocus (camera variant)
- **🔌 Zero-Solder**: Complete STEMMA QT plug-and-play assembly
- **📊 OLED Display**: 128x64 integrated status screen
- **🏠 ESPHome**: Native Home Assistant integration
- **⚡ Safety**: NEC/IEC compliant with multiple protection layers
- **🌍 Global**: 120V/230V configurations

## 🚀 Quick Start

```bash
# 1. Clone and setup
git clone https://github.com/bandwith/ShopVacRatTrap.git
cd ShopVacRatTrap

# 2. Order components (see docs/hardware/sourcing.md)

# 3. 3D print parts
python .github/scripts/build.py --build  # Generate STLs
# Print with PETG/ASA, 0.2mm layers, 40% infill

# 4. Flash firmware
cd esphome
cp secrets.yaml.example secrets.yaml  # Add WiFi credentials
esphome run rat-trap.yaml
```

**Full guide:** [Quick Start Documentation](docs/getting-started/quick-start.md)

## 💰 Cost Estimate

| Configuration | Components | Total |
|---------------|------------|-------|
| **Standard** | ESP32 + Sensors + Display + Power + Safety | ~$183 |
| **+ Camera** | Adds OV5640 + IR LED + SD Card | ~$204 |

**Detailed BOM:** [Component Sourcing Guide](docs/hardware/sourcing.md)

## 🔐 Safety

**⚠️ This project involves 120V/230V AC electrical connections.**

**Requirements:**
- Understanding of AC electrical safety
- Knowledge of NEC/IEC electrical codes
- Proper safety equipment (PPE)
- Licensed electrician for AC wiring (if not qualified)

**Read the [Safety Guidelines](docs/getting-started/safety.md) before proceeding.**

## 📖 Documentation Structure

| Document | Purpose |
|----------|---------|
| [Getting Started](docs/getting-started/index.md) | Safety, overview, quick start |
| [Hardware](docs/hardware/index.md) | BOM, sourcing, electrical, assembly |
| [Software](docs/software/index.md) | ESPHome, testing, Home Assistant |
| [Reference](docs/reference/index.md) | Troubleshooting, FAQ, glossary |
| [Contributing](docs/contributing/index.md) | How to contribute, code style |

## 🤝 Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

**Quick setup:**
```bash
# Install dependencies
uv venv && source .venv/bin/activate
uv pip install -r requirements.txt

# Install pre-commit hooks
pre-commit install
```

**Code style:** [Contributing Guide](docs/contributing/code-style.md)

## 📜 License

Licensed under the Apache License 2.0 - see [LICENSE](LICENSE) file.

## ⚠️ Legal Disclaimer

**IMPORTANT:** This project is for educational and experimental purposes only.

The vacuum-based rodent trap concept may be subject to patent protection. Before building, especially for commercial purposes:

1. Conduct thorough patent research
2. Consult with a patent attorney

The authors provide this design "as is" without warranty and assume no liability for legal issues arising from its use.

## 🙏 Credits

- **Inspiration**: [Shop Rodent Stoppers Rat Vac](https://shoprodentstoppers.com/products/rat-vac-motion-sensor-rodent-catching-systems)
- **Forked From**: [shellster/ShopVacRatTrap](https://github.com/shellster/ShopVacRatTrap)

## 📞 Support

- **Documentation**: [Read the Docs](https://shopvac-rat-trap.readthedocs.io)
- **Issues**: [GitHub Issues](https://github.com/bandwith/ShopVacRatTrap/issues)
- **Discussions**: [GitHub Discussions](https://github.com/bandwith/ShopVacRatTrap/discussions)
- **Community**: [Home Assistant](https://community.home-assistant.io) | [ESPHome Discord](https://discord.gg/KhAMKrd)

---

**Ready to build?** → [Quick Start Guide](docs/getting-started/quick-start.md)
