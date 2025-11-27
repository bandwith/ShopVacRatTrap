# Getting Started

Welcome to the ShopVac Rat Trap documentation! This section will help you understand the project and get started with building your own professional rodent control system.

## Choose Your Path

<div class="grid cards" markdown>

-   :material-book-open-page-variant:{ .lg .middle } __New to the Project?__

    ---

    Learn about the system architecture, features, and capabilities

    [:octicons-arrow-right-24: Project Overview](overview.md)

-   :material-alert:{ .lg .middle } __Safety First__

    ---

    **Required reading** before starting any work with electrical components

    [:octicons-arrow-right-24: Safety Guidelines](safety.md)

-   :material-rocket-launch:{ .lg .middle } __Ready to Build?__

    ---

    Fast-track guide to building and deploying your trap

    [:octicons-arrow-right-24: Quick Start Guide](quick-start.md)

</div>

## What You'll Need

### Skills & Knowledge

- **Required**: Basic electronics assembly skills
- **Required**: Understanding of AC electrical safety (for power section)
- **Recommended**: 3D printing experience
- **Recommended**: ESPHome/Home Assistant familiarity

### Tools & Equipment

- **Safety Equipment**: Insulated gloves, safety glasses, voltage tester
- **Electronics Tools**: Screwdrivers, wire strippers, multimeter
- **3D Printer**: Access to FDM printer (PETG/ASA recommended)
- **Computer**: For ESPHome configuration and flashing

### Time Investment

| Phase | Estimated Time |
|-------|----------------|
| Component Ordering | 1-2 weeks (shipping) |
| 3D Printing | 8-12 hours (print time) |
| Assembly | 2-4 hours |
| Software Setup | 1-2 hours |
| Testing & Calibration | 1-2 hours |
| **Total** | **2-3 weeks** |

## Project Configurations

### Standard Configuration

Basic trap with reliable ToF and PIR detection:

- **Cost**: ~$150
- **Sensors**: VL53L0X + PIR + APDS9960
- **Features**: Offline detection, Home Assistant integration
- **Recommended for**: Most users, reliable operation

[:octicons-arrow-right-24: Standard Build Guide](../hardware/assembly.md)

### Camera Configuration

Advanced trap with visual classification:

- **Cost**: ~$190 (+$40)
- **Sensors**: All standard sensors + OV5640 camera + IR LED
- **Features**: Visual evidence, TinyML classification
- **Recommended for**: Advanced users, visual confirmation needed

[:octicons-arrow-right-24: Camera Variant Guide](../hardware/assembly.md#camera-variant)

## Support Resources

### Documentation

- [Hardware Documentation](../hardware/index.md) - BOM, wiring, assembly
- [Software Guide](../software/index.md) - ESPHome configuration
- [Reference](../reference/index.md) - Troubleshooting and FAQ

### Community

- [GitHub Repository](https://github.com/bandwith/ShopVacRatTrap) - Source code and issues
- [ESPHome Discord](https://discord.gg/KhAMKrd) - ESPHome support
- [Home Assistant Community](https://community.home-assistant.io) - HA integration help

### Professional Help

!!! tip "When to Hire a Professional"
    Consider hiring a licensed electrician if:

    - You're not comfortable working with AC voltage
    - Local codes require licensed installation
    - You need electrical permit assistance
    - You want professional safety verification

## Next Steps

1. **Read the Safety Guidelines** - Understand electrical hazards and safety requirements
2. **Review the Overview** - Familiarize yourself with system architecture
3. **Check the BOM** - Review components and pricing
4. **Follow Quick Start** - Build your first trap!

---

<div style="text-align: center;">
    <p><strong>Ready to begin?</strong></p>
    <a href="safety/" class="md-button md-button--primary">Start with Safety →</a>
</div>
