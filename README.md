ShopVac Rat Trap - 2025 Optimized Design
==========================================

**Professional-grade ESP32-based IoT rat trap with cost-optimized power management, integrated status display, and comprehensive safety compliance.**

## Key Features
- **Smart Detection**: VL53L1X time-of-flight sensor with 4m range and millimeter precision
- **Integrated Status Display**: 128x64 OLED with visual status indicators (eliminates separate LEDs)
- **Physical Controls**: Illuminated emergency disable switch, test trigger, and reset button
- **Cost-Optimized Power**: Single power supply with ESP32 built-in 3.3V regulation (-$27 savings)
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
| Option | Power Supply | Total Cost | Best For |
|--------|-------------|------------|----------|
| **Recommended** | LRS-35-5 (7A) | **$61** | Most builders |
| **Premium** | HDR-30-5 DIN Rail | **$73** | Professional installs |

## Component Overview

> **Note:** For all purchasing details, vendor part numbers, and direct links, see [BOM_OCTOPART.csv](BOM_OCTOPART.csv) and [PURCHASE_LINKS.md](PURCHASE_LINKS.md).

Budget build: See [BOM_BUDGET.csv](BOM_BUDGET.csv) for the cost-optimized configuration (excludes vacuum). Note: with a UL panel SSR and BME280 kept, current total is above $100; see BOM notes for trade-offs.

**Complete Bill of Materials and sourcing information available in [ELECTRICAL_DESIGN.md](ELECTRICAL_DESIGN.md)**

### **Core System Architecture**
```
[120V/230V AC] → [Circuit Protection] → [Single PSU] → [ESP32 + Built-in 3.3V]
                                                           ↓
[Shop Vacuum] ← [25A SSR] ← [GPIO5] ← [ESPHome Logic] ← [VL53L1X I2C Sensor]
                                                        ↓  
[OLED Status Display] ← [I2C Bus] → [Integrated Visual Status (No LEDs)]
```

## Electrical Architecture

### **Power Distribution (NEC/IEC Compliant)**
```
🇺🇸 120V AC / 🇪🇺 230V AC Input:
├─ Circuit Breaker (15A/10A) → Fuse Protection → Single Power Supply
├─ Illuminated Emergency Disable Switch (NEC 422.31(B) / IEC 60204-1 Category 0)
├─ 25A SSR (>4000V isolation) → Vacuum Outlet
└─ Equipment Ground (12AWG / 1.5mm²) → Enclosure

ESP32 Power Management:
├─ 5V Input from PSU → ESP32 VIN
└─ Built-in 3.3V Regulator (600mA) → VL53L1X + OLED + E-stop LED + Pull-ups (160mA max)
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
- **Monthly**: Clean VL53L1X sensor lens, inspect all visible connections
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
- **GitHub**: https://github.com/bandwith/ShopVacRatTrap
- **Issues**: Bug reports and feature requests
- **Discussions**: Community support and modifications

### **Technical Documentation**
- **ESPHome Platform**: https://esphome.io
- **Home Assistant**: https://home-assistant.io  
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
| **Power Supply** | Dual rail PSU + regulator | Single PSU + ESP32 regulator | -$27, simplified |
| **Status Display** | Separate LEDs | Integrated OLED + Illuminated E-stop | -$16, better UX |
| **Circuit Protection** | 5A undersized | 15A properly sized | Safety compliant |
| **Control Interface** | Complex multi-switch | Streamlined 3-button | -$12, easier use |
| **Compliance** | Basic safety | NEC/IEC standards | Professional grade |

---

**⚠️ Electrical Safety Notice: This project involves potentially dangerous AC voltages. Installation must be performed by qualified individuals following all applicable electrical codes and safety procedures.**

Credits
-------

Original Inspiration: https://shoprodentstoppers.com/products/rat-vac-motion-sensor-rodent-catching-systems

Shop Vacuum Adapter OpenSCAD starting point: https://www.thingiverse.com/thing:1246651
