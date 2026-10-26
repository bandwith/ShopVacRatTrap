# ShopVac Rat Trap

> **⚠️ Work in Progress ⚠️**
>

This project implements a modern IoT-based rodent control system using advanced STEMMA QT hybrid detection sensors and simplified assembly. The design eliminates complex wiring and provides a robust multi-sensor detection architecture.

## Key Features

- **Hybrid Detection System**: APDS9960 (primary) + VL53L0X (secondary) + PIR (tertiary) for maximum reliability
- **5MP Camera System**: OV5640 STEMMA QT camera with autofocus and enhanced resolution
- **High-Power Night Vision**: 10+ meter range IR illumination via STEMMA JST PH module
- **Complete STEMMA Ecosystem**: Zero-solder assembly with plug-and-play modularity
- **Integrated Status Display**: 128x64 OLED with comprehensive system monitoring
- **Enhanced Processing**: ESP32-S3 Feather with 8MB Flash for advanced image processing
- **Modular Architecture**: All sensors connected via STEMMA QT/JST for easy maintenance, with ESPHome configuration split into modular packages for improved readability and reusability.
- **Professional Controls**: Large arcade button emergency disable with visual feedback
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

The detection process unfolds in a sequence as a rodent enters the trap:

1.  **Stage 1: Primary Detection (Proximity)**
    *   **Sensor**: APDS9960 Proximity/Gesture Sensor
    *   **Location**: Positioned at the top of the trap tube, looking down.
    *   **Function**: This is the first line of detection. The APDS9960 emits infrared light and measures the reflection. When a rodent passes underneath, the reflected light intensity increases sharply, triggering the first detection flag. This sensor is highly effective for detecting the presence of a nearby object without being fooled by minor environmental changes.

2.  **Stage 2: Secondary Confirmation (Distance)**
    *   **Sensor**: VL53L0X Time-of-Flight (ToF) Sensor
    *   **Location**: Positioned at the bottom of the trap tube, looking up.
    *   **Function**: If the primary sensor is triggered, the system queries the ToF sensor. This sensor measures the exact distance to the object above it. A valid reading (e.g., a distance corresponding to the height of a rodent) confirms that a physical object is inside the tube, rather than just a shadow or a change in light. This provides a crucial secondary confirmation.

### 2. Intelligent Hybrid Detection
- **Multi-Sensor Logic**: Uses a "2 of 3" confirmation system (PIR Motion + VL53L0X Distance + APDS9960 Proximity) to eliminate false triggers. See **[Sensor Logic](../hardware/sensor-logic.md)** for detailed placement diagrams and logic explanation.
- **Visual Classification**: A **Seeed Studio XIAO ESP32S3 Sense** (all-in-one camera module with 8MB PSRAM) runs TinyML models to classify rodents by species and size in real-time.
- **Chew-Resistant Design**: All 3D printed components feature reinforced **4mm thick walls** to withstand rodent teeth and ensure long-term durability.
- **Safety First**: Integrated emergency stop, current monitoring, and isolation protocols.

3.  **Stage 3: Tertiary Backup (Motion)**
    *   **Location**: Positioned on the side of the trap tube.
    *   **Function**: The PIR sensor detects the infrared radiation (heat) emitted by a moving animal. It serves as a robust backup and a third data point. Its wide field of view ensures that any movement within the trap zone is detected.

4.  **Trigger Logic: 2 of 3 Confirmation**
    *   The vacuum is only activated when **at least two of the three** detection systems are triggered simultaneously. This "2 of 3" logic is the key to preventing false positives. A single sensor anomaly (e.g., a flash of light fooling the proximity sensor, or a warm draft affecting the PIR) will not trigger the trap. This redundancy ensures that the system is confident that a rodent is inside before activation.

5.  **Evidence Capture (Camera Variant)**
    *   **Sensor**: OV5640 5MP Camera
        *   **Function**: If the camera variant is used, a high-resolution image is captured the moment the trap is triggered. This image is then sent to Home Assistant for logging and notification, providing visual confirmation of the capture.

This layered, multi-sensor approach ensures that the trap is both effective and reliable, minimizing the chances of false alarms while maximizing the probability of a successful capture.

## Hardware Configurations

### **Standard Configuration** (ESP32-S3 Feather) - `rat-trap.yaml`

> **Note:** The ESPHome configuration for this variant is now modularized using packages in the `../../../esphome/packages/` directory for improved maintainability and readability.

**Electronics Enclosure** (Commercially available, user-supplied):
- ESP32-S3 Feather controller
- OLED display (128x64)
- Large arcade button
- Emergency stop switch
- Power supply, SSR, and terminal blocks

**Trap Assembly**:
- `trap_entrance` with integrated APDS9960 and VL53L0X sensors
- `trap_body_main` with integrated PIR sensor
- `trap_funnel_adapter` to connect to a shop vacuum
- `bait_station` (removable)

### **STEMMA QT Camera System** (ESP32-S3 + OV5640) - `rat-trap-stemma-camera.yaml`
**Electronics Enclosure** (Same as standard, with additional components):
- All standard components
- OV5640 5MP Camera
- High-Power IR LED

**Trap Assembly** (Enhanced with camera and IR):
- `trap_entrance` with integrated APDS9960, VL53L0X, and OV5640 camera
- `trap_body_main` with integrated PIR sensor and high-power IR LED
- `trap_funnel_adapter` to connect to a shop vacuum
- `bait_station` (removable)

## Detection Strategy - Enhanced Hybrid System

### **Multi-Modal Sensor Confirmation (Fully Offline Operation)**
**Standard Configuration:**
- **Primary**: APDS9960 proximity/gesture detection (offline)
- **Secondary**: VL53L0X ToF distance confirmation
- **Tertiary**: PIR motion sensor backup
- **Logic**: 2 of 3 sensors required for trigger

**Camera Configuration:**
- **Primary**: APDS9960 proximity/gesture detection (offline)
- **Secondary**: VL53L0X ToF distance confirmation
- **Tertiary**: PIR motion sensor backup
- **Evidence**: OV5640 camera captures photo for Home Assistant logging
- **Logic**: 2 of 3 detection sensors required for trigger

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
    ├─ [VL53L0X]
    └─ [PIR Sensor]
```

### **STEMMA QT Power Management (Optimized)**

```
ESP32-S3 Built-in 3.3V Regulator (600mA capacity):
├─ OLED Display: 25mA peak (Control Box - STEMMA QT)
├─ ESP32-S3 Core: 70mA WiFi active
└─ INLET SENSOR ASSEMBLY (via 500mm STEMMA QT cable):
   ├─ APDS9960 Proximity: 15mA active
   ├─ VL53L0X ToF Sensor: 30mA peak
   ├─ PIR Motion Sensor: 5mA active
   ├─ BME280 Environmental: 3.6mA active
   ├─ STEMMA QT Hub: 5mA
   └─ [Camera Variant]:
      ├─ OV5640 Camera: 100mA capture, 20mA idle
      └─ High-Power IR LED: 200mA pulsed

Total Load Standard: 149mA (75% headroom) ✅ EXCELLENT
Total Load Camera: 379mA peak capture (37% headroom) ✅ APPROVED
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

- **Monthly**: Clean VL53L0X sensor lens, inspect all visible connections
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
