> **⚠️ Work in Progress ⚠️**
>
> This project is under active development. The documentation, features, and hardware recommendations are subject to change. Please check back for updates.

# ShopVac Rat Trap - Electrical Design, Wiring, and Safety

## 1. Design Overview

This document details the electrical design, theory of operation, and safety considerations for the ShopVac Rat Trap.

> [!NOTE]
> For practical wiring instructions and diagrams, please refer to the **[Assembly Guide](ASSEMBLY_GUIDE.md)**.

### 1.1. Core Design Philosophy

1. **Safety First**: Adherence to NEC/UL (North America) and IEC/CE (Europe) electrical safety standards
2. **Simplified Assembly**: No-solder design using modular STEMMA QT connectors
3. **Robustness**: Industrial-grade components for long-term operation
4. **IoT Integration**: Seamless ESPHome and Home Assistant compatibility
5. **Global Compatibility**: Support for both 120V AC and 230V AC systems

### 1.2. Key Design Decisions

#### Single Power Supply Architecture
The design uses a single power supply with ESP32-S3's built-in regulation:
- **Mean Well LRS-35-5**: Single 5V/7A chassis-mount power supply
- **ESP32-S3 Built-in Regulator**: 600mA capacity powers all 3.3V components
- **Total 3.3V Load**: ~99mA (84% safety margin)
- **Benefit**: Eliminates external regulator modules

#### STEMMA QT Modular System
All sensors use standardized JST SH 4-pin connectors for assembly without soldering:
- Daisy-chain compatible I2C bus
- Polarized connectors prevent incorrect wiring
- Hot-swappable sensors for easy maintenance
- Professional cable management

#### Electronics Enclosure
For maximum safety and code compliance, all electronic components (both high and low voltage) should be housed in a single, commercially available, UL-listed (or equivalent) enclosure. The recommended enclosure for this project is the **Hammond PN-1334-C (8"x6"x4" ABS)**, which is already included in the BOM. This enclosure provides ample space for all components and ensures proper separation between high and low voltage circuits.

## 2. Bill of Materials (BOM)

**Total Project Cost: $183 (Standard) / $204 (Camera)**

> **Note**: Complete vendor information and direct purchase links are available in [BOM_CONSOLIDATED.csv](BOM_CONSOLIDATED.csv).

### 2.1. Core Electronics

| Qty | Component | Part Number | Description | Vendor | Price |
|-----|-----------|-------------|-------------|--------|-------|
| 1 | ESP32-S3 Feather | 5323 | 8MB Flash, USB-C, STEMMA QT | Adafruit | $17.50 |
| 1 | Feather Stacking Headers | 2830 | 12-pin and 16-pin female headers | Adafruit | $1.25 |
| 1 | VL53L0X ToF Sensor | 3317 | Time-of-Flight distance sensor | Adafruit | $15.89 |
| 1 | APDS9960 Proximity | 3595 | Proximity/Light/RGB/Gesture | Adafruit | $7.50 |
| 1 | PIR Motion Sensor | 4871 | PIR Motion Sensor | Adafruit | $3.95 |
| 1 | OLED Display 128x64 | 326 | 0.96" monochrome display | Adafruit | $17.50 |
| 1 | BME280 Env. Sensor | 4816 | Temperature/Humidity/Pressure | Adafruit | $10.95 |
| 1 | STEMMA QT 5-Port Hub | 5625 | 5-Port STEMMA QT/Qwiic Hub | Adafruit | $2.50 |

### 2.2. Power & Safety Components

| Qty | Component | Part Number | Description | Vendor | Price |
|-----|-----------|-------------|-------------|--------|-------|
| 1 | Power Supply | LRS-35-5 | Mean Well 5V/7A chassis mount | Mouser | $11.80 |
| 1 | Solid State Relay | AQA411VL | Panasonic 25A SSR | Mouser | $25.61 |
| 1 | Thermal Pad | HSP-7 | Crydom thermal pad for SSR | Mouser | $1.38 |
| 1 | IEC Inlet w/ CB & Switch | DF11.2078.0010.01 | C14 inlet + CB + switch | Mouser | $37.27 |
| 1 | AC Outlet | 6600.3100 | Panel Mount IEC C13 Outlet | Mouser | $2.05 |
| 1 | Emergency Stop Button | XB6ETN521P | 16mm Red E-Stop Switch | Mouser | $22.13 |
| 1 | Current Transformer | PCS020-EE0502KS | 20A Split Core CT | Mouser | $4.09 |
| 1 | Optocoupler | 4N35-X007 | General Purpose Optocoupler | Mouser | $0.76 |
| 1 | Large Arcade Button | 368 | Large Arcade Button | Adafruit | $2.00 |
| 1 | Enclosure | PN-1334-C | Hammond 8"x6"x4" ABS | Mouser | $16.20 |

### 2.3. Cables & Hardware

| Qty | Component | Part Number | Description | Vendor | Price |
|-----|-----------|-------------|-------------|--------|-------|
| 1 | STEMMA QT Cable 500mm | 4401 | 500mm JST SH cable | Adafruit | $1.25 |
| 1 | STEMMA QT Cable 50mm | 4399 | 50mm JST SH cable | Adafruit | $0.95 |
| 2 | STEMMA QT Cable 100mm | 4397 | 100mm JST SH cable | Adafruit | $1.90 |
| 1 | Wire - Red 26AWG | 1877 | Silicone cover 2m red wire | Adafruit | $0.95 |
| 1 | Wire - Black 26AWG | 1881 | Silicone cover 2m black wire | Adafruit | $0.95 |

## 3. Circuit Design & Connections

### 3.1. System Architecture

**Standard Configuration:**
```
[120V AC Input] → [IEC Inlet + Switch] → [Mean Well PSU] → [ESP32-S3]
                                              ↓                ↓
[Shop Vacuum] ← [SSR Output] ← [SSR Control] ← [GPIO5] ← [3.3V Regulation]
                                                        ↓
[STEMMA QT Bus] ← [I2C Sensors: APDS9960 + VL53L0X + BME280 + OLED]
```

**STEMMA QT Camera Enhanced Configuration:**
```
[120V AC Input] → [IEC Inlet + Switch] → [Mean Well PSU] → [ESP32-S3 Feather]
                                              ↓                ↓
[Shop Vacuum] ← [SSR Output] ← [SSR Control] ← [GPIO5] ← [3.3V Built-in Regulator]
                                                         ↓
[STEMMA QT Bus] ← [I2C: APDS9960 + VL53L0X + BME280 + OLED] → [Hybrid Detection]
                                                         ↓
[Evidence Storage] ← [Dimension Capture] ← [OV5640 STEMMA Camera] ← [Auto Trigger]
                                                         ↓
[High-Power IR] ← [STEMMA JST PH] ← [GPIO6] ← [Night Vision Control]
```

### 3.2. GPIO Pin Assignments

**Critical Safety Rule**: GPIO5 is reserved ONLY for SSR control - never use for other purposes.

**Standard ESP32-S3 Feather Configuration:**
| GPIO | Function | Connection | Safety Level |
|------|----------|------------|--------------|
| GPIO5 | SSR Control | 4N35 Optocoupler → SSR | SAFETY CRITICAL |
| GPIO18 | Emergency Stop | Arcade Button (Active Low) | SAFETY CRITICAL |
| GPIO3 | I2C SDA | STEMMA QT Bus (Primary) | Standard |
| GPIO4 | I2C SCL | STEMMA QT Bus (Primary) | Standard |
| GPIO10 | Reset Button | Reset/Test Button | Standard |
| GPIO13 | PIR Motion | PIR Sensor Input | Standard |

**STEMMA QT Camera Enhanced Configuration:**
| GPIO | Function | Connection | Safety Level |
|------|----------|------------|--------------|
| GPIO5 | SSR Control | 4N35 Optocoupler → SSR | SAFETY CRITICAL |
| GPIO18 | Emergency Stop | Arcade Button (Active Low) | SAFETY CRITICAL |
| GPIO3 | I2C SDA | STEMMA QT Bus (Primary Sensors) | Standard |
| GPIO4 | I2C SCL | STEMMA QT Bus (Primary Sensors) | Standard |
| GPIO8 | I2C SDA | OV5640 Camera (Secondary Bus) | Standard |
| GPIO9 | I2C SCL | OV5640 Camera (Secondary Bus) | Standard |
| GPIO6 | IR LED Control | High-Power IR STEMMA Module | Standard |
| GPIO10 | Reset Button | Reset/Test Button | Standard |
| GPIO13 | PIR Motion | PIR Sensor Input | Standard |

### 3.3. Power Distribution

#### AC Side (120V/230V)
```
IEC Inlet with Integrated CB & Switch (DF11.2078.0010.01)
├─ Line → Mean Well PSU (AC Input) + SSR Common + Current Transformer
├─ Neutral → Mean Well PSU (AC Input) + IEC C13 Outlet Neutral
└─ Ground → IEC C13 Outlet Ground + Enclosure Ground

SSR Output → IEC C13 Outlet Line (Hot)
```

#### DC Side (5V/3.3V)
```
Mean Well LRS-35-5 (5V/7A)
├─ +5V → ESP32-S3 VIN
│        └─ Built-in 3.3V Regulator (600mA)
│            ├─ VL53L0X (15mA)
│            ├─ OLED Display (15mA)
│            ├─ BME280 (3.6mA)
│            └─ 501mA Available
└─ GND → Common Ground
```

### 3.4. Power Budget Analysis

**STANDARD CONFIGURATION (APDS9960 + VL53L0X + PIR + BME280):**
```
ESP32-S3 Core:         45-70mA WiFi active
APDS9960 Proximity:    400µA typical, 5mA active
VL53L0X ToF Sensor:    15mA typical, 30mA peak
PIR Motion Sensor:     65µA quiescent, 2.3mA active
BME280 Env. Sensor:    1μA sleep, 3.6mA active
OLED Display:          15mA typical, 25mA peak
Total Load:            76-106mA typical, 135mA peak
ESP32-S3 Capacity:     600mA (built-in regulator)
Safety Margin:         465-524mA available (77-87% headroom)
Power Compliance:      ✅ APPROVED - Excellent headroom
```

**CAMERA CONFIGURATION (Four-Sensor + OV5640 Camera):**
```
ESP32-S3 Core:         70mA WiFi + processing
APDS9960 Proximity:    400µA typical, 5mA active
OV5640 5MP Camera:     100mA capturing, 20mA idle
PIR Motion Sensor:     65µA quiescent, 2.3mA active
VL53L0X ToF Sensor:    15mA typical, 30mA peak
BME280 Env. Sensor:    1μA sleep, 3.6mA active
OLED Display:          15mA typical, 25mA peak
High-Power IR LEDs:    200mA @ 3.3V (pulsed only)
Camera Processing:     +50mA during image processing
Total Typical:         225mA normal operation
Total Peak Load:       431mA during capture with IR pulse
ESP32-S3 Capacity:     600mA (built-in regulator)
Safety Margin:         169mA available (28% headroom)
Power Compliance:      ✅ APPROVED - Within ESP32-S3 limits
```

## 4. Wiring Diagrams & Cable Management

This section provides comprehensive wiring diagrams for the ShopVac Rat Trap system, including both the current daisy-chain setup and the improved hub-based configuration using the **Adafruit QWIIC/STEMMA QT 5-Port Hub (Product ID: 5625)**.

### 4.1. Current Wiring Configuration (Daisy Chain)

#### System Architecture Diagram
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
│  │  GPIO13 ─────────────┼────┼─ [PIR Motion]                   │ │               │
│  │       │              │    │                                 │ │               │
│  │       │              │    │             ┌─────────┐       │ │               │
│  │  GPIO18 ─────────────┼────┼─ [Emergency │OLED     │       │ │               │
│  │       │              │    │    Button]  │Display  │       │ │               │
│  │  GPIO3 (SDA) ───────┼────┼─────────────────────│(0x3C)   ││ │               │
│  │  GPIO4 (SCL) ───────┼────┼─────────────────────│         ││ │               │
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

#### I2C Device Chain Details
```
ESP32-S3 STEMMA QT Port (GPIO3/4)
    ↓ (100mm STEMMA QT Cable #1)
VL53L0X ToF Sensor (I2C Address: 0x29)
    ↓ (100mm STEMMA QT Cable #2)
BME280 Environmental Sensor (I2C Address: 0x77)
    ↓ (200mm STEMMA QT Cable #3)
OLED Display (I2C Address: 0x3C)
```

### 4.2. Improved Wiring Configuration (Hub-Based)

#### System Architecture with QWIIC Hub in Inlet Area
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
│  │  GPIO3 (SDA) ────────┼────────┼──│ Port 4 ──── ┼ (Camera)  │ │               │
│  │  GPIO4 (SCL) ────────┼────────┼──│ Port 5 ──── ┼ (Future)  │ │               │
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

## 5. Safety & Compliance

### 5.1. ⚠️ ELECTRICAL HAZARD WARNING ⚠️

This project involves 120V/230V AC electrical connections. Installation **MUST** be performed by qualified individuals with electrical experience. Improper installation can result in:
- Electrical shock or electrocution (potentially fatal)
- Fire hazard from overloaded circuits or motor overload
- Equipment damage from improper connections or overcurrent conditions
- Personal injury from mechanical failures or vacuum motor damage

### 5.2. 🚨 MANDATORY SAFETY ENHANCEMENTS (August )

#### **CRITICAL: Current Monitoring Required**
All installations **MUST** include AC current monitoring for safety:
- **Component**: SCT-013-020 current transformer (20A rating)
- **Purpose**: Detect vacuum motor overload, clogged hoses, bearing failures
- **Action**: Automatic shutdown when current exceeds 12A (141% of normal)
- **Installation**: CT clamp around hot wire to vacuum outlet
- **Compliance**: Required for motor protection per NEC 430.32

### 5.3. Safety Standards Compliance

#### North America (NEC/UL Standards)
- **Circuit Protection:** 15A breaker and **12A fuse** (enhanced selective coordination)
- **Wire Gauge:** 12 AWG minimum for all AC circuits (NEC Table 310.15(B)(16))
- **Current Monitoring:** SCT-013-020 CT mandatory for motor protection (NEC 430.32)
- **GFCI Protection:** Required for wet locations (NEC 210.8)
- **Ground Integrity:** Continuous ground path verification mandatory (NEC 250.114)
- **Disconnect Means:** Readily accessible per NEC 422.31(B)
- **Isolation:** >4000V between AC and DC sections per UL 508A
- **Surge Protection:** TVS diodes on GPIO pins recommended

#### Europe (IEC/CE Standards)
- **Circuit Protection:** 10A MCB and **10A fuse** coordination per IEC 60364-4-43
- **Wire Gauge:** 1.5mm² minimum for all 230V connections (IEC 60364-5-52)
- **Current Monitoring:** SCT-013-020 CT mandatory for motor protection (IEC 60204-1)
- **RCD Protection:** 30mA RCD required for wet locations per IEC 60364-4-41
- **Protective Earth:** Continuous PE conductor per IEC 60364-6-61
- **Emergency Stop:** Category 0 disconnect per IEC 60204-1
- **CE Marking:** All components must be CE marked for EU compliance
- **EMC Compliance:** EN 55011 Class B emissions, ferrite cores required

### 5.4. Required Safety Equipment

#### For Installation
- Safety glasses with side shields
- Insulated electrical gloves (rated for 600V minimum)
- Non-contact voltage tester
- Multimeter with CAT III 600V rating
- **AC current clamp meter** (for CT calibration)
- **GFCI outlet tester** (Klein RT105 or equivalent)
- First aid kit with electrical burn treatment

#### For Regular Use
- Fire extinguisher suitable for electrical fires (Class C)
- Emergency contact information clearly posted
- Operational checklist for regular safety verification
- **Monthly current monitoring verification**

## 6. Assembly and Installation

### 6.1. Assembly Guidelines

#### Component Layout
**Enclosure Organization (Hammond PN-1334-C 8"x6"x4" ABS):**

The following layout is recommended to ensure proper safety clearances and thermal management.

```
┌─────────────────────────────┐
│ [E-Stop] [OLED]    [Power]  │ ← Front Panel (User Interface)
│                     [PSU]   │
│ [ESP32-S3]         [SSR]    │ ← Main Section (Mounted on DIN rail or standoffs)
│ [Term.Blocks]      [Outlet] │
│                             │
│ [IEC Inlet]    [Cable Gland]│ ← Rear Panel (Power and Sensor Connections)
└─────────────────────────────┘
```

#### Wiring Best Practices
- **AC Wiring (Safety Critical)**: Use 12 AWG wire, proper strain relief, and follow color codes.
- **DC Wiring**: Use pre-made STEMMA QT cables.
- **Thermal Management**: Ensure proper ventilation and use heat sinks if necessary.

### 6.2. Lockout/Tagout Procedure

**MANDATORY: Follow this procedure before ANY maintenance work**

1. **Disconnect Power**
2. **Verify Zero Energy State**
3. **Lockout**
4. **Tagout**
5. **Test Verification**

## 7. Testing & Validation

### 7.1. ⚠️ **MANDATORY Current Monitoring Calibration**
**CRITICAL SAFETY PROCEDURE - Required for all installations**

1. **CT Installation Verification**
2. **Current Calibration Procedure**
3. **Safety Threshold Testing**

### 7.2. Safety Testing (Mandatory)
1. **Isolation Test**: >4MΩ resistance between AC and DC sections
2. **Ground Continuity**: <0.1Ω resistance from inlet to outlet ground
3. **Thermal Test**: Monitor ESP32 temperature under full load
4. **Emergency Stop**: Verify immediate SSR shutdown on button press
5. **Protection Test**: Confirm PSU overload protection functions

### 7.3. Integration Testing
1. **ESPHome Flash**: Upload configuration and verify WiFi connection
2. **Home Assistant**: Confirm automatic entity discovery
3. **Sensor Calibration**: Verify ToF sensor distance readings
4. **Load Test**: Test with actual shop vacuum connected

## 8. Emergency Procedures

### 8.1. Thermal Emergency
If thermal shutdown is triggered:
1. **IMMEDIATE**: Disconnect power to the system
2. **ASSESS**: Check for obstructions to ventilation
3. **WAIT**: Allow minimum 30 minutes cooling time
4. **INSPECT**: Look for signs of component damage
5. **DOCUMENT**: Record the incident with temperature data if available

### 8.2. Emergency Stop Activation
If emergency stop is activated:
1. **IDENTIFY**: Determine reason for emergency stop activation
2. **SECURE**: Ensure area is safe before resetting
3. **INSPECT**: Check for physical damage or loose components
4. **RESET**: Only after confirming safe conditions
5. **TEST**: Verify all functions operate correctly
