ShopVac Rat Trap - 2025 Optimized Design
===========================================

**Professional-grade ESP32 based IoT rat trap with ToF sensor detection, integrated status display, and simplified assembly.**

## Key Features

- **Smart Detection**: VL53L0X time-of-flight sensor with 2m range and millimeter precision
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

## 2025 STEMMA QT Upgrade Benefits

**Major Improvements Over ESP32-CAM:**
- ✅ **5MP vs 2MP**: Higher resolution for better animal identification
- ✅ **Extended IR range**: Improved night vision capabilities
- ✅ **Zero-solder assembly**: Complete STEMMA QT/JST ecosystem
- ✅ **Modular design**: Easy component replacement and upgrades
- ✅ **Enhanced power management**: Optimized current draw with better thermal performance

## Hardware Configurations

### **Standard Configuration** (ESP32-S3 Feather) - `rat-trap-2025.yaml`
**Control Box Components** (Side-mounted enclosure):
- ESP32-S3 Feather controller with WiFi connectivity
- OLED display (128x64) for status monitoring and user interface
- Large arcade button for manual trigger/reset
- Emergency stop switch for safety compliance
- Power supply, SSR, and terminal blocks

**Inlet Components** (Detection assembly):
- VL53L0X ToF sensor for distance detection
- BME280 environmental sensor for monitoring conditions
- STEMMA QT 5-Port Hub to minimize cable count (single 500mm cable to control box)
- Weatherproof housing and mounting hardware

### **STEMMA QT Camera System** (ESP32-S3 + OV5640) - `rat-trap-stemma-camera.yaml`
**Control Box Components** (Same as standard):
- ESP32-S3 Feather controller with enhanced processing capability
- OLED display for status and camera system monitoring
- Large arcade button and emergency stop switch
- Power supply with sufficient capacity for camera system

**Inlet Components** (Enhanced detection assembly):
- OV5640 5MP Camera with autofocus lens for computer vision detection
- VL53L0X ToF sensor for backup distance detection
- BME280 environmental sensor for monitoring conditions
- High-Power IR LED for night vision illumination
- STEMMA QT 5-Port Hub for centralized sensor management
- Single 500mm cable connection to control box

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

### **Core System Architecture - STEMMA QT Enhanced**

```
[120V/230V AC] → [Circuit Protection] → [Mean Well PSU] → [ESP32-S3 + Built-in 3.3V]
                                                            ↓
[Shop Vacuum] ← [25A SSR] ← [GPIO5] ← [ESPHome Logic] ← [VL53L0X STEMMA QT]
                                                        ↓
[5MP Camera (OV5640)] ← [Secondary I2C] ← [ESP32-S3] → [STEMMA QT Bus] → [BME280] → [OLED]
                                         ↓                                              ↑
[High-Power IR LED] ← [STEMMA JST PH] ← [GPIO6]                                      └─ [Daisy Chain]
```

### **STEMMA QT Power Management (Enhanced)**

```
ESP32-S3 Built-in 3.3V Regulator (600mA capacity):
├─ VL53L0X ToF Sensor: 30mA peak (STEMMA QT)
├─ BME280 Environmental: 3.6mA active (STEMMA QT)
├─ OLED Display: 25mA peak (STEMMA QT)
├─ OV5640 Camera: 100mA capture, 20mA idle (secondary I2C)
├─ High-Power IR LED: 200mA pulsed (STEMMA JST PH)
├─ ESP32-S3 Core: 70mA WiFi active
└─ Total Peak Load: 431mA (72% headroom for thermal derating) ✅ APPROVED
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
