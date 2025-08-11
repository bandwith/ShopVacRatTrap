# ShopVac Rat Trap 2025 - Electrical Design & BOM

## Design Overview

This document outlines the electrical design for the 2025 optimized ShopVac Rat Trap, focusing on enhanced safety, cost reduction, and simplified assembly while maintaining professional-grade performance and international compliance.

### Core Design Philosophy

1. **Safety First**: Adherence to NEC/UL (North America) and IEC/CE (Europe) electrical safety standards
2. **Simplified Assembly**: No-solder design using modular STEMMA QT connectors
3. **Robustness**: Industrial-grade components for long-term operation
4. **IoT Integration**: Seamless ESPHome and Home Assistant compatibility
5. **Global Compatibility**: Support for both 120V AC and 230V AC systems

### Key Design Decisions

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

## Bill of Materials (BOM)

**Total Project Cost: $146.10**

> **Note**: Complete vendor information and direct purchase links are available in [BOM_CONSOLIDATED.csv](BOM_CONSOLIDATED.csv).

### Core Electronics

| Qty | Component | Part Number | Description | Vendor | Price |
|-----|-----------|-------------|-------------|--------|-------|
| 1 | ESP32-S3 Feather | 5323 | 8MB Flash, USB-C, STEMMA QT | Adafruit | $17.50 |
| 1 | VL53L0X ToF Sensor | 3317 | Time-of-Flight distance sensor | Adafruit | $14.95 |
| 1 | OLED Display 128x64 | 326 | 0.96" monochrome display | Adafruit | $17.50 |
| 1 | BME280 Env. Sensor | 2652 | Temperature/Humidity/Pressure | Adafruit | $14.95 |
| 1 | QWIIC Hub | 5625 | 5-Port STEMMA QT/QWIIC Hub | Adafruit | $7.50 |
| 1 | Solid State Relay | COM-13015 | 40A chassis mount SSR | SparkFun | $24.95 |
| 1 | Optocoupler 4N35 | 2515 | Isolation for SSR control | Adafruit | $4.95 |

### Power & Safety Components

| Qty | Component | Part Number | Description | Vendor | Price |
|-----|-----------|-------------|-------------|--------|-------|
| 1 | Power Supply | LRS-35-5 | Mean Well 5V/7A chassis mount | Mouser | $18.50 |
| 1 | IEC Inlet with Switch | 4300.0030 | C14 inlet + rocker switch | Mouser | $12.80 |
| 1 | AC Outlet | 5320-W | NEMA 5-15R 15A outlet | Mouser | $8.40 |
| 1 | Emergency Stop Button | 368 | Large red arcade button | Adafruit | $4.95 |
| 1 | Project Enclosure | PN-1334-C | ABS 8"x6"x4" box | Mouser | $16.20 |

### Cables & Hardware

| Qty | Component | Part Number | Description | Vendor | Price |
|-----|-----------|-------------|-------------|--------|-------|
| 1 | STEMMA QT Cable 500mm | 4401 | Main cable to inlet hub | Adafruit | $1.95 |
| 1 | STEMMA QT Cable 50mm | 4399 | Hub to VL53L0X (co-located) | Adafruit | $0.75 |
| 2 | STEMMA QT Cable 100mm | 4397 | Hub to BME280 + ESP32 to OLED | Adafruit | $1.90 |
| 1 | Wire Kit | 3258/3259 | Red/Black 26AWG silicone wire | Adafruit | $5.90 |

**Cable Configuration - Inlet Hub Optimized:**
- **ESP32 to Inlet Hub**: 1x 500mm cable (single main run)
- **Inlet Area Sensors**: 2x short cables (50mm, 100mm)
- **Control Box OLED**: 1x 100mm cable (direct connection)
- **Major Benefit**: Only 1 cable run between control box and inlet vs. 3+ separate runs

### Regional Variants

#### 🇺🇸 North America (120V AC, 60Hz)
- Wire Colors: Black=Hot, White=Neutral, Green=Ground
- Protection: 15A circuit breaker
- Outlet: NEMA 5-15R

#### 🇪🇺 Europe (230V AC, 50Hz)
- Wire Colors: Brown=Line, Blue=Neutral, Green/Yellow=Earth
- Protection: 10A MCB + 30mA RCD
- Outlet: CEE 7/7 (Schuko)
- IEC Inlet: 4300.0063 (230V rated)

### Power Budget Analysis - HYBRID DETECTION SYSTEM

**STANDARD CONFIGURATION (APDS9960 + ToF + PIR):**
```
ESP32-S3 Core:         45-70mA WiFi active
APDS9960 Proximity:    400µA typical, 5mA active
VL53L0X ToF Sensor:    15mA typical, 30mA peak
PIR Motion Sensor:     65µA quiescent, 2.3mA active
BME280 Env. Sensor:    1μA sleep, 3.6mA active
OLED Display:          15mA typical, 25mA peak
Total Load:            76-108mA typical, 135mA peak
ESP32-S3 Capacity:     600mA (built-in regulator)
Safety Margin:         465-524mA available (77-87% headroom)
```

**CAMERA CONFIGURATION (Four-Sensor Hybrid Detection):**
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
Total Peak Load:       435mA during capture with IR pulse
ESP32-S3 Capacity:     600mA (built-in regulator)
Safety Margin:         165mA available (27% headroom)
Power Compliance:      ✅ APPROVED - Within ESP32-S3 limits
```

**⚠️ CRITICAL POWER MANAGEMENT NOTES:**
- Camera configuration operates near ESP32 limits during capture
- IR LED MUST be pulsed only - never continuous operation
- Thermal monitoring mandatory - ESP32 temperature <85°C
- Intelligent power sequencing prevents overload conditions

**Key Advantages of STEMMA QT Upgrade:**
- ✅ Higher resolution: 5MP OV5640 vs 2MP OV2640
- ✅ Enhanced IR range: 10+ meters vs 3-5 meters
- ✅ No-solder assembly: Complete STEMMA ecosystem
- ✅ Better power management: Optimized current draw
- ✅ Modular design: Easy component replacement

## Circuit Design & Connections

### System Architecture

**Standard Configuration:**
```
[120V AC Input] → [IEC Inlet + Switch] → [Mean Well PSU] → [ESP32-S3]
                                              ↓                ↓
[Shop Vacuum] ← [SSR Output] ← [SSR Control] ← [GPIO5] ← [3.3V Regulation]
                                                        ↓
[STEMMA QT Bus] ← [I2C Sensors: VL53L0X + BME280 + OLED]
```

**STEMMA QT Camera Enhanced Configuration:**
**Standard ESP32-S3 Configuration:**
```
[120V AC Input] → [IEC Inlet + Switch] → [Mean Well PSU] → [ESP32-S3 Feather]
                                              ↓                ↓
[Shop Vacuum] ← [SSR Output] ← [SSR Control] ← [GPIO5] ← [3.3V Built-in Regulator]
                                                         ↓
[STEMMA QT Bus] ← [I2C: VL53L0X + BME280 + OLED] → [Detection Trigger]
```

**STEMMA QT Camera Enhancement:**
```
[120V AC Input] → [IEC Inlet + Switch] → [Mean Well PSU] → [ESP32-S3 Feather]
                                              ↓                ↓
[Shop Vacuum] ← [SSR Output] ← [SSR Control] ← [GPIO5] ← [3.3V Built-in Regulator]
                                                         ↓
[STEMMA QT Bus] ← [VL53L0X + BME280 + OLED] → [Detection Trigger]
                                                         ↓
[SD Card Storage] ← [Image Capture] ← [OV5640 STEMMA Camera] ← [Auto Trigger]
                                                         ↓
[High-Power IR] ← [STEMMA JST PH] ← [GPIO6] ← [Night Vision Control]
```

### GPIO Pin Assignments

**Critical Safety Rule**: GPIO5 is reserved ONLY for SSR control - never use for other purposes.

**Standard ESP32-S3 Feather Configuration:**
| GPIO | Function | Connection | Safety Level |
|------|----------|------------|--------------|
| GPIO5 | SSR Control | 4N35 Optocoupler → SSR | SAFETY CRITICAL |
| GPIO13 | Emergency Stop | Arcade Button (Active Low) | SAFETY CRITICAL |
| GPIO3 | I2C SDA | STEMMA QT Bus (Primary) | Standard |
| GPIO4 | I2C SCL | STEMMA QT Bus (Primary) | Standard |
| GPIO13 | Status LED | Onboard LED | Standard |

**STEMMA QT Camera Enhanced Configuration:**
| GPIO | Function | Connection | Safety Level |
|------|----------|------------|--------------|
| GPIO5 | SSR Control | 4N35 Optocoupler → SSR | SAFETY CRITICAL |
| GPIO13 | Emergency Stop | Arcade Button (Active Low) | SAFETY CRITICAL |
| GPIO3 | I2C SDA | STEMMA QT Bus (Sensors) | Standard |
| GPIO4 | I2C SCL | STEMMA QT Bus (Sensors) | Standard |
| GPIO8 | I2C SDA | OV5640 Camera (Secondary Bus) | Standard |
| GPIO9 | I2C SCL | OV5640 Camera (Secondary Bus) | Standard |
| GPIO6 | IR LED Control | High-Power IR STEMMA Module | Standard |

### Power Distribution

#### AC Side (120V/230V)
```
IEC Inlet with Switch (4300.0030)
├─ Line → Mean Well PSU (AC Input) + SSR Common
├─ Neutral → Mean Well PSU (AC Input) + Outlet Neutral
└─ Ground → Outlet Ground + Enclosure Ground

SSR Output → Outlet Line (Hot)
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

### I2C Bus Configuration

**Current Implementation: STEMMA QT Daisy Chain**
```
ESP32-S3 STEMMA QT Port
    ↓ (100mm cable)
VL53L0X ToF Sensor (0x29)
    ↓ (100mm cable)
BME280 Environmental (0x77)
    ↓ (200mm cable)
OLED Display (0x3C)
```

**⚡ RECOMMENDED: Inlet Hub-Based Configuration**
```
ESP32-S3 STEMMA QT Port (Control Box)
    ↓ (500mm cable to inlet area)
QWIIC/STEMMA QT 5-Port Hub (Adafruit 5625) - Located at Inlet
    ├─ Port 1 → VL53L0X ToF Sensor (50mm cable - co-located)
    ├─ Port 2 → BME280 Environmental (100mm cable - inlet area)
    ├─ Port 3 → [Reserved for Camera Module at inlet]
    ├─ Port 4 → [Reserved for Additional Inlet Sensors]
    └─ Port 5 → [Reserved for Future Expansion]

OLED Display (0x3C) → Direct to ESP32 (100mm cable in control box)
```

**I2C Device Addresses:**
- `0x29` - VL53L0X Time-of-Flight sensor (at inlet)
- `0x3C` - SSD1306 OLED display (in control box)
- `0x77` - BME280 environmental sensor (at inlet for accurate readings)

**Inlet Hub Benefits:**
- ✅ **Massive Cable Reduction**: Only 1 cable run between control box and inlet area
- ✅ **Accurate Environmental Data**: BME280 at inlet monitors actual entry conditions
- ✅ **Simplified Installation**: Single cable routing vs. multiple sensor cable runs
- ✅ **Reduced EMI Susceptibility**: Short sensor cables less vulnerable to interference
- ✅ **Future Expansion**: Camera and additional sensors can be added at inlet without new cable runs
- ✅ **Easier Maintenance**: All detection components accessible at inlet location

### Safety Isolation

**High Voltage Isolation:**
- Minimum 5mm clearance between AC and DC sections
- 4N35 optocoupler provides >4000V isolation for SSR control
- Continuous ground from IEC inlet to outlet and enclosure
- No shared connections between AC and DC grounds

## Safety & Compliance

> **Note**: For comprehensive safety procedures and detailed compliance requirements, refer to [SAFETY_REFERENCE.md](SAFETY_REFERENCE.md) and [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md).

### Electrical Standards Compliance

#### 🇺🇸 North America (NEC/UL/CSA)
| Standard | Requirement | Implementation |
|----------|-------------|----------------|
| NEC 422.11(A) | Appliance disconnect within sight | Emergency switch on front panel |
| NEC 422.31(B) | Switch rated for appliance load | 25A SSR > 15A vacuum load |
| NEC 240.4(B) | Overcurrent protection coordination | Building breaker + PSU protection |
| NEC 250.114 | Equipment grounding | Continuous ground path |
| UL 508A | Industrial control panel standard | >4000V isolation, proper barriers |

#### 🇪🇺 Europe (IEC/CE)
| Standard | Requirement | Implementation |
|----------|-------------|----------------|
| IEC 60204-1 | Safety of machinery - Electrical | Category 0 emergency stop |
| EN 55011 Class B | EMC emissions | Zero-crossing SSR, filtering |
| IEC 60364-4-41 | Shock protection | RCD + protective earthing |
| EU 2006/42/EC | Machinery Directive | CE marking required |

### Power System Specifications

#### Regional Requirements
| Region | Voltage | Frequency | Protection | Wire Size |
|--------|---------|-----------|------------|-----------|
| 🇺🇸 North America | 120V AC ±10% | 60Hz | 15A breaker | 12 AWG |
| 🇪🇺 Europe | 230V AC ±10% | 50Hz | 10A MCB | 1.5mm² |
| 🇬🇧 UK | 230V AC ±10% | 50Hz | 13A fused plug | 1.5mm² |
| 🇦🇺 Australia | 230V AC ±10% | 50Hz | 10A RCD | 2.5mm² |

### Safety Features

**Protection Hierarchy:**
1. **Primary**: Building electrical panel protection (15A/10A)
2. **Power Supply**: LRS-35-5 built-in overload protection
3. **Local Disconnect**: IEC inlet integrated switch
4. **Emergency Stop**: Large red arcade button
5. **Software**: ESP32 thermal monitoring with auto-shutdown

**Isolation Requirements:**
- Minimum 4000V between AC and DC circuits (4N35 optocoupler)
- Minimum 5mm physical clearance between high/low voltage
- Continuous equipment grounding per local electrical codes
- No shared grounds between AC and DC sections

## Assembly Guidelines

### Component Layout

**Enclosure Organization (8"x6"x4" ABS):**
```
┌─────────────────────────────┐
│ [E-Stop] [OLED]    [Power]  │ ← Front Panel
│                     [PSU]   │
│ [ESP32-S3]         [SSR]    │ ← Main Section
│ [Sensors] [Term.Blocks]     │
│                             │
│ [IEC Inlet]    [AC Outlet]  │ ← Rear Panel
└─────────────────────────────┘
```

**Safety Zones:**
- **High Voltage Zone**: Right side - PSU, SSR, AC connections
- **Low Voltage Zone**: Left side - ESP32, sensors, DC connections
- **Interface Zone**: Front panel - user controls and display
- **Minimum 5mm separation** between AC and DC components

### Wiring Best Practices

#### AC Wiring (Safety Critical)
- **Wire Colors**: Black=Hot, White=Neutral, Green=Ground (US)
- **Wire Size**: 12 AWG minimum for 15A circuits
- **Strain Relief**: UL-listed cable glands on all external cables
- **Connections**: Terminal blocks or wire nuts (UL listed)
- **Torque**: Follow manufacturer specifications for all terminals

#### DC Wiring
- **STEMMA QT**: Pre-made cables eliminate soldering
- **GPIO Connections**: Use header pins and jumper wires
- **Strain Relief**: Service loops prevent cable tension
- **Labeling**: Clear identification of all connections

### Thermal Management

**ESP32-S3 Cooling:**
- Mount with standoffs for airflow underneath
- Optional: 10x10mm heat sink with thermal adhesive
- Software temperature monitoring with thermal shutdown at 85°C
- Position away from heat-generating components (PSU, SSR)

**Enclosure Ventilation:**
- Ventilation slots above PSU for convection cooling
- Cable entry points sized appropriately to prevent overheating
- Component spacing allows natural air circulation

## Environmental Monitoring

The BME280 sensor provides comprehensive environmental data for analytics and correlation with rodent activity patterns.

### BME280 Specifications
- **Temperature**: -40°C to +85°C (±1.0°C accuracy)
- **Humidity**: 0-100% RH (±3% accuracy)
- **Pressure**: 300-1100 hPa (±1 hPa accuracy)
- **Power**: 1μA sleep, 3.6mA active
- **I2C Address**: 0x77 (STEMMA QT default)

### Analytics Integration
- **Pattern Recognition**: Correlate environmental conditions with captures
- **Predictive Triggering**: Adjust sensitivity based on weather/humidity
- **Home Assistant Dashboards**: Trend analysis and data visualization
- **Maintenance Alerts**: Monitor for condensation risk or extreme temperatures

## Testing & Validation

### Pre-Assembly Testing
1. **Component Verification**: Test each module individually
2. **Power Supply**: Verify 5V output and current capacity
3. **I2C Bus**: Confirm all sensors respond at correct addresses
4. **GPIO Function**: Test emergency stop and SSR control

### Safety Testing (Mandatory)
1. **Isolation Test**: >4MΩ resistance between AC and DC sections
2. **Ground Continuity**: <0.1Ω resistance from inlet to outlet ground
3. **Thermal Test**: Monitor ESP32 temperature under full load
4. **Emergency Stop**: Verify immediate SSR shutdown on button press
5. **Protection Test**: Confirm PSU overload protection functions

### Integration Testing
1. **ESPHome Flash**: Upload configuration and verify WiFi connection
2. **Home Assistant**: Confirm automatic entity discovery
3. **Sensor Calibration**: Verify ToF sensor distance readings
4. **Load Test**: Test with actual shop vacuum connected
5. **Environmental Data**: Confirm BME280 readings are reasonable

## Quality Control Checklist

**Electrical Safety:**
- [ ] All AC connections tight and properly insulated
- [ ] Ground continuity verified throughout system
- [ ] No exposed conductors or sharp edges
- [ ] Strain relief installed on ALL external cables
- [ ] Emergency stop clearly labeled and functional

**Component Installation:**
- [ ] ESP32 mounted with proper standoffs
- [ ] All STEMMA QT connections secure
- [ ] SSR properly mounted with thermal interface
- [ ] Power supply secured and ventilated
- [ ] All terminal screws torqued to specification

**System Function:**
- [ ] WiFi connection established
- [ ] All sensors reporting correct values
- [ ] SSR switching operates correctly
- [ ] Emergency stop immediately disables vacuum
- [ ] OLED display showing proper status information
- [ ] Home Assistant integration working

---

## Related Documents

- **[BOM_CONSOLIDATED.csv](BOM_CONSOLIDATED.csv)** - Complete parts list with vendor information
- **[SAFETY_REFERENCE.md](SAFETY_REFERENCE.md)** - Comprehensive safety procedures
- **[INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md)** - Step-by-step assembly instructions
- **[3D Models/Side_Mount_Control_Box.scad](3D%20Models/Side_Mount_Control_Box.scad)** - Parametric side-mount enclosure design

This electrical design provides a safe, reliable, and cost-effective foundation for the ShopVac Rat Trap while meeting international electrical safety standards.
