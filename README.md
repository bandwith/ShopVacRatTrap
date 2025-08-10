ShopVac Rat Trap - 2025 Optimized Design
==========================================

**Professional-grade ESP32-based IoT rat trap with cost-optimized power management, integrated status display, and comprehensive safety compliance.**

## Key Features

- **Smart Detection**: VL53L0X time-of-flight sensor with 2m range and millimeter precision
- **Integrated Status Display**: 128x64 OLED with visual status indicators (eliminates separate LEDs)
- **Modular Design**: STEMMA QT connectors for no-solder assembly
- **Enhanced Processing**: ESP32-S3 with 4MB Flash + 2MB PSRAM for advanced features
- **LiPo Battery Backup**: 2500mAh battery provides 25+ hours backup power
- **Physical Controls**: Large arcade button emergency disable and test trigger
- **Cost-Optimized Power**: Single power supply with ESP32-S3 built-in 3.3V regulation
- **Safety Compliant**: NEC/IEC electrical standards with proper circuit protection
- **WiFi Connectivity**: ESPHome integration with Home Assistant automation
- **Global Support**: 120V/230V configurations for worldwide deployment

## 2025 Design Optimizations

### **Cost Savings Achieved: -$47 (19% reduction)**

- **Single Power Supply**: ESP32 built-in 3.3V regulator eliminates external regulators (-$27)
- **Integrated Status Display**: OLED and illuminated E-stop replace separate indicators (-$16)
- **Simplified Controls**: Streamlined interface reduces component count (-$12)
- **Enhanced Safety**: Upgraded to 15A circuit protection for proper vacuum load handling

### **Available Build Options**

| Option | Processing | Total Cost | Best For |
|--------|-------------|------------|----------|
| **Recommended** | ESP32-S3 + STEMMA QT | **$149** | Most builders |
| **Enhanced** | ESP32-S3 + LiPo Battery | **$164** | Portable/backup power |

## Component Overview

> **Note:** For all purchasing details, vendor part numbers, and direct links, see [purchasing/PURCHASE_GUIDE.md](purchasing/PURCHASE_GUIDE.md).

**Complete Bill of Materials and sourcing information available in [ELECTRICAL_DESIGN.md](ELECTRICAL_DESIGN.md)**

### **Core System Architecture**

```
[120V/230V AC] → [Circuit Protection] → [Mean Well PSU] → [ESP32-S3 + Built-in 3.3V]
                                                            ↓
[Shop Vacuum] ← [25A SSR] ← [GPIO5] ← [ESPHome Logic] ← [VL53L0X STEMMA QT]
                                                        ↓
[OLED Status Display] ← [STEMMA QT Bus] → [BME280 Environmental Sensor]
                                        ↓
[LiPo Battery Backup] ← [ESP32-S3 Charger] ← [5V from PSU]
```
                                   [LiPo Battery Backup]
```

## Electrical Architecture

### **Power Distribution (NEC/IEC Compliant)**

```
🇺🇸 120V AC / 🇪🇺 230V AC Input:
├─ Circuit Breaker (15A/10A) → Fuse Protection → Single Power Supply
├─ Large Arcade Button Emergency Disable (NEC 422.31(B) / IEC 60204-1 Category 0)
├─ 25A SSR (>4000V isolation) → Vacuum Outlet
└─ Equipment Ground (12AWG / 1.5mm²) → Enclosure

ESP32-S3 Power Management:
├─ 5V Input from Mean Well PSU → ESP32-S3 VIN
├─ LiPo Battery (2500mAh) → Automatic backup power
└─ Built-in 3.3V Regulator (600mA) → VL53L0X + OLED + BME280 via STEMMA QT (99mA max)
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
2. **Order Components** - Use detailed BOM with multiple vendor options
3. **3D Print Enclosures** - All files in [3D Models](3D%20Models/) directory
4. **Assemble Electronics** - Follow NEC/IEC compliant wiring diagrams
5. **Flash Firmware** - Use [rat-trap-2025.yaml](esphome/rat-trap-2025.yaml) configuration
6. **Test & Calibrate** - Complete safety and function testing
7. **Deploy** - Install with proper weatherproofing and electrical inspection

## Purchasing & Component Sourcing

### **📦 Quick Purchase Options**

The project includes automated purchase links and bulk upload files for streamlined component ordering:

- **[purchasing/PURCHASE_GUIDE.md](purchasing/PURCHASE_GUIDE.md)** - Complete purchase guide with direct links
- **`purchasing/mouser_upload_consolidated.csv`** - Upload directly to Mouser BOM tool
- **`purchasing/adafruit_order_consolidated.csv`** - Adafruit component list with cart URL
- **`purchasing/sparkfun_order_consolidated.csv`** - SparkFun components with cart URL

### **🛒 One-Click Ordering**

| Supplier | Components | Upload File | Direct Link |
|----------|------------|-------------|-------------|
| **Mouser** | Power supplies, enclosure, AC components | `purchasing/mouser_upload_consolidated.csv` | [BOM Upload Tool](https://www.mouser.com/tools/bom-tool) |
| **Adafruit** | ESP32, sensors, STEMMA QT modules | See cart URL file | [Shopping Cart](https://www.adafruit.com/shopping_cart) |
| **SparkFun** | Solid State Relay, Qwiic modules | See cart URL file | [Cart](https://www.sparkfun.com/cart) |

### **💰 Cost Breakdown**

- **Total Project Cost**: ~$213 (single unit, list pricing)
- **Adafruit Components**: 54.6% - ESP32, sensors, cables
- **Mouser Components**: 33.6% - Power supply, enclosure, AC parts
- **SparkFun Components**: 11.7% - Solid state relay

*Volume pricing available for 10+ units with estimated 15-25% savings*

### **📁 Project Documentation**

| Document | Purpose |
|----------|---------|
| **[ELECTRICAL_DESIGN.md](ELECTRICAL_DESIGN.md)** | Complete BOM, wiring, safety standards |
| **[INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md)** | Step-by-step assembly with safety protocols |
| **[DESIGN_OPTIMIZATION_SUMMARY.md](DESIGN_OPTIMIZATION_SUMMARY.md)** | Cost savings and design improvements |
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

## Design Evolution Summary

### **2025 Optimizations Achieved**

- ✅ **Cost Reduction**: 19% savings through component integration
- ✅ **Safety Enhancement**: Full NEC/IEC electrical code compliance
- ✅ **Global Support**: 120V/230V configurations for worldwide deployment
- ✅ **Simplified Assembly**: Reduced component count and wiring complexity
- ✅ **Enhanced Reliability**: ESP32 built-in regulation, thermal protection
- ✅ **Professional Quality**: Industrial-grade components and proper protection

### **Key Technical Decisions**

| Component | 2024 Design | 2025 Optimized | Improvement |
|-----------|-------------|----------------|-------------|
| **Processing** | ESP32 basic | ESP32-S3 + 2MB PSRAM | Enhanced performance |
| **Connectivity** | Soldered I2C | STEMMA QT modular | No-solder assembly |
| **Power Backup** | AC only | LiPo battery backup | 25+ hours backup |
| **Status Display** | Separate LEDs | Integrated OLED | Professional interface |
| **Assembly** | Complex wiring | Modular connectors | Beginner-friendly |

## 🤖 Automated BOM Management

This project includes **GitHub Actions automation** for comprehensive BOM validation and pricing management using the **Nexar API**.

### **Automated Features**

- 📊 **Weekly Pricing Updates**: Automatic validation and updates of all component pricing
- 🚨 **Availability Monitoring**: Daily checks for critical component stock levels
- 💰 **Cost Change Alerts**: Automatic issues created for significant price changes
- 📦 **Supply Chain Risk**: Early warnings for out-of-stock safety-critical components
- 🔄 **Backup System**: Previous pricing automatically preserved before updates

### **Setup**

1. **Get Nexar API credentials** (free): [nexar.com/api](https://nexar.com/api)
2. **Add GitHub secrets**: `NEXAR_CLIENT_ID` and `NEXAR_CLIENT_SECRET`
3. **Workflows activate automatically** - see [GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md)

### **Benefits**

- ✅ **Always Current**: BOM pricing automatically updated with market data
- ⚡ **Proactive Alerts**: Issues created before supply chain problems impact builds
- 📈 **Cost Tracking**: Historical pricing trends for budget planning
- 🔍 **Quality Assurance**: Verification that all parts exist and are available

*The automation ensures your project costs and supply chain remain optimized with zero manual effort.*

---

**⚠️ Electrical Safety Notice: This project involves potentially dangerous AC voltages. Installation must be performed by qualified individuals following all applicable electrical codes and safety procedures.**

Credits
-------

Original Inspiration: <https://shoprodentstoppers.com/products/rat-vac-motion-sensor-rodent-catching-systems>

Shop Vacuum Adapter OpenSCAD starting point: <https://www.thingiverse.com/thing:1246651>
