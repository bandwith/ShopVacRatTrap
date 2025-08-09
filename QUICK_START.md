# ShopVac Rat Trap 2025 - Quick Start Guide

This guide focuses on the cost-optimized build process using the latest 2025 design improvements.

> **Note:** For all purchasing details, vendor part numbers, and direct links, see [BOM_OCTOPART.csv](BOM_OCTOPART.csv) and [PURCHASE_LINKS.md](PURCHASE_LINKS.md).

## Essential Components
- ESP32 DevKit
- VL53L1X ToF Sensor
- OLED Display 128x64 SSD1306
- BME280 Environmental Sensor
- Solid State Relay 25A
- Illuminated E-Stop Button
- Power Supply (LRS-35-5 recommended)
- Enhanced IEC Inlet w/ Fuse & Switch
- NEMA 5-15R Outlet
- DIN terminal blocks
- Wiring & hardware

## Assembly Overview

This is a simplified assembly overview. For detailed step-by-step instructions including safety procedures, wiring diagrams, and testing protocols, please refer to the [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md) document.

1. **Prepare Enclosure**
   - Print 3D enclosure and sensor housing components
   - Install mounting hardware

2. **Install Components**
   - Mount electrical components (IEC inlet, outlet, ESP32, etc.)
   - Wire AC section following safety guidelines
   - Connect low-voltage components

3. **Flash & Test**
   - Flash `rat-trap-2025.yaml` firmware
   - Perform safety verification
   - Test functionality

## Connection Overview

For the complete wiring diagrams and detailed electrical schematics, please refer to the [ELECTRICAL_DESIGN.md](ELECTRICAL_DESIGN.md) document. Here's a simplified overview of the core connections:

```
POWER FLOW:
IEC Inlet → Power Supply → ESP32 → Sensors & Controls

CONTROL SIGNALS:
ESP32 → GPIO5 → SSR → Vacuum
ESP32 → GPIO4/17 → Illuminated E-Stop Button
ESP32 → GPIO21/22 → I2C Bus (Sensors & Display)
```

## Configuration Quick Reference

### Default ESPHome Configurations
- Default detection threshold: 150mm
- Default vacuum runtime: 8 seconds
- Default cooldown period: 30 seconds
- WiFi fallback hotspot: "RatTrap2025 Fallback"

### Power Budget
- ESP32 + peripherals: ~160mA @ 5V (0.80W)
- LRS-35-5 capacity: 7A @ 5V (35W) - ample headroom

### Documentation Resources
- [README.md](README.md) - Project overview and features
- [ELECTRICAL_DESIGN.md](ELECTRICAL_DESIGN.md) - Comprehensive BOM and electrical specifications
- [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md) - Detailed assembly instructions
- [SAFETY_REFERENCE.md](SAFETY_REFERENCE.md) - Complete safety guidelines
