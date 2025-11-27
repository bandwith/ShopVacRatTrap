> **⚠️ Work in Progress ⚠️**
>
> This project is under active development. The documentation, features, and hardware recommendations are subject to change. Please check back for updates.

# ShopVac Rat Trap - Installation & Setup Guide
**STEMMA QT Camera System with Enhanced Capabilities**

## Enhanced System Overview

The 2025 version features a revolutionary **STEMMA QT camera system** that provides:

- 🎥 **5MP OV5640 Camera**: Professional quality with autofocus
- 🌙 **High-Power IR LED**: 10+ meter night vision range
- 🔌 **Zero-Solder Assembly**: Complete plug-and-play modularity
- 📊 **Complete Sensor Suite**: Environmental monitoring and ToF detection
- 🏠 **Home Assistant Integration**: Automatic image capture and notifications

### **Key Advantages Over Previous Versions:**
- **2.5x higher resolution** (5MP vs 2MP generic cameras)
- **3x longer IR range** (10+ meters vs 3-5 meters)
- **Modular design** enables easy upgrades and maintenance
- **Professional-grade components** with thermal protection

Installation Guide
==================

> **Note:** For all purchasing details, vendor part numbers, and direct links, see [COMPONENT_SOURCING.md](COMPONENT_SOURCING.md).

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
- [ ] **Precision screwdriver set** (for STEMMA QT connectors)
- [ ] **Cable management tools** (zip ties, cable management clips)
- [ ] **Magnifying glass** (for STEMMA connector inspection)
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
curl -O <https://raw.githubusercontent.com/bandwith/ShopVacRatTrap/main/ELECTRICAL_DESIGN.md>
```

**Required Components:**
- [ ] ESP32-S3 Feather (test with blink program)
- [ ] VL53L0X sensor (verify I2C address 0x29)
- [ ] OLED display (verify I2C address 0x3C) - **Integrated status display**
- [ ] **Single LRS-35-5 PSU** (5V/7A, provides ample capacity for all components)
- [ ] Panasonic AQA411VL SSR 25A (panel mount)
- [ ] **15A Circuit Breaker** (for safety compliance)
- [ ] **15A Fuses** (for proper protection)
- [ ] Resistors: 2x 10kΩ for pull-up circuits

#### **1.2 3D Print Trap Components**
```bash
# Print settings for PETG/ASA
Layer Height: 0.2mm
Infill: 20%
Supports: Yes, for snap-fit clips and other overhangs
Print Speed: 50 mm/s
Temperature: PETG 240°C / ASA 250°C
```

Print order:
1. `trap_entrance.scad`
2. `trap_body_main.scad`
3. `trap_funnel_adapter.scad`
4. `bait_station.scad`

#### **1.3 Test Basic Components**

Test the ESP32 and sensors before assembly:
- [ ] I2C scan detects devices at expected addresses
- [ ] ESP32 3.3V regulator powers all devices successfully
- [ ] Sensors return stable readings
- [ ] Display shows status information
- [ ] ESP32 temperature monitoring functional
- [ ] ESP32-S3 3.3V output adequate for sensor load

### **Phase 2: Enclosure Assembly and Wiring**

This phase covers the assembly of all electronic components inside the recommended **Hammond PN-1334-C** enclosure.

#### **2.1 Enclosure Preparation**

1.  **Mark Cutouts:** Carefully mark the locations for all external components on the enclosure. Use a ruler and fine-tip marker for precision.
    *   **Front Panel:** OLED display, Emergency Stop button, Arcade button.
    *   **Rear Panel:** IEC C14 power inlet, IEC C13 power outlet, and a cable gland for the sensor cable.
2.  **Drill and Cut:**
    *   Use a step drill bit for the round holes (buttons, connectors, cable gland).
    *   Use a rotary tool with a cutting wheel or a small hand saw for the rectangular OLED display cutout.
    *   **Pro Tip:** Drill pilot holes first, and use a slow speed to avoid cracking the ABS plastic.
    *   Deburr all edges with a file or a deburring tool for a clean finish.

#### **2.2 Component Mounting**

1.  **Install External Components:**
    *   Mount the IEC inlet, outlet, buttons, and display in their respective cutouts. Secure them with their included nuts or mounting hardware.
2.  **Mount Internal Components:**
    *   Use a DIN rail or M3 standoffs to mount the ESP32, SSR, and power supply.
    *   Follow the layout recommended in the `ELECTRICAL_DESIGN.md` to ensure proper separation between high and low voltage components.
    *   Attach the thermal pad to the back of the SSR before mounting it.

#### **2.3 Wiring**

**DANGER: Ensure all power is disconnected before wiring.**

1.  **AC Wiring (High Voltage):**
    *   Use 12 AWG wire for all AC connections.
    *   Connect the IEC inlet to the power supply and SSR as shown in the wiring diagram in `ELECTRICAL_DESIGN.md`.
    *   Connect the SSR output to the IEC outlet.
    *   Ensure the ground connection is continuous from the inlet to the outlet and the enclosure itself (if using a metal enclosure).
2.  **DC Wiring (Low Voltage):**
    *   Connect the 5V output of the power supply to the VIN pin of the ESP32 Feather.
    *   Connect the ESP32 to the other low-voltage components (OLED, buttons, sensors) using the STEMMA QT cables and the GPIO pins specified in `ELECTRICAL_DESIGN.md`.
    *   Use the 4N35 optocoupler to isolate the ESP32 from the SSR.
3.  **Sensor Cable:**
    *   Route the STEMMA QT cable for the sensors through the cable gland on the rear panel. This will provide a secure and weather-resistant seal.

### **Phase 3: Software Configuration**

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

2. **Sensor Connections (INLET HUB-BASED - OPTIMAL CONFIGURATION)**
   ```
   Inlet Hub-Based Assembly (Minimized Cable Runs):

   AT INLET AREA:
   QWIIC/STEMMA QT 5-Port Hub (Adafruit 5625)
      ├─ Port 1 → VL53L0X ToF Sensor (50mm cable - co-located)
      ├─ Port 2 → BME280 Environmental (100mm cable - inlet area)
      ├─ Port 3 → [Reserved for Camera Module]
      ├─ Port 4 → [Reserved for Additional Sensors]
      └─ Port 5 → [Reserved for Future Expansion]

   AT CONTROL BOX:
   ESP32-S3 Feather STEMMA QT Port
      ↓ (Single 500mm STEMMA QT cable to inlet hub)
   QWIIC Hub at Inlet (upstream connection)

   OLED Display (Adafruit 5027)
      ↓ (Direct 100mm cable to ESP32 in control box)

   MAJOR BENEFITS of Inlet Hub Placement:
   - ✅ Only 1 cable run between control box and inlet (vs. 3+ separate runs)
   - ✅ Environmental monitoring at actual rodent entry point
   - ✅ Simplified installation with single main cable route
   - ✅ Reduced EMI susceptibility on short sensor cables
   - ✅ Camera and additional sensors can be added at inlet without new cable runs
   - ✅ All detection components accessible at inlet for maintenance

   Alternative: STEMMA QT Daisy Chain Assembly (Alternative method):
   ESP32-S3 Feather STEMMA QT Port
      ↓ (100mm STEMMA QT cable)
   VL53L0X ToF Sensor (Adafruit 4210)
      ↓ (100mm STEMMA QT cable)
   BME280 Environmental Sensor (Adafruit 4816)
      ↓ (200mm STEMMA QT cable)
   OLED Display (Adafruit 5027)

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
git clone <https://github.com/bandwith/ShopVacRatTrap.git>
cd ShopVacRatTrap/esphome

# Update secrets.yaml with your settings
cp secrets.yaml secrets_local.yaml
nano secrets_local.yaml
```

Update the following in `secrets_local.yaml`:
```yaml
wifi_ssid_base64: "$(echo -n 'YourActualNetworkName' | base64)"
wifi_password_base64: "$(echo -n 'YourActualPassword' | base64)"
ota_password_base64: "$(echo -n 'YourSecureOTAPassword' | base64)"
api_encryption_key_base64: "$(openssl rand -base64 32)"  # 32 bytes recommended (base64-encoded)
```

#### **3.3 Generate Security Keys**
```bash
# Generate OTA password
openssl rand -base64 16

# Generate API encryption key (base64)
openssl rand -base64 32

# Update secrets_local.yaml with generated keys
```

#### **3.4 Initial Flash**
```bash
# Compile configuration
esphome compile rat-trap.yaml

# Connect ESP32 via USB and flash
esphome upload rat-trap.yaml --device /dev/ttyUSB0

# Monitor initial boot
esphome logs rat-trap.yaml
```

#### **3.5 Verify Installation**
Check log output for:
- [ ] WiFi connection successful
- [ ] I2C devices detected
- [ ] VL53L0X distance readings
- [ ] OLED display functional
- [ ] All GPIO pins responding
- [ ] Home Assistant API connected

### **Phase 4: Sensor Integration & Testing**

#### **4.1 Hybrid Detection System Setup**

**STANDARD CONFIGURATION (ToF + PIR Backup):**
1. **Primary ToF Sensor Installation**
   ```
   - Mount VL53L0X in sensor tower at 75mm from pipe entrance
   - Connect via STEMMA QT to hub or daisy chain
   - Verify I2C address 0x29 detection
   - Test distance readings with clear line of sight
   ```

2. **PIR Motion Sensor (Backup Detection)**
   ```
   - Mount PIR sensor in backup tower at 85mm from pipe entrance
   - Connect to GPIO13 with 3-pin JST PH cable
   - Verify motion detection sensitivity
   - Test range and field of view coverage
   - Adjust sensitivity potentiometer if needed
   ```

**CAMERA CONFIGURATION (Hybrid Cascaded Detection):**
1. **Primary Camera System**
   ```
   - Mount OV5640 5MP camera at 75mm from pipe entrance
   - Connect via STEMMA QT chain to hub
   - Test camera capture and image quality
   - Verify IR LED illumination timing
   - Configure computer vision parameters
   ```

2. **Secondary PIR Motion Detection**
   ```
   - Install PIR sensor at 85mm position as backup
   - Configure as secondary confirmation sensor
   - Test motion detection reliability
   - Verify integration with camera trigger logic
   ```

3. **Tertiary ToF Confirmation**
   ```
   - Position VL53L0X as final confirmation sensor
   - Configure as distance validation backup
   - Test integration with hybrid detection logic
   ```

#### **4.2 Cascaded Detection Logic Testing**

1. **Multi-Sensor Confirmation**
   ```yaml
   # Test detection requirements in ESPHome:
   # Standard Config: ToF primary + PIR backup (1 of 2 required)
   # Camera Config: Camera primary + PIR + ToF (2 of 3 required)

   # Test scenarios:
   - Single sensor activation (should not trigger)
   - Multiple sensor confirmation (should trigger)
   - False positive rejection
   - Environmental interference immunity
   ```

2. **Detection Timing Validation**
   ```
   - Test rodent entry simulation at various speeds
   - Verify 0.15-0.25 second confirmation window
   - Ensure full entry before vacuum activation
   - Test entrance investigation vs. full entry
   ```

#### **4.3 Distance Sensor Calibration**
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

2. **Camera & IR Testing**
   ```
   - Test camera capture functionality via ESPHome logs
   - Verify IR LED activation with test object detection
   - Check image quality and focus at various distances
   - Test night vision capability with IR illumination
   - Verify image upload to Home Assistant
   ```

3. **STEMMA QT System Testing**
   ```
   - Verify all STEMMA QT devices detected on I2C bus
   - Test sensor chain daisy configuration
   - Check cable connections and strain relief
   - Verify modular component removal/replacement
   ```

4. **Environmental Testing**
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
         entity_id: binary_sensor.rat_trap_rodent_detected
         to: 'on'
     action:
       - service: notify.mobile_app
         data:
           message: "Rodent detected in trap!"
           title: "Rat Trap Alert"
   ```

2. **Mobile Notifications with Images**
   ```yaml
   # Add to configuration.yaml for camera integration
   camera:
     - platform: generic
       still_image_url: "http://rat-trap-ip/capture"
       name: "Rat Trap Camera"

   # automation.yaml with image capture
   - alias: "Rat Trap Detection with Photo"
     trigger:
       - platform: state
         entity_id: binary_sensor.rat_trap_rodent_detected
         to: 'on'
     action:
       - service: camera.snapshot
         target:
           entity_id: camera.rat_trap_camera
         data:
           filename: "/config/www/rat_trap_capture_{{ now().strftime('%Y%m%d_%H%M%S') }}.jpg"
       - service: notify.mobile_app
         data:
           message: "Rodent detected! See attached image."
           title: "Rat Trap Alert"
           data:
             image: "/local/rat_trap_capture_{{ now().strftime('%Y%m%d_%H%M%S') }}.jpg"
   ```

3. **STEMMA QT System Monitoring**
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
- ESPHome documentation: <https://esphome.io>
- Home Assistant: <https://home-assistant.io>

### **Community Support**
- Home Assistant Community: <https://community.home-assistant.io>
- ESPHome Discord: <https://discord.gg/KhAMKrd>
- Reddit r/homeassistant: <https://reddit.com/r/homeassistant>

### **Professional Support**
For electrical installation assistance, contact:
- Licensed electrician in your area
- Local electrical inspector for code compliance
- Professional home automation installer

**Remember: Safety first! If you have any doubts about electrical safety, consult a professional.**
