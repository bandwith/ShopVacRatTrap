# ShopVac Rat Trap 2025 - Quick Start Guide

This guide focuses on the cost-optimized build process using the latest 2025 design improvements.

Quick Start Guide
=================

> **Note:** For all purchasing details, vendor part numbers, and direct links, see [purchasing/PURCHASE_GUIDE.md](purchasing/PURCHASE_GUIDE.md).

## Essential Components
- ESP32-S3 Feather (Adafruit 5323)
- VL53L0X ToF Sensor STEMMA QT (Adafruit 4210)
- OLED Display 128x64 STEMMA QT (Adafruit 5027)
- BME280 Environmental Sensor STEMMA QT (Adafruit 4816)
- LiPo Battery 2500mAh (Adafruit 1578)
- STEMMA QT Cables (Adafruit 4397, 4399)
- Solid State Relay 25A (SparkFun COM-14456)
- Large Arcade Button (Adafruit 368)
- 5V Power Supply (Mean Well LRS-35-5)
- Project Enclosure (Bud Industries PN-1334-C)
- IEC Inlet & AC Outlet (Schurter & Leviton)
- Circuit protection & wiring components

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
120V AC → IEC Inlet → Circuit Breaker → Mean Well LRS-35-5 PSU → 5V → ESP32-S3 → 3.3V → Sensors

CONTROL SIGNALS:
ESP32-S3 → GPIO5 → SSR → Vacuum Outlet
ESP32-S3 → GPIO0 → Emergency Stop Button
ESP32-S3 → GPIO21/22 → STEMMA QT I2C Bus → Sensors & Display
```

## Configuration Quick Reference

### Default ESPHome Configurations
- Default detection threshold: 150mm
- Default vacuum runtime: 8 seconds
- Default cooldown period: 30 seconds
- WiFi fallback hotspot: "RatTrap2025 Fallback"

### Power Budget
- ESP32-S3 + peripherals: ~99mA @ 3.3V (0.33W)
- Mean Well LRS-35-5 capacity: 7A @ 5V (35W) - ample headroom
- LiPo backup: 25+ hours runtime at full load

### Documentation Resources
- [README.md](README.md) - Project overview and features
- [ELECTRICAL_DESIGN.md](ELECTRICAL_DESIGN.md) - Comprehensive BOM and electrical specifications
- [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md) - Detailed assembly instructions
- [SAFETY_REFERENCE.md](SAFETY_REFERENCE.md) - Complete safety guidelines
