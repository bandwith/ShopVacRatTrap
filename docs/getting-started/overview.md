# ShopVac Rat Trap

> **⚠️ Work in Progress ⚠️**
>

This project implements a modern IoT-based rodent control system using advanced STEMMA QT hybrid detection sensors and simplified assembly. The design eliminates complex wiring and provides a robust multi-sensor detection architecture.

## Key Features

- **Hybrid Detection System**: APDS9960 (optical proximity) + VL53L4CX (ToF distance) + STHS34PF80 (IR body heat/presence) + LSM6DSOX (6-DoF vibration/tamper) + Vision AI with 4-of-5 confirmation logic for maximum reliability
- **Vision & Telemetry Options**: Direct 5MP OV5640 autofocus snapshot capture or Grove Vision AI V2 on-device Edge-AI NPU with MicroSD telemetry logging and acoustic monitoring
- **High-Power Night Vision**: 10+ meter range IR illumination via STEMMA JST PH module
- **Complete STEMMA Ecosystem**: Zero-solder assembly with plug-and-play modularity
- **Integrated Status Display**: 128x64 OLED with comprehensive system monitoring
- **Enhanced Processing**: ESP32-S3 Feather with 8MB Flash for advanced image processing and sensor fusion
- **Modular Architecture**: All sensors connected via STEMMA QT/JST for easy maintenance, with ESPHome configuration split into modular packages for improved readability and reusability.
- **Professional Controls**: 30mm arcade button emergency disable with visual feedback and industrial E-stop
- **Safety Compliant**: NEC/IEC electrical standards with 15A circuit protection
- **WiFi Connectivity**: ESPHome integration with Home Assistant automation
- **Global Support**: 120V/230V configurations for worldwide deployment

## ⚠️ Legal and Patent Disclaimer

**IMPORTANT: This project is for educational and experimental purposes only. It is the responsibility of each builder and user to ensure that their use of this project does not infringe on any patents in their jurisdiction.**

The concept of a vacuum-based rodent trap may be subject to patent protection. Commercial products with similar functionality exist, and it is likely they are protected by one or more patents. Before building, using, or distributing this project, especially for any purpose other than personal, non-commercial experimentation, you are strongly advised to:

1.  Conduct your own thorough patent search.
2.  Consult with a qualified patent attorney to assess potential infringement risks.

The authors and contributors of this project provide this design "as is" without any warranty, express or implied, and assume no liability for any damages or legal issues arising from its use.

## 🔧 System Architecture

**Modern Design Improvements:**
- ✅ **Horizontal & Modular Design**: Lays flat for stability and uses snap-fit connectors for easy, tool-free assembly.
- ✅ **Large 4-Inch Opening**: Accommodates a wide variety of rodent sizes.
- ✅ **Removable Bait Station**: Allows for easy baiting without disassembling the trap.
- ✅ **All-in-One Electronics Enclosure**: All electronic components are housed in a single, commercially available enclosure for maximum safety, reliability, and code compliance.

## Theory of Operation

The reliability of the trap hinges on its multi-stage detection logic, which is designed to be both highly sensitive to rodents and resilient to false positives. The system operates entirely offline, meaning a WiFi connection is not required for the core detection and trapping functionality.

The detection process unfolds in a multi-modal sequence as a rodent enters the trap:

1.  **Stage 1: Primary Detection (Optical Proximity)**
    *   **Sensor**: APDS9960 Proximity/Gesture Sensor (`3595`)
    *   **Location**: Positioned at the top of the trap tube, looking down.
    *   **Function**: Emits infrared light and measures reflection. As a rodent enters, reflection rises sharply, triggering the optical entry flag.

2.  **Stage 2: Secondary Confirmation (Distance Ranging)**
    *   **Sensor**: VL53L4CX Time-of-Flight (ToF) Distance Sensor (`5425`)
    *   **Location**: Positioned inside the entrance tube looking inward.
    *   **Function**: Measures precise distance to target in millimeters (within the configurable 50-500mm bounds) to verify a physical target is inside.

3.  **Stage 3: Tertiary Confirmation (Thermal Body Heat)**
    *   **Sensor**: STHS34PF80 IR Temperature & Presence Sensor (`6426`)
    *   **Location**: Positioned on the entrance / body junction.
    *   **Function**: Detects live infrared thermal signatures and optical blackbody motion.

4.  **Stage 4: Quaternary Confirmation (Mechanical Vibration & Tampering)**
    *   **Sensor**: LSM6DSOX 6-DoF Accelerometer (`4438`)
    *   **Location**: Rigidly coupled to the entrance/chassis.
    *   **Function**: Flags acceleration transients above the threshold (e.g. >12.0 m/s²) caused by rodent movement, scurrying, or impact.

5.  **Stage 5: Vision Intelligence & Data Logging**
    *   **Option A (Direct DVP Snapshot)**: Adafruit 5946 OV5640 5MP camera captures high-resolution photo with high-power IR LED illumination.
    *   **Option B (Edge-AI Telemetry & MicroSD Logger)**: Seeed Grove Vision AI Module V2 (`101021112`) runs on-device TinyML inference, streams bounding box/confidence data via UART, logs telemetry to MicroSD, and captures acoustic vocalizations via onboard PDM mic.

### Trigger Logic: Multi-Sensor Confirmation (4-of-5 Quorum)
The vacuum trigger logic (`is_rodent_detected` in `detection_logic.h`) evaluates signals from all active sensors. The trap only triggers when the configurable quorum (default 4-of-5 signals) is satisfied simultaneously within the validation window, virtually eliminating false activations.

## Hardware Configurations

### **Standard Configuration** (ESP32-S3 Feather) - `rat-trap.yaml`

**Electronics Enclosure** (Commercially available, user-supplied):
- ESP32-S3 Feather controller (`5323`)
- OLED display (128x64, `326`)
- 30mm arcade button (`471`)
- Emergency stop switch (`XB6ETN521P`)
- Mean Well LRS-35-5 power supply, Panasonic AQA411VL SSR, Schurter DF11 inlet, and Schurter 6600.3100 outlet

**Trap Assembly**:
- `trap_entrance` with integrated APDS9960 (`3595`) and VL53L4CX (`5425`) sensors
- `trap_body_main` with integrated STHS34PF80 (`6426`) and LSM6DSOX (`4438`) sensors
- `trap_funnel_adapter` to connect to a shop vacuum
- `bait_station` (removable)

### **Camera & Advanced Telemetry Systems**

#### Option A: Direct Snapshot Camera (OV5640) - `rat-trap.yaml`
- Adafruit 5946 OV5640 5MP camera breakout wired via DVP parallel bus
- Adafruit 5639 high-power IR LED for night illumination

#### Option B: Edge-AI Vision & MicroSD Logger - `rat-trap-stemma-camera.yaml`
- Seeed Studio Grove Vision AI Module V2 (`101021112`) with dual Cortex-M55 + Ethos-U55 NPU
- Onboard digital microphone for rodent acoustic squeak detection
- MicroSD card slot for offline event, photo, and audio telemetry logging
- UART telemetry connection (`GPIO16`/`GPIO17`) streaming classification results to ESP32

## Detection Strategy - Enhanced Hybrid System

### **Multi-Modal Sensor Confirmation (Fully Offline Operation)**
**Standard Configuration (4-of-5 Confirmation):**
- **Optical Proximity**: APDS9960 proximity & gesture sensor
- **Distance Ranging**: VL53L4CX Time-of-Flight sensor (50-500mm window)
- **Thermal Signature**: STHS34PF80 IR temperature & motion/presence sensor
- **Vibration & Tamper**: LSM6DSOX 6-DoF accelerometer
- **Vision Confirmation**: Camera AI confirmation (OV5640 or Grove Vision AI)
- **Logic**: Configurable quorum (default 4 of 5 signals) required for trigger

**Vision & Evidence Capture Configurations:**
- **Option A (OV5640 DVP)**: Direct 5MP high-resolution photo dispatched via ESPHome / Home Assistant
- **Option B (Grove Vision AI V2)**: Continuous on-device Edge-AI classification, bounding boxes, acoustic rodent squeak detection, and local MicroSD offline event logging

**Benefits of Enhanced Hybrid Approach:**
- ✅ **Fully offline operation** - No WiFi required for detection logic
- ✅ **APDS9960 proximity detection** - Superior to computer vision for rodent detection
- ✅ **Three-sensor redundancy** - Eliminates false positives from any single sensor failure
- ✅ **Evidence capture** - Camera provides visual confirmation sent to Home Assistant
- ✅ **Gesture detection capability** - APDS9960 can distinguish different movement patterns
- ✅ **Ambient light awareness** - APDS9960 RGB sensor provides lighting context
- ✅ **Proven reliability** - Based on successful APDS9960 implementation

## Component Overview

> **Note:** For all purchasing details, vendor part numbers, and direct links, see [Component Sourcing](../hardware/sourcing.md).

**Complete Bill of Materials and sourcing information available in [Electrical Design](../hardware/electrical.md)**

## Electrical Architecture

### **Power Distribution (NEC/IEC Compliant)**

```
🇺🇸 120V AC / 🇪🇺 230V AC Input:
├─ Circuit Breaker (15A/10A) → Fuse Protection → Single Power Supply
├─ Large Arcade Button Emergency Disable (NEC 422.31(B) / IEC 60204-1 Category 0)
├─ 25A SSR (>4000V isolation) → Vacuum Outlet
└─ ESP32-S3 Built-in 3.3V Regulation ← 5V from PSU
```

### **Core System Architecture - All-in-One Enclosure**

```
[COMMERCIAL ENCLOSURE (User-Supplied)]
[120V/230V AC] → [IEC Inlet+CB] → [Mean Well PSU] → [25A SSR] → [Shop Vacuum Outlet]
    │               └─ [E-Stop]         │               ↑
    └────────────────────────────────── [ESP32-S3] ─────────┘
                                          │
                                          ├─ [OLED Display]
                                          ├─ [Arcade Button]
                                          └─ [STEMMA QT to Sensors]

[TRAP ASSEMBLY (3D Printed, Snap-Fit)]
[trap_entrance] ← [trap_body_main] ← [trap_funnel_adapter]
    ├─ [APDS9960]
    ├─ [VL53L4CX ToF]
    ├─ [STHS34PF80 IR]
    └─ [LSM6DSOX IMU]
```

### **STEMMA QT Power Management (Optimized)**

```
ESP32-S3 Built-in 3.3V Regulator (600mA capacity):
├─ OLED Display: 25mA peak (Control Box - STEMMA QT)
├─ ESP32-S3 Core: 70mA WiFi active
└─ INLET SENSOR ASSEMBLY (via STEMMA QT bus):
   ├─ APDS9960 Proximity: 5mA active
   ├─ VL53L4CX ToF Sensor: 30mA peak
   ├─ STHS34PF80 IR Sensor: 1.5mA active
   ├─ LSM6DSOX 6-DoF IMU: 0.55mA active
   ├─ BME280 Environmental: 3.6mA active
   ├─ STEMMA QT Hub: 5mA
   └─ [Vision Options]:
      ├─ Option A: OV5640 Camera (100mA capture) + IR LED (200mA pulsed)
      └─ Option B: Grove Vision AI V2 (powered independently via 5V rail)

Total Load Standard: ~140mA (76% headroom) ✅ EXCELLENT
Total Load Option A: ~440mA peak capture (26% headroom) ✅ APPROVED
Total Load Option B: ~140mA on 3.3V bus (NPU runs on 5V rail) ✅ APPROVED
```

### **Safety Features (Code Compliant)**

- **Dual Protection**: Circuit breaker + fuse per NEC 240.4 / IEC 60364
- **Proper Isolation**: >4000V between AC/DC per UL 508A / IEC 61010-1
- **Emergency Stop**: Illuminated disable switch per NEC 422.31(B) / IEC 60204-1
- **Wire Sizing**: 12AWG/1.5mm² for AC circuits per NEC/IEC standards
- **Thermal Management**: ESP32 temperature monitoring with automatic shutdown

## Quick Start Guide

# Building and Running

> [!TIP]
> **Start Here**: For step-by-step build instructions, including 3D printing, wiring, and assembly, see the **[Assembly Guide](../hardware/assembly.md)**.

## Prerequisites:
*   Electrical safety knowledge (for AC wiring).
*   Access to a 3D printer.
*   ESPHome development environment.
*   Basic electronics assembly skills.

### **🔨 Build Process**

1. **Review Safety Requirements** - Read [Electrical Design](../hardware/electrical.md) safety section
2. **Order Components** - Use detailed BOM
3. **3D Print Enclosures** - All files in [`3d_models/`](https://github.com/bandwith/ShopVacRatTrap/tree/main/3d_models) directory
4. **Assemble Electronics** - Follow NEC/IEC compliant wiring diagrams
5. **Flash Firmware** - Use [`esphome/rat-trap.yaml`](https://github.com/bandwith/ShopVacRatTrap/blob/main/esphome/rat-trap.yaml) configuration
6. **Test & Calibrate** - Complete safety and function testing
7. **Deploy** - Install with proper weatherproofing and electrical inspection

## Purchasing & Component Sourcing

### **📦 Quick Purchase Options**

The project includes automated purchase links and bulk upload files for streamlined component ordering:

- **[Component Sourcing](../hardware/sourcing.md)** - Complete purchase guide with direct links

### **📁 Project Documentation**

| Document | Purpose |
|----------|---------|
| **[Electrical Design](../hardware/electrical.md)** | Complete BOM, wiring, safety standards |
| **[Assembly Guide](../hardware/assembly.md)** | Step-by-step assembly with safety protocols |
| **[README.md](https://github.com/bandwith/ShopVacRatTrap/blob/main/README.md)** | Project overview and design specifications |
| **[`esphome/rat-trap.yaml`](https://github.com/bandwith/ShopVacRatTrap/blob/main/esphome/rat-trap.yaml)** | Main ESP32 firmware configuration (uses packages) |
| **[`esphome/packages/`](https://github.com/bandwith/ShopVacRatTrap/tree/main/esphome/packages)** | Modular ESPHome configuration packages |

## System Operation

### **Integrated OLED Status Display**

- **System Status**: Armed/Triggered/Disabled with visual highlighting
- **Distance Reading**: Real-time sensor data in millimeters
- **Capture Statistics**: Total count with persistent storage
- **Network Status**: WiFi connection and IP address
- **Safety Monitoring**: ESP32 temperature and system health

### **Physical Controls (Safety Critical)**

- **Emergency Disable**: Master safety switch (NEC 422.31(B) compliant)
- **Test Button**: Manual vacuum trigger for system verification
- **Reset Button**: ESP32 restart and fault condition clearing

### **Smart Detection Features**

- **Adaptive Thresholds**: Configurable detection distance (50-500mm)
- **Cooldown Timer**: Prevents false triggers (10-300 seconds)
- **Thermal Protection**: Automatic shutdown at 85°C ESP32 temperature
- **Power-On Safety**: SSR disabled during boot sequence

## International Compliance

### **🇺🇸 North America (NEC/UL)**

- NEMA 5-15R outlets, 15A circuit protection
- GFCI protection for wet locations
- Wire colors: Black (Hot), White (Neutral), Green (Ground)

### **🇪🇺 Europe (IEC/CE)**

- CEE 7/7 Schuko or country-specific outlets
- 10A MCB + RCD protection required
- Wire colors: Brown (Line), Blue (Neutral), Green/Yellow (Earth)
- CE marking mandatory for commercial use

### **🌍 Other Regions**

- **🇬🇧 UK**: BS 1363 outlets, Part P compliance
- **🇦🇺 Australia**: AS/NZS 3112 outlets, RCD protection
- **🇨🇦 Canada**: CSA standards, CEC compliance

## Troubleshooting

### **Safety Issues (Address Immediately)**

- **No Power**: Check circuit breaker, fuse integrity, and AC connections
- **Ground Fault**: Verify continuous ground path with multimeter
- **Overheating**: ESP32 thermal shutdown indicates cooling or load issues
- **Arc/Spark**: Immediately disconnect power and inspect all AC connections

### **System Issues**

- **WiFi Connection**: Use fallback hotspot mode for reconfiguration
- **False Triggers**: Adjust detection threshold or sensor mounting position
- **Display Problems**: Verify I2C connections and check for address conflicts
- **SSR Problems**: Confirm 3.3V control signal and AC load connections

### **Maintenance Schedule**

- **Monthly**: Clean VL53L4CX sensor lens, inspect all visible connections
- **Quarterly**: Test emergency disable switch, verify all button functions
- **Annually**: Professional electrical inspection, fuse replacement, firmware updates

## Home Assistant Integration

### **Automated Features**

- **Mobile Notifications**: Instant alerts for captures and system faults
- **Historical Data**: Capture trends and system performance monitoring
- **Remote Control**: Vacuum testing and system configuration
- **Health Monitoring**: WiFi signal, temperature, and uptime tracking

### **Example Automation**

```yaml
automation:
  - alias: "Rat Trap Capture Alert"
    trigger:
      platform: state
      entity_id: binary_sensor.rodent_detected
      to: 'on'
    action:
      - service: notify.mobile_app
        data:
          message: "Rodent captured! System cycling vacuum."
          data:
            tag: "rat_trap"
            actions:
              - action: "DISABLE_TRAP"
                title: "Disable Trap"
```

## Support & Resources

### **Project Repository**

- **GitHub**: <https://github.com/bandwith/ShopVacRatTrap>
- **Issues**: Bug reports and feature requests
- **Discussions**: Community support and modifications

### **Technical Documentation**

- **ESPHome Platform**: <https://esphome.io>
- **Home Assistant**: <https://home-assistant.io>
- **Electrical Standards**: NEC (US), IEC 60204-1 (International)

### **Safety Resources**

- **Safety Documentation**: See [Safety Reference](safety.md) for comprehensive safety guidelines
- **Electrical Safety**: Always consult qualified electricians for AC work
- **Code Compliance**: Check local electrical codes and permit requirements

**⚠️ Electrical Safety Notice: This project involves potentially dangerous AC voltages. Installation must be performed by qualified individuals following all applicable electrical codes and safety procedures.**

---
**Components:** 17 items, fully STEMMA QT compatible, no-solder assembly

Credits
-------

Original Inspiration: <https://shoprodentstoppers.com/products/rat-vac-motion-sensor-rodent-catching-systems>

Forked from: <https://github.com/shellster/ShopVacRatTrap>

Shop Vacuum Adapter OpenSCAD starting point: <https://www.thingiverse.com/thing:1246651>
