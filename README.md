ShopVac Rat Trap - 2025 Design
================================

**Professional-grade ESP32 based IoT rat trap with hybrid sensor detection, integrated status display, and simplified assembly.**

## 🚀 August 2025 System Overview

This project implements a modern IoT-based rodent control system using advanced STEMMA QT hybrid detection sensors and simplified assembly. The design eliminates complex wiring and provides a robust multi-sensor detection architecture.

## Key Features

- **Hybrid Detection System**: APDS9960 (primary) + VL53L0X (secondary) + PIR (tertiary) for maximum reliability
- **5MP Camera System**: OV5640 STEMMA QT camera with autofocus and enhanced resolution
- **High-Power Night Vision**: 10+ meter range IR illumination via STEMMA JST PH module
- **Complete STEMMA Ecosystem**: Zero-solder assembly with plug-and-play modularity
- **Integrated Status Display**: 128x64 OLED with comprehensive system monitoring
- **Enhanced Processing**: ESP32-S3 Feather with 8MB Flash for advanced image processing
- **Modular Architecture**: All sensors connected via STEMMA QT/JST for easy maintenance
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
- ✅ **Simplified Wiring**: Single 500mm STEMMA QT cable: control box ↔ inlet sensors
- ✅ **Zero-Solder Assembly**: Complete STEMMA QT/JST ecosystem for all detection components
- ✅ **Centralized Detection**: All sensors optimally positioned at trap inlet
- ✅ **Enhanced Weather Protection**: Dedicated IP65 inlet sensor assembly
- ✅ **Modular Upgrades**: Inlet sensors independently replaceable/upgradeable
- ✅ **Better Thermal Management**: Heat-generating components separated from sensors

## Hardware Configurations

### **Standard Configuration** (ESP32-S3 Feather) - `rat-trap-2025.yaml`
**Control Box Components** (Side-mounted enclosure):
- ESP32-S3 Feather controller with WiFi connectivity
- OLED display (128x64) for status monitoring and user interface
- Large arcade button for manual trigger/reset
- Emergency stop switch for safety compliance
- Power supply, SSR, and terminal blocks

**Inlet Sensor Assembly** (NEW - Weatherproof hybrid detection):
- APDS9960 proximity/gesture sensor for primary detection (offline)
- VL53L0X ToF sensor for distance confirmation (secondary)
- PIR motion sensor for backup motion detection (tertiary)
- BME280 environmental sensor for monitoring conditions
- STEMMA QT 5-Port Hub for centralized sensor management
- Single 500mm STEMMA QT cable to control box
- Weatherproof IP65 enclosure and mounting hardware

### **STEMMA QT Camera System** (ESP32-S3 + OV5640) - `rat-trap-stemma-camera.yaml`
**Control Box Components** (Same as standard):
- ESP32-S3 Feather controller with enhanced processing capability
- OLED display for status and camera system monitoring
- Large arcade button and emergency stop switch
- Power supply with sufficient capacity for camera system

**Inlet Sensor Assembly** (Enhanced with camera and IR):
- APDS9960 proximity/gesture sensor for primary detection (offline)
- VL53L0X ToF sensor for distance confirmation (secondary)
- PIR motion sensor for motion backup detection (tertiary)
- BME280 environmental sensor for monitoring conditions
- OV5640 5MP Camera for evidence capture and Home Assistant logging
- High-Power IR LED for night vision illumination
- STEMMA QT 5-Port Hub for centralized sensor management
- Single 500mm STEMMA QT cable to control box

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

> **Note:** For all purchasing details, vendor part numbers, and direct links, see [COMPONENT_SOURCING.md](COMPONENT_SOURCING.md).

**Complete Bill of Materials and sourcing information available in [ELECTRICAL_DESIGN.md](ELECTRICAL_DESIGN.md)**

## Electrical Architecture

### **Power Distribution (NEC/IEC Compliant)**

```
🇺🇸 120V AC / 🇪🇺 230V AC Input:
├─ Circuit Breaker (15A/10A) → Fuse Protection → Single Power Supply
├─ Large Arcade Button Emergency Disable (NEC 422.31(B) / IEC 60204-1 Category 0)
├─ 25A SSR (>4000V isolation) → Vacuum Outlet
└─ ESP32-S3 Built-in 3.3V Regulation ← 5V from PSU
```

### **Core System Architecture - STEMMA QT Simplified**

```
[120V/230V AC] → [Circuit Protection] → [Mean Well PSU] → [ESP32-S3 + Built-in 3.3V]
                                                            ↓
[Shop Vacuum] ← [25A SSR] ← [GPIO5] ← [ESPHome Logic] ← [Single 500mm STEMMA Cable]
                                                        ↓
[INLET SENSOR ASSEMBLY] - Weatherproof IP65 Enclosure:
├─ STEMMA QT 5-Port Hub (Adafruit 5625)
├─ APDS9960 Proximity/Gesture (Adafruit 3595) - Primary Detection
├─ VL53L0X ToF Distance (Adafruit 3317) - Secondary Confirmation
├─ PIR Motion Sensor (Adafruit 4871) - Tertiary Backup
├─ BME280 Environmental (Adafruit 4816) - Monitoring
└─ [Camera Variant: OV5640 5MP + IR LED] - Evidence Capture

[CONTROL BOX] - Side-Mount Enclosure:
├─ ESP32-S3 Feather (Adafruit 5323) - Controller
├─ OLED Display (Adafruit 326) - User Interface
├─ Large Arcade Button (Adafruit 368) - Manual Control
├─ Emergency Stop Switch - Safety Critical
└─ Mean Well PSU + 25A SSR - Power & AC Switching
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

### **📋 Prerequisites**

- **⚠️ Electrical Safety Knowledge Required** - 120V/230V AC work must be performed by qualified individuals
- 3D printer access for enclosures
- ESPHome development environment
- Basic electronics assembly skills

### **🔨 Build Process**

1. **Review Safety Requirements** - Read [ELECTRICAL_DESIGN.md](ELECTRICAL_DESIGN.md) safety section
2. **Order Components** - Use detailed BOM
3. **3D Print Enclosures** - All files in [3D Models](3D%20Models/) directory
4. **Assemble Electronics** - Follow NEC/IEC compliant wiring diagrams
5. **Flash Firmware** - Use [rat-trap-2025.yaml](esphome/rat-trap-2025.yaml) configuration
6. **Test & Calibrate** - Complete safety and function testing
7. **Deploy** - Install with proper weatherproofing and electrical inspection

## Purchasing & Component Sourcing

### **📦 Quick Purchase Options**

The project includes automated purchase links and bulk upload files for streamlined component ordering:

- **[COMPONENT_SOURCING.md](COMPONENT_SOURCING.md)** - Complete purchase guide with direct links
- **`purchasing/mouser_upload_consolidated.csv`** - Upload directly to Mouser BOM tool
- **`purchasing/adafruit_order_consolidated.csv`** - Adafruit component list with cart URL
- **`purchasing/sparkfun_order_consolidated.csv`** - SparkFun components with cart URL

### **🛒 One-Click Ordering**

| Supplier | Components | Upload File | Direct Link |
|----------|------------|-------------|-------------|
| **Mouser** | Power supplies, enclosure, AC components | `purchasing/mouser_upload_consolidated.csv` | [BOM Upload Tool](https://www.mouser.com/tools/bom-tool) |

### **💰 Cost Breakdown**

- **Total Project Cost**: ~$146.10 (single unit, list pricing)

*Volume pricing available for 10+ units*

### **📁 Project Documentation**

| Document | Purpose |
|----------|---------|
| **[ELECTRICAL_DESIGN.md](ELECTRICAL_DESIGN.md)** | Complete BOM, wiring, safety standards |
| **[INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md)** | Step-by-step assembly with safety protocols |
| **README.md** | Project overview and design specifications |
| **[esphome/rat-trap-2025.yaml](esphome/rat-trap-2025.yaml)** | Optimized ESP32 firmware configuration |

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

- **Safety Documentation**: See [SAFETY_REFERENCE.md](SAFETY_REFERENCE.md) for comprehensive safety guidelines
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
