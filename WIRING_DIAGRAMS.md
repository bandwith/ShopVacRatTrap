# ShopVac Rat Trap - Wiring Diagrams & Cable Management

## Overview

This document provides comprehensive wiring diagrams for the ShopVac Rat Trap 2025 system, including both the current daisy-chain setup and the improved hub-based configuration using the **Adafruit QWIIC/STEMMA QT 5-Port Hub (Product ID: 5625)**.

---

## Current Wiring Configuration (Daisy Chain)

### System Architecture Diagram
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           AC POWER SECTION (120V/230V)                         │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  [IEC Inlet]────[Circuit Protection]────[Mean Well PSU]                        │
│      │               │                        │                                │
│      │               │                        ├─ +5V ──────────────────────────┼─ ESP32 VIN
│      │               │                        ├─ GND ──────────────────────────┼─ Common GND
│      │               │                        │                                │
│  [Ground Bus]─────────┼────────────────────────┘                                │
│      │               │                                                         │
│  [AC Outlet]──────────┼─ [SSR Output]                                          │
│                       │      ↑                                                 │
│                   [15A Fuse]  │                                                 │
│                              │                                                 │
└──────────────────────────────┼─────────────────────────────────────────────────┘
                               │
┌──────────────────────────────┼─────────────────────────────────────────────────┐
│                    DC CONTROL SECTION (5V/3.3V)                │               │
├─────────────────────────────────────────────────────────────────┼───────────────┤
│                                                                 │               │
│  ┌─────────────────────┐    ┌──────────────────────────────────┐ │               │
│  │   ESP32-S3 Feather  │    │        I2C Daisy Chain           │ │               │
│  │                     │    │        (STEMMA QT)              │ │               │
│  │   ┌─────────────────┴┐   │                                 │ │               │
│  │   │ Built-in 3.3V   ││   │  ┌──────────┐ 100mm ┌─────────┐│ │               │
│  │   │ Regulator       ││───┼──┤VL53L0X   ├───────┤BME280   ││ │               │
│  │   │ 600mA capacity  ││   │  │ToF       │       │Env.     ││ │               │
│  │   └─────────────────┘│   │  │Sensor    │       │Sensor   ││ │               │
│  │                     │    │  │(0x29)    │       │(0x77)   ││ │               │
│  │  GPIO5 ──────────────┼────┼──┘          │       └─────────┘│ │               │
│  │       │              │    │             │                 │ │               │
│  │       │              │    │             │ 200mm           │ │               │
│  │  GPIO13 ─────────────┼────┼─ [Emergency │       ┌─────────┐│ │               │
│  │       │              │    │    Button]  └───────┤OLED     ││ │               │
│  │       │              │    │                     │Display  ││ │               │
│  │  GPIO21 (SDA) ───────┼────┼─────────────────────│(0x3C)   ││ │               │
│  │  GPIO22 (SCL) ───────┼────┼─────────────────────│         ││ │               │
│  │                     │    │                     └─────────┘│ │               │
│  └─────────────────────┘    └─────────────────────────────────┘ │               │
│            │                                                    │               │
│            │                  ┌─────────────────────────────────┘               │
│            │                  │                                                 │
│            │                  │  ┌─────────────────┐                           │
│            └──[4N35]──────────┼──┤ Solid State     │                           │
│               Optocoupler     │  │ Relay (40A)     │                           │
│                               │  │                 │                           │
│                               │  └─────────────────┘                           │
│                               │           │                                     │
└───────────────────────────────┘───────────┼─────────────────────────────────────┘
                                            │
                                    [Vacuum Control]
```

### I2C Device Chain Details
```
ESP32-S3 STEMMA QT Port (GPIO21/22)
    ↓ (100mm STEMMA QT Cable #1)
VL53L0X ToF Sensor (I2C Address: 0x29)
    ↓ (100mm STEMMA QT Cable #2)
BME280 Environmental Sensor (I2C Address: 0x77)
    ↓ (200mm STEMMA QT Cable #3)
OLED Display (I2C Address: 0x3C)
```

### Current Cable Requirements
| Component | Cable Type | Length | Quantity | Part Number |
|-----------|------------|--------|----------|-------------|
| ESP32 → VL53L0X | STEMMA QT | 100mm | 1 | Adafruit 4397 |
| VL53L0X → BME280 | STEMMA QT | 100mm | 1 | Adafruit 4397 |
| BME280 → OLED | STEMMA QT | 200mm | 1 | Adafruit 4399 |
| **Total** | | | **3** | **Mixed lengths** |

### Current Setup Limitations
- **Single Point of Failure**: If any cable in the chain fails, all downstream devices stop working
- **Voltage Drop**: Each connection adds resistance, reducing voltage to downstream devices
- **Complex Routing**: Long daisy-chain requires careful cable management through enclosure
- **Difficult Troubleshooting**: Hard to isolate individual device issues
- **Limited Expansion**: Adding devices requires extending the chain

---

## Improved Wiring Configuration (Hub-Based)

### System Architecture with QWIIC Hub in Inlet Area
```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           AC POWER SECTION (120V/230V)                         │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                 [Same as above]                                │
└──────────────────────────────┬─────────────────────────────────────────────────┘
                               │
┌──────────────────────────────┼─────────────────────────────────────────────────┐
│                    DC CONTROL SECTION (5V/3.3V)                │               │
├─────────────────────────────────────────────────────────────────┼───────────────┤
│                                                                 │               │
│  ┌─────────────────────┐                                        │               │
│  │   CONTROL BOX       │        INLET AREA COMPONENTS           │               │
│  │                     │        (Reduced Cable Runs)           │               │
│  │   ┌─────────────────┴┐       ┌─────────────────────────────┐ │               │
│  │   │ Built-in 3.3V   ││       │   QWIIC Hub at Inlet       │ │               │
│  │   │ Regulator       ││       │   (Adafruit 5625)          │ │               │
│  │   │ 600mA capacity  ││       │                            │ │               │
│  │   └─────────────────┘│       │  ┌─────────────┐           │ │               │
│  │                     │        │  │ 5-Port Hub  │           │ │               │
│  │  GPIO5 ──────────────┼────────┼──│             │           │ │               │
│  │       │              │        │  │ Port 1 ──── ┼ VL53L0X   │ │               │
│  │  GPIO13 ─────────────┼────────┼──│ Port 2 ──── ┼ BME280*   │ │               │
│  │       │              │        │  │ Port 3 ──── ┼ (Future)  │ │               │
│  │  GPIO21 (SDA) ───────┼────────┼──│ Port 4 ──── ┼ (Camera)  │ │               │
│  │  GPIO22 (SCL) ───────┼────────┼──│ Port 5 ──── ┼ (Future)  │ │               │
│  │                     │  |     │  │             │           │ │               │
│  │  ┌─────────────────┐ │  |     │  │ Upstream ── ┼ ESP32 ────┼─┼─ Single Cable │
│  │  │ OLED Display    │ │  |     │  └─────────────┘           │ │   to Control  │
│  │  │ (0x3C)          │ │  |     └─────────────────────────────┘ │   Box         │
│  │  └─────────────────┘ │  |                                    │               │
│  │                     │  |     * BME280 can be in either        │               │
│  │  ┌─────────────────┐ │  |       location based on needs       │               │
│  │  │ BME280 Env.     │ │  |                                    │               │
│  │  │ (Optional)      │ │  |                                    │               │
│  │  └─────────────────┘ │  |                                    │               │
│  └─────────────────────┘  |                                    │               │
│            │              |                                    │               │
│            │              └────────────────────────────────────┘               │
│            └──[4N35]──────────────────────────────────────────────────────────┘
│               Optocoupler
│                                  ┌─────────────────┐
│                                  │ Solid State     │
│                                  │ Relay (40A)     │
│                                  └─────────────────┘
```

### Optimized Component Placement Strategy
```
INLET AREA (At Pipe Detection Point):
├─ QWIIC/STEMMA QT 5-Port Hub (Adafruit 5625)
├─ VL53L0X ToF Sensor (Primary Detection)
├─ BME280 Environmental Sensor (Optional - can be at inlet or control box)
└─ [Future: Camera, Additional Sensors]

CONTROL BOX (Main Electronics):
├─ ESP32-S3 Feather (Main Controller)
├─ OLED Display (User Interface)
├─ Power Supply (Mean Well LRS-35-5)
├─ SSR + Optocoupler (AC Switching)
└─ Emergency Stop Button
```

### Optimized Hub-Based Connection Details
```
ESP32-S3 STEMMA QT Port (Control Box)
    ↓ (Single 500mm-1000mm STEMMA QT Cable to Inlet)
QWIIC/STEMMA QT 5-Port Hub (Located at Inlet Area)
    ├─ Port 1 → VL53L0X ToF Sensor (50mm cable - co-located)
    ├─ Port 2 → BME280 Environmental (100mm cable - nearby at inlet)
    ├─ Port 3 → [Reserved for Camera Module at inlet]
    ├─ Port 4 → [Reserved for Additional Inlet Sensors]
    └─ Port 5 → [Reserved for Future Expansion]

CONTROL BOX Direct Connections:
    ├─ OLED Display (Direct to ESP32 via 100mm cable)
    └─ Emergency Controls (GPIO direct connections)
```

### Optimized Cable Requirements
| Component | Cable Type | Length | Quantity | Part Number |
|-----------|------------|--------|----------|-------------|
| ESP32 → Hub (Inlet) | STEMMA QT | 500mm-1000mm | 1 | Adafruit 4401/4404 |
| Hub → VL53L0X | STEMMA QT | 50mm | 1 | Adafruit 4399 |
| Hub → BME280 (Inlet) | STEMMA QT | 100mm | 1 | Adafruit 4397 |
| ESP32 → OLED (Control Box) | STEMMA QT | 100mm | 1 | Adafruit 4397 |
| Hub | QWIIC 5-Port | - | 1 | **Adafruit 5625** |
| **Total** | | | **4** | **Minimized runs** |

---

## Bill of Materials (BOM) Updates

### Components to Add
| Qty | Component | Part Number | Description | Vendor | Price |
|-----|-----------|-------------|-------------|--------|-------|
| 1 | QWIIC/STEMMA QT Hub | 5625 | 5-Port I2C Hub with JST SH connectors | Adafruit | $7.50 |

### Components to Modify (Inlet Hub Configuration)
| Original | New | Reason | Price Impact |
|----------|-----|--------|--------------|
| 3x 100mm + 1x 200mm STEMMA QT Cables | 1x 500mm + 2x 50mm + 1x 100mm | Inlet hub reduces cable runs | -$1.85 |
| Individual sensor cable routing | Single main cable to inlet | Simplified installation | $0.00 |
| Multiple control box sensor mounts | Single cable entry point | Reduced complexity | $0.00 |

### **Net Cost Impact: +$5.65** (vs. +$8.45 for control box hub)

### Cable Requirements Comparison
| Configuration | Cable Count | Total Length | Complexity | Cost |
|---------------|-------------|--------------|------------|------|
| **Original Daisy Chain** | 3 cables | 400mm total | High | $4.15 |
| **Control Box Hub** | 4 cables | 450mm total | Medium | $6.15 |
| **Inlet Hub (RECOMMENDED)** | 4 cables | 750mm total | Low | $7.80 |

**Inlet Hub Benefits**: Despite slightly higher cable cost, provides massive installation and maintenance advantages.

---

## Enclosure Modifications Required

### Inlet Area Hub Mounting Location
```
┌─────────────────────────────────────────────────────────────┐
│ Inlet Assembly (Side View) - 4" PVC Pipe                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   [Pipe Opening]  ─────►  [Detection Zone]                 │
│         │                        │                         │
│         │                   ┌────▼────┐                    │
│         │                   │VL53L0X  │                    │
│         │                   │Sensor   │                    │
│         ▼                   └─────────┘                    │
│  ┌─────────────┐                 │                         │
│  │ Protection  │          ┌──────▼──────┐                  │
│  │ Housing     │          │ QWIIC Hub   │                  │
│  │             │          │ (5625)      │                  │
│  │  ┌────────┐ │          │  ┌───┐ ┌───┐│                  │
│  │  │BME280  │ │          │  │ 1 │ │ 2 ││ ← VL53L0X/BME280 │
│  │  │Env.    │ │          │  ├───┤ ├───┤│                  │
│  │  │Sensor  │ │          │  │ 3 │ │ 4 ││ ← Future/Camera  │
│  │  └────────┘ │          │  ├───┤ ├───┤│                  │
│  └─────────────┘          │  │ 5 │ │ U ││ ← Future/Upstream│
│                           │  └───┘ └───┘│                  │
│                           └──────┬──────┘                  │
│                                  │                         │
│                                  ▼                         │
│              Single Cable to Control Box                   │
│              (500mm-1000mm STEMMA QT)                      │
└─────────────────────────────────────────────────────────────┘
```

### Control Box Interior (Simplified Layout)
```
┌─────────────────────────────────────────────────────────────┐
│ Control Box Interior (Top View) - Fewer Internal Cables    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [E-Stop] [OLED]                             [Power SW]     │
│     │       │                                    │         │
│     │       └─────────── Direct Connection       │         │
│     │              (100mm cable)                 │         │
│     │                    │                       │         │
│     │               ┌────▼─────┐                 │         │
│     │               │ ESP32-S3 │                 │         │
│     │               │ Feather  │                 │         │
│     │               └────┬─────┘                 │         │
│     │                    │                       │         │
│     │                    └─── Single Cable ──────┼─ TO     │
│     │                         to Inlet Hub       │  INLET  │
│     │                         (500mm-1000mm)     │  AREA   │
│     │                                            │         │
│     └─ [Emergency Stop Circuit] ──────────────────────────── │
│                                                             │
│  [PSU]              [SSR]              [Terminal Blocks]   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 3D Model Updates Required

#### Inlet Area Models (Primary Changes)
The following SCAD files need significant updates for hub integration:
- `Inlet_Rodent_Detection_Assembly.scad` - Add hub mounting provisions

#### New Parameters for Inlet Hub Integration
```scad
// QWIIC Hub mounting parameters (Inlet Location)
qwiic_hub_width = 25.4;      // 1 inch PCB width
qwiic_hub_length = 25.4;     // 1 inch PCB length
qwiic_hub_thickness = 1.6;   // Standard PCB thickness
qwiic_hub_mounting_holes = 4; // M2.5 mounting holes

// Inlet hub placement (relative to sensor)
hub_offset_x = 40;           // Offset from VL53L0X sensor center
hub_offset_y = 20;           // Distance from pipe wall
hub_protection_clearance = 10; // Space for weatherproof enclosure

// Cable management for inlet area
inlet_cable_exit_diameter = 8;    // Single cable to control box
cable_strain_relief_length = 15;  // Weather sealing
cable_protection_depth = 25;      // Conduit depth into enclosure
```

#### Control Box Models (Simplified)
- `Side_Mount_Control_Box.scad` - Remove individual sensor mounts, keep hub cable entry

### 3D Model Updates Required
The following SCAD files need to be updated to accommodate the hub:
- `Side_Mount_Control_Box.scad`

#### New Parameters to Add
```scad
// QWIIC Hub mounting parameters (Adafruit 5625)
qwiic_hub_width = 25.4;      // 1 inch PCB width
qwiic_hub_length = 25.4;     // 1 inch PCB length
qwiic_hub_thickness = 1.6;   // Standard PCB thickness
qwiic_hub_mounting_holes = 4; // M2.5 mounting holes
qwiic_hub_x = 60;            // Central location for cable management
qwiic_hub_y = 30;            // Midpoint between front and back
```

---

## Related Documents
- `ELECTRICAL_DESIGN.md` - Complete electrical specifications
- `INSTALLATION_GUIDE.md` - Step-by-step assembly procedures
- `3D Models/Side_Mount_Control_Box.scad` - Enclosure design
- `BOM_CONSOLIDATED.csv` - Complete bill of materials
- `esphome/rat-trap-2025.yaml` - ESPHome configuration
