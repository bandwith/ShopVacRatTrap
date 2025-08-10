# ShopVac Rat Trap 2025 - Installation & Setup Guide

Installation Guide
==================

> **Note:** For all purchasing details, vendor part numbers, and direct links, see [purchasing/PURCHASE_GUIDE.md](purchasing/PURCHASE_GUIDE.md).

## Pre-Installation Safety Notice

⚠️ **CRITICAL ELECTRICAL HAZARD WARNING** ⚠️

This project involves 120V AC electrical connections. Installation **MUST** be performed by qualified individuals with electrical experience. Improper installation can result in:
- Electrical shock or electrocution (potentially fatal)
- Fire hazard from overloaded circuits or motor overload conditions
- Equipment damage from improper connections or overcurrent faults
- Personal injury from mechanical failures or vacuum motor damage

**🚨 ENHANCED SAFETY REQUIREMENTS (August 2025):**
- **Current Monitoring:** MANDATORY SCT-013-020 current transformer installation
- **Motor Protection:** Automatic shutdown on vacuum overload (>12A)
- **Enhanced Coordination:** 12A fuse with 15A breaker for selective protection

**MANDATORY Qualifications:**
- Understanding of AC electrical safety and NEC code requirements
- Experience with high voltage wiring and proper safety procedures
- Proper electrical tools and PPE (Personal Protective Equipment)
- Knowledge of local electrical codes and permit requirements

**SAFETY COMPLIANCE REQUIREMENTS:**
- **Circuit Protection:** 15A breaker and fuse (properly sized for 8-12A vacuum loads)
- **Wire Gauge:** 12 AWG minimum for all AC circuits (NEC compliance)
- **GFCI Protection:** Required for wet locations (garage, basement, outdoor)
- **Ground Integrity:** Continuous ground path verification mandatory

If you are not qualified to perform electrical work, **STOP** and hire a licensed electrician.

## Required Tools & Equipment

### **Safety Equipment (MANDATORY)**
- [ ] Safety glasses with side shields
- [ ] Insulated electrical gloves (rated for 600V minimum)
- [ ] Non-contact voltage tester
- [ ] Multimeter with CAT III 600V rating
- [ ] **AC current clamp meter** (for CT calibration)
- [ ] **GFCI outlet tester** (Klein RT105 or equivalent)
- [ ] First aid kit with electrical burn treatment

### **Installation Tools**
- [ ] Insulated screwdrivers (Phillips and flathead)
- [ ] Insulated wire strippers (12-22 AWG)
- [ ] Wire nuts (appropriate sizes)
- [ ] Electrical tape (UL listed)
- [ ] Heat shrink tubing and heat gun
- [ ] Soldering iron and lead-free solder
- [ ] 3D printer or access to 3D printing service
- [ ] Drill with metal/plastic bits
- [ ] Digital calipers for verification

### **Testing Equipment**
- [ ] Oscilloscope (optional, for advanced debugging)
- [ ] Logic analyzer (optional, for I2C troubleshooting)
- [ ] Bench power supply (for pre-testing)
- [ ] Load tester for relay verification

## Step-by-Step Installation

### **Phase 1: Component Preparation & Testing**

#### **1.1 Verify Optimized Component List** ✅
```bash
# Create component checklist with cost-optimized design
mkdir -p ~/rat_trap_build
cd ~/rat_trap_build

# Download updated BOM
curl -O https://raw.githubusercontent.com/bandwith/ShopVacRatTrap/main/ELECTRICAL_DESIGN.md
```

**Optimized Components (Cost Savings: -$62.75):**
- [ ] ESP32-S3 Feather (test with blink program)
- [ ] VL53L0X sensor (verify I2C address 0x29)
- [ ] OLED display (verify I2C address 0x3C) - **Integrated status display**
- [ ] **Single LRS-15-5 PSU** (5V/3A, eliminates external 3.3V regulator, -$27)
- [ ] SSR relay 40A (SparkFun COM-13015, chassis mount, -$10 vs kit)
- [ ] **15A Circuit Breaker** (upgraded from 5A for safety compliance)
- [ ] **15A Fuses** (upgraded from 5A for proper protection)
- [ ] Resistors: 2x 10kΩ only (**LEDs eliminated**, -$8 savings)

**ELIMINATED Components (Cost Optimization):**
- ❌ External 3.3V regulator (ESP32 built-in used)
- ❌ Status LEDs (integrated into OLED display)
- ❌ LED current limiting resistors
- ❌ Additional wire complexity

#### **1.2 3D Print Enclosure Components**
```bash
# Print settings for PLA/PETG
Layer Height: 0.2mm
Infill: 20%
Supports: Yes (for overhangs >45°)
Print Speed: 50 mm/s
Temperature: PLA 200°C / PETG 240°C
```

Print order:
1. `Control_Box_Enclosure.scad` - Main housing
2. `Control_Box_Lid.scad` - Removable top
3. `Sensor_Housing_VL53L0X.scad` - Updated sensor mount
4. Existing files: `Rat_Trap_Mouth.stl`, `Vacuum_Hose_Adapter.stl`

#### **1.3 Pre-Test ESP32 & Sensors (Simplified)**
```yaml
# Create optimized test configuration
# Save as: esp32_component_test.yaml
esphome:
  name: component-test-optimized
  platform: ESP32
  board: esp32dev

wifi:
  ssid: "YourTestNetwork"
  password: "YourPassword"

i2c:
  sda: 21
  scl: 22
  scan: true

# Test sensors with ESP32 built-in 3.3V regulator
sensor:
  - platform: vl53l0x
    name: "Test Distance"
    update_interval: 1s

  - platform: template
    name: "ESP32 Temperature"
    lambda: |-
      return temperatureRead();
    update_interval: 10s

display:
  - platform: ssd1306_i2c
    model: "SSD1306 128x64"
    address: 0x3C
    lambda: |-
      it.print(0, 0, "Optimized Design Test");
      it.printf(0, 16, "3.3V from ESP32: OK");
      it.printf(0, 32, "Temp: %.1f°C", id(esp32_temp).state);

font:
  - file: "gfonts://Roboto"
    id: font_default
    size: 10
```

**Verify Optimized Design:**
- [ ] I2C scan detects devices at 0x29 (VL53L0X) and 0x3C (OLED)
- [ ] ESP32 3.3V regulator powers all devices successfully
- [ ] VL53L0X returns stable distance readings
- [ ] OLED displays integrated status information
- [ ] ESP32 temperature monitoring functional
- [ ] No external 3.3V regulator needed (cost savings confirmed)

### **Phase 2: Electrical Assembly**

#### **2.1 AC Power Section Assembly**

**DANGER: Disconnect all power before working on AC sections**

1. **Install IEC C14 Power Inlet**
   ```
   - Mount in rear panel of control box
   - Verify proper grounding connection
   - Use locknut and sealing gasket
   ```

2. **Install Circuit Breaker**
   ```
   - Mount 5A breaker in accessible location
   - Connect Line (Hot) wire from IEC inlet
   - Verify proper operation (should trip at 5A)
   ```

3. **Install NEMA 5-15R Outlet**
   ```
   - Mount in rear panel for vacuum connection
   - Prepare for SSR switching of Line connection
   - Ground and Neutral directly connected
   ```

4. **Optimized Single Power Supply Installation** ⭐
   ```
   - Mount LRS-35-5 with proper ventilation clearance (simplified design)
   - AC Input Screw Terminals:
     * L (Line) ← Connect after 15A circuit breaker and 15A fuse
     * N (Neutral) ← Connect to main neutral bus
   - DC Output Screw Terminals:
     * +5V/7A → ESP32 VIN (single supply solution)
     * GND → Common ground bus
   - ESP32 Built-in 3.3V Regulator:
     * Powers VL53L0X, OLED, and all 3.3V components
     * 600mA capacity >> 99mA actual load (84% safety margin)
   - Verify outputs: 5V ±0.25V, ESP32 3.3V stable under load
   - Isolation Test: Verify >1MΩ between AC and DC sides
   ```

#### **2.2 DC Electronics Assembly**

1. **ESP32 Mounting**
   ```
   - Install on standoffs in control box
   - Ensure USB port accessibility
   - Route antenna away from switching circuits
   ```

2. **Sensor Connections (STEMMA QT Modular)**
   ```
   STEMMA QT Daisy Chain Assembly:
   ESP32-S3 Feather STEMMA QT Port
      ↓ (100mm STEMMA QT cable)
   VL53L0X ToF Sensor (Adafruit 4210)
      ↓ (100mm STEMMA QT cable)
   BME280 Environmental Sensor (Adafruit 4816)
      ↓ (200mm STEMMA QT cable)
   OLED Display (Adafruit 5027)

   Benefits:
   - No soldering required - all JST SH 4-pin connectors
   - Automatic I2C addressing and pull-ups
   - Hot-swappable sensor connections
   - Professional cable management

   Power Budget Verification:
   - ESP32-S3 3.3V regulator: 600mA maximum capacity
   - Total 3.3V load: ~99mA typical (84% safety margin)
   ```

3. **Simplified Control Interface Wiring**
   ```
   Reset Button (GPIO18):
   - One side → GPIO18
   - Other side → GND
   - 10kΩ pull-up to ESP32 3.3V output

   Test Button (GPIO19):
   - One side → GPIO19
   - Other side → GND
   - 10kΩ pull-up to ESP32 3.3V output

   Illuminated Emergency Disable Switch - SAFETY CRITICAL:
   - Switch Contact Side:
     * Common → GPIO4
     * NO → GND
     * 10kΩ pull-up to ESP32 3.3V output
   - LED Side:
     * Anode → GPIO17
     * Cathode → GND

   ELIMINATED (Cost Optimization):
   - Separate status LEDs → Integrated into OLED display
   - Separate power indicator → Integrated into E-stop button
   - Complex LED wiring → Simplified interface

   Benefits:
   - Reduced component count: 10 → 6 items
   - Lower cost: -$8 savings
   - Simplified assembly and troubleshooting
   - Better status display with detailed information
   ```

4. **SSR Control Circuit (Enhanced with Optocoupler Protection)**
   ```
   ESP32 GPIO5 → 4N35 Optocoupler Protection Circuit:

   Input Side (ESP32):
   GPIO5 → 330Ω Resistor → 4N35 LED Anode
   4N35 LED Cathode → ESP32 GND

   Output Side (SSR):
   4N35 Collector → SSR + Control
   4N35 Emitter → SSR - Control (GND)

   AC Switching (unchanged):
   - Input Common → Line from circuit breaker
   - Output NO → Line to NEMA outlet

   Benefits:
   - Double isolation: ESP32 ↔ Optocoupler ↔ SSR ↔ AC Load
   - Total isolation: >8000V (4N35: 5000V + SSR: 4000V)
   - Protects ESP32 from voltage spikes and noise
   - Standard industrial practice for safety-critical switching
   - Minimal cost addition: ~$1.50
   ```

#### **2.3 Safety Verification Checklist**

Before applying power, verify:
- [ ] All AC connections tight and properly insulated
- [ ] No exposed conductors or sharp edges
- [ ] Proper gauge wire used (18AWG minimum for AC)
- [ ] Ground continuity from IEC inlet to outlet
- [ ] Isolation between AC and DC sections >1MΩ
- [ ] Fuse properly installed and rated
- [ ] Circuit breaker functional
- [ ] Strain relief on all external cables

### **Phase 3: Software Configuration**

#### **3.1 ESPHome Installation**
```bash
# Install ESPHome
pip3 install esphome

# Or use Home Assistant Add-on
# Navigate to Supervisor → Add-on Store → ESPHome
```

#### **3.2 Configure Device**
```bash
# Clone project repository
git clone https://github.com/bandwith/ShopVacRatTrap.git
cd ShopVacRatTrap/esphome

# Update secrets.yaml with your settings
cp secrets.yaml secrets_local.yaml
nano secrets_local.yaml
```

Update the following in `secrets_local.yaml`:
```yaml
wifi_ssid: "YourActualNetworkName"
wifi_password: "YourActualPassword"
ota_password: "YourSecureOTAPassword"
api_encryption_key: "GenerateNewKey32Characters"
```

#### **3.3 Generate Security Keys**
```bash
# Generate OTA password
openssl rand -base64 16

# Generate API encryption key
openssl rand -base64 32

# Update secrets_local.yaml with generated keys
```

#### **3.4 Initial Flash**
```bash
# Compile configuration
esphome compile rat-trap-2025.yaml

# Connect ESP32 via USB and flash
esphome upload rat-trap-2025.yaml --device /dev/ttyUSB0

# Monitor initial boot
esphome logs rat-trap-2025.yaml
```

#### **3.5 Verify Installation**
Check log output for:
- [ ] WiFi connection successful
- [ ] I2C devices detected
- [ ] VL53L0X distance readings
- [ ] OLED display functional
- [ ] All GPIO pins responding
- [ ] Home Assistant API connected

### **Phase 4: Calibration & Testing**

#### **4.1 Distance Sensor Calibration**
1. **Baseline Reading**
   ```
   - Mount sensor in final position
   - Record distance to trap floor
   - Verify readings are stable ±2mm
   ```

2. **Detection Threshold**
   ```
   - Place test object at desired trigger distance
   - Adjust threshold in Home Assistant
   - Test with objects of different sizes
   - Verify no false triggers from air movement
   ```

3. **Environmental Testing**
   ```
   - Test in various lighting conditions
   - Verify operation in temperature range
   - Check for interference from other devices
   ```

#### **4.2 Relay & Safety Testing**
1. **Low Power Testing**
   ```bash
   # Connect small load (LED or buzzer) to outlet
   # Test all trigger methods:
   # - Sensor detection
   # - Manual test button
   # - Software trigger via Home Assistant
   ```

2. **High Power Testing**
   ```bash
   # Connect actual shop vacuum
   # Test full load operation
   # Verify relay can handle startup current
   # Monitor for overheating
   ```

3. **Safety System Testing**
   ```bash
   # Test circuit breaker trip
   # Test fuse protection
   # Verify ground fault protection (if GFCI protected)
   # Test emergency stop (relay disable switch)
   ```

#### **4.3 Integration Testing**
1. **Home Assistant Setup**
   ```yaml
   # automation.yaml example
   - alias: "Rat Trap Notification"
     trigger:
       - platform: state
         entity_id: binary_sensor.rat_trap_2025_rodent_detected
         to: 'on'
     action:
       - service: notify.mobile_app
         data:
           message: "Rodent detected in trap!"
           title: "Rat Trap Alert"
   ```

2. **Mobile Notifications**
   ```yaml
   # Add to configuration.yaml
   notify:
     - platform: pushover
       api_key: !secret pushover_api_key
       user_key: !secret pushover_user_key
   ```

### **Phase 5: Final Assembly & Deployment**

#### **5.1 Mechanical Integration**
1. **Trap Assembly**
   ```
   - Install 4" ABS pipe with 3D printed components
   - Mount sensor housing at trap entrance
   - Connect vacuum hose adapter
   - Secure all connections with appropriate fasteners
   ```

2. **Control Box Mounting**
   ```
   - Mount control box on plywood base
   - Ensure accessibility for maintenance
   - Protect from weather if used outdoors
   - Label all controls clearly
   ```

#### **5.2 Final System Testing**
1. **Complete Function Test**
   - [ ] Power on sequence
   - [ ] Display shows correct information
   - [ ] All LEDs functional
   - [ ] Buttons respond correctly
   - [ ] Sensor detection working
   - [ ] Vacuum triggers properly
   - [ ] WiFi and Home Assistant connected

2. **Performance Verification**
   - [ ] Vacuum runtime appropriate (8 seconds default)
   - [ ] Cooldown period prevents false triggers
   - [ ] Capture count increments correctly
   - [ ] System recovers properly after power loss

3. **Safety Final Check**
   - [ ] All electrical connections secure
   - [ ] No exposed high voltage
   - [ ] Ground integrity verified
   - [ ] Illuminated emergency stop functional
   - [ ] E-stop LED illuminates when system armed
   - [ ] E-stop LED turns off when E-stop activated
   - [ ] Enclosure properly sealed

## Maintenance Schedule

### **Monthly**
- [ ] Clean sensor lens with soft cloth
- [ ] Check all electrical connections
- [ ] Test emergency stop switch
- [ ] Verify vacuum hose connection
- [ ] Clean display screen

### **Quarterly**
- [ ] Test circuit breaker operation
- [ ] Inspect fuse condition
- [ ] Check for signs of overheating
- [ ] Update ESPHome firmware
- [ ] Calibrate distance sensor if needed

### **Annually**
- [ ] Replace fuse as preventive maintenance
- [ ] Deep clean all components
- [ ] Inspect 3D printed parts for wear
- [ ] Update security keys
- [ ] Full system performance test

## Troubleshooting Guide

### **Power Issues**
```
Symptom: No power to system
Check: Circuit breaker, fuse, power supply connections
Solution: Reset breaker, replace fuse, verify wiring

Symptom: Intermittent power loss
Check: Loose connections, undersized wire
Solution: Tighten all connections, upgrade wire gauge
```

### **Communication Issues**
```
Symptom: WiFi connection fails
Check: Signal strength, network credentials
Solution: Move closer to router, verify SSID/password

Symptom: Home Assistant not connecting
Check: API key, network configuration
Solution: Regenerate API key, check firewall
```

### **Sensor Issues**
```
Symptom: Erratic distance readings
Check: Sensor mounting, electrical interference
Solution: Secure mounting, shield sensor cables

Symptom: No sensor response
Check: I2C connections, power supply
Solution: Verify wiring, check 3.3V supply
```

### **Relay Issues**
```
Symptom: Relay not switching
Check: Control signal, SSR status
Solution: Verify GPIO output, replace SSR if failed

Symptom: Vacuum runs continuously
Check: Relay contacts, control logic
Solution: Replace SSR, check software configuration
```

## Support & Resources

### **Documentation**
- Project repository: https://github.com/bandwith/ShopVacRatTrap
- ESPHome documentation: https://esphome.io
- Home Assistant: https://home-assistant.io

### **Community Support**
- Home Assistant Community: https://community.home-assistant.io
- ESPHome Discord: https://discord.gg/KhAMKrd
- Reddit r/homeassistant: https://reddit.com/r/homeassistant

### **Professional Support**
For electrical installation assistance, contact:
- Licensed electrician in your area
- Local electrical inspector for code compliance
- Professional home automation installer

**Remember: Safety first! If you have any doubts about electrical safety, consult a professional.**
