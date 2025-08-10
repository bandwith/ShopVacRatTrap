# ShopVac Rat Trap - AI Agent Instructions

## Project Overview
Modern ESP32-based IoT rat trap with ToF sensor, OLED display, and Home Assistant integration. **Recently optimized (Aug 2025)** for safety compliance, cost reduction (-19%), and simplified assembly.

## Core Architecture & Data Flow
```
[120V AC Input] → [15A Protection] → [Single PSU] → [ESP32 + Built-in 3.3V]
                                                         ↓
[Shop Vacuum] ← [SSR 25A] ← [GPIO5] ← [ESPHome Logic] ← [ToF I2C Sensor]
                                                      ↓
[OLED Status Display] ← [I2C Bus] → [Integrated Status (No LEDs)]
```

**Key Design Decision**: Single power supply + ESP32 built-in 3.3V regulator eliminates external regulators, saving costs, and reducing complexity while avoiding any PCB, SMD, or THT component assembly.

## Critical File Relationships

### ESPHome Configurations (Choose Based on Hardware)
- `esphome/rat-trap-2025.yaml` - **Primary config** with optimized single PSU design
- `esphome/rat-trap-ttgo-display.yaml` - For integrated ESP32+TFT boards
- `esphome/rat-trap-budget.yaml` - Budget-friendly configuration with essential features

### Design Documentation Hierarchy
1. `ELECTRICAL_DESIGN.md` - **Start here** for BOM and circuit design
2. `INSTALLATION_GUIDE.md` - Safety procedures and assembly steps
3. `3D Models/Control_Box_Enclosure.scad` - Parametric enclosure design
4. `SAFETY_REFERENCE.md` - Consolidated safety guidelines
5. `QUICK_START.md` - Quick start guide for installation and setup

## Project-Specific Development Patterns

### ESPHome Component Integration
```yaml
# Always use configurable parameters (not hardcoded values)
number:
  - platform: template
    name: "Detection Threshold (mm)"
    id: detection_threshold
    initial_value: 150

# Thermal protection is mandatory
sensor:
  - platform: template
    name: "ESP32 Temperature"
    lambda: |-
      return temperatureRead();
    filters:
      - lambda: |-
          if (x > 85.0) {
            id(thermal_shutdown).execute();
          }
```

### Status Display Pattern (No Separate LEDs)
**Critical**: Status integrated into OLED display to reduce component count (cost savings).
```yaml
display:
  lambda: |-
    if (id(trap_triggered).state) {
      it.filled_rectangle(0, 26, 128, 16, COLOR_ON);  # Visual highlight
      it.print(2, 30, id(font_medium), COLOR_OFF, ">> VACUUM ON <<");
    }
```

### International Support Patterns
When modifying code, be aware of the voltage-specific configurations:
```yaml
substitutions:
  # 🇺🇸 North America (120V AC, 60Hz, NEC compliant)
  line_voltage: "120V AC"
  line_frequency: "60Hz"
  max_current: "15A"
  safety_standard: "NEC/UL"

  # 🇪🇺 Europe (230V AC, 50Hz, IEC/CE compliant)
  # line_voltage: "230V AC"
  # line_frequency: "50Hz"
  # max_current: "10A"
  # safety_standard: "IEC/CE"
```

### Environmental Monitoring Pattern
The BME280 sensor is used for environmental monitoring and analytics:
```yaml
# Environmental sensor for temperature, humidity, pressure
sensor:
  - platform: bme280
    address: 0x76
    update_interval: 60s
    temperature:
      name: "Environmental Temperature"
    humidity:
      name: "Environmental Humidity"
    pressure:
      name: "Barometric Pressure"
```

### Safety-Critical GPIO Assignments
```yaml
# These pins are standardized - don't change without updating 3D models
gpio:
  - pin: 5    # SSR control (120V AC switching) - SAFETY CRITICAL
  - pin: 4    # Emergency disable switch (safety critical)
  - pin: 21   # I2C SDA (sensor + display)
  - pin: 22   # I2C SCL (sensor + display)

# SAFETY RULE: GPIO5 must NEVER be used for anything except SSR control
# SAFETY RULE: GPIO4 emergency disable must remain accessible and functional
# SAFETY RULE: Pull-ups must be to ESP32 3.3V output, not external supply
```

### ⚠️ **Electrical Safety Checklist for Modifications**

**Before suggesting ANY electrical changes, verify:**
- [ ] **Power Analysis**: 3.3V budget remains <400mA total
- [ ] **Thermal Impact**: No components near ESP32 that generate >5W heat
- [ ] **Wire Gauge**: All AC connections use ≥12 AWG wire
- [ ] **Protection**: 15A breaker/fuse ratings maintained
- [ ] **Isolation**: No shared grounds between AC and DC sides
- [ ] **Emergency Access**: GPIO4 disable switch remains functional
- [ ] **Code Compliance**: All changes follow NEC electrical code

**When suggesting power supply changes:**
1. **MANDATORY**: Verify new PSU maintains >1MΩ AC/DC isolation
2. **MANDATORY**: Confirm PSU is UL/CE listed for safety compliance
3. **MANDATORY**: Check thermal dissipation fits enclosure design
4. **REQUIRED**: Update `ELECTRICAL_DESIGN.md` BOM immediately
5. **REQUIRED**: Modify `Control_Box_Enclosure.scad` mounting if needed

## Development Workflow Commands

### ESPHome Development
```bash
# Test configuration without flashing
esphome config rat-trap-2025.yaml

# Flash with monitoring (first time requires USB)
esphome run rat-trap-2025.yaml --device /dev/ttyUSB0

# OTA update (after initial flash)
esphome run rat-trap-2025.yaml

# Live sensor monitoring
esphome logs rat-trap-2025.yaml
```

### 3D Model Modification
```bash
# Generate STL from parametric SCAD
openscad -o Control_Box_Enclosure.stl Control_Box_Enclosure.scad

# Key parameters to modify:
# - box_width/depth/height (component fit)
# - power_supply_width/length (PSU mounting)
# - component positions (front panel layout)
```

### Power Budget Validation
```yaml
# SAFETY CRITICAL: Always verify 3.3V load against ESP32 600mA limit
# Current loads (from ELECTRICAL_DESIGN.md):
# VL53L0X ToF Sensor: 15mA typical, 30mA peak
# OLED Display: 15mA typical, 25mA peak
# BME280 Environmental: 1μA sleep, 3.6mA active
# ESP32-S3: 45-70mA WiFi active
# Total: 61-99mA (84% safety margin)

# SAFETY RULE: Never exceed 400mA total 3.3V load (66% of ESP32 limit)
# SAFETY RULE: Account for WiFi transmission spikes (+50mA)
# SAFETY RULE: Include temperature derating for hot environments
# SAFETY RULE: Only use pre-assembled modules with known power requirements
```

### ⚠️ **CRITICAL SAFETY PROCEDURES** ⚠️

**When AI agents suggest sensor additions:**
1. **MANDATORY**: Check I2C address conflicts first
2. **MANDATORY**: Calculate additional 3.3V current draw
3. **MANDATORY**: Verify total load <400mA including new sensor
4. **REQUIRED**: Update thermal analysis if the sensor generates heat
5. **REQUIRED**: Check enclosure space and mounting requirements
6. **REQUIRED**: Only use pre-assembled modules - NO PCB, SMD, or through-hole components allowed in this project

**When AI agents suggest relay/switching changes:**
1. **STOP**: Never suggest changes to 120V AC switching without explicit electrical engineering review
2. **MANDATORY**: All AC switching must use UL-listed SSR ≥25A rating
3. **MANDATORY**: Maintain complete galvanic isolation between 3.3V and 120V
4. **REQUIRED**: Verify GPIO5 drive capability for SSR control signal
5. **REQUIRED**: Emergency disable (GPIO4) must override all switching logic

## Safety & Electrical Integration Critical Points

### ⚠️ **MANDATORY SAFETY PROTOCOLS FOR AI AGENTS** ⚠️

**NEVER suggest modifications that:**
- Bypass 15A circuit protection (breaker + fuse)
- Use undersized wire gauge (<12 AWG for AC circuits)
- Eliminate ground connections or isolation barriers
- Increase 3.3V loads beyond ESP32 600mA capacity
- Remove thermal monitoring or safety shutdowns
- Require PCB design, SMD soldering, or through-hole component assembly

**ALWAYS verify before suggesting changes:**
1. **Power budget**: Total 3.3V draw ≤ 400mA (66% of ESP32 limit)
2. **Thermal impact**: Additional components won't exceed 85°C ESP32 limit
3. **Isolation integrity**: >1MΩ between AC and DC sides maintained
4. **Code compliance**: All AC modifications follow NEC standards
5. **Safety redundancy**: Dual protection (breaker + fuse) preserved

### High Voltage Isolation Requirements
- **15A circuit protection** (not 5A) - recently upgraded for code compliance
- **12 AWG wire** for all AC circuits (NEC requirement)
- **>1MΩ isolation** between AC and DC sides
- **GFCI protection** mandatory for wet locations

### International Compliance Requirements
- **🇺🇸 US/North America**: NEC/UL standards, 120V AC, 60Hz, 15A protection
- **🇪🇺 Europe**: IEC/CE standards, 230V AC, 50Hz, 10A protection
- **Wire colors**: US (Black/White/Green), EU (Brown/Blue/Green-Yellow)
- **Outlets**: NEMA 5-15R (US), CEE 7/7 Schuko (EU)

### Component Sourcing Strategy
**Primary vendors**: Major electronic component distributors (power/safety/dev boards), mechanical hardware suppliers
**Alternate vendors**: Online electronics retailers, maker-focused shops
**Component requirements**:
- Use only pre-assembled modules (no raw PCB, SMD, or through-hole components)
- Select chassis/panel-mount components wherever possible
- Prioritize components with screw terminals over soldered connections
- Choose UL/CE listed components for all high-voltage sections

## Cross-Component Communication Patterns

### ESPHome ↔ Home Assistant
- **Automatic discovery** via mDNS/API
- **Entity naming**: Use descriptive names matching physical labels
- **State persistence**: Capture count, thresholds, runtime settings
- **Thermal monitoring**: Temperature sensors exposed for HA graphing

### 3D Models ↔ Electronics
- **Enclosure constraints drive component layout**: ESP32 standoffs, PSU mounting, display cutouts
- **Thermal management**: Ventilation slots aligned with PSU cooling requirements
- **Service access**: USB port accessible, front panel components user-reachable

## Common Modification Patterns

### Adding New Sensors
1. Check I2C address conflicts (VL53L0X=0x29, OLED=0x3C, BME280=0x77)
2. Verify 3.3V power budget (ESP32 600mA limit)
3. Update 3D enclosure for mounting points
4. Add ESPHome configuration with appropriate filters

### Power Supply Changes
1. Update `ELECTRICAL_DESIGN.md` BOM section
2. Modify `Control_Box_Enclosure.scad` mounting brackets
3. Adjust ESPHome power monitoring if voltage changes
4. Verify thermal clearances and ventilation

### Display Customization
Use existing OLED integration pattern - avoid separate LEDs:
```yaml
# Add new status information to existing display lambda
it.printf(0, new_line, id(font_small), "New Status: %s", status.c_str());

# For visual highlighting (status indicators)
it.filled_rectangle(0, 26, 128, 16, COLOR_ON);  # Creates highlight bar
it.print(2, 30, id(font_medium), COLOR_OFF, ">> STATUS TEXT <<");  # Inverted text
```

### User Interface Patterns
All status information is displayed on the OLED using this hierarchy:
```yaml
# OLED Display Layout Pattern
display:
  lambda: |-
    # Header with system info
    it.printf(0, 0, id(font_small), "Rat Trap %s %s", id(line_voltage).c_str(), id(safety_standard).c_str());

    # WiFi status indicator (top right)
    if (id(wifi_component).is_connected()) {
      it.printf(105, 0, id(font_small), "WiFi");
    } else {
      it.printf(100, 0, id(font_small), "No Net");
    }

    # Primary sensor reading (large, prominent)
    it.printf(0, 12, id(font_medium), "Distance: %.0fmm", id(trap_distance).state);

    # Status section with visual highlighting
    if (id(trap_triggered).state) {
      it.filled_rectangle(0, 26, 128, 16, COLOR_ON);
      it.print(2, 30, id(font_medium), COLOR_OFF, ">> VACUUM ON <<");
    }

    # Statistics section (middle-bottom)
    it.printf(0, 42, id(font_small), "Captures: %.0f", id(capture_count_sensor).state);

    # Environmental data section (bottom)
    it.printf(0, 47, id(font_small), "Env: %.1f°C  %.0f%%RH",
             id(env_temperature).state, id(env_humidity).state);

    # System monitoring (very bottom)
    it.printf(0, 56, id(font_small), "WiFi: %.0fdBm  CPU: %.1f°C",
              id(wifi_signal).state, id(esp32_temp).state);
```

## Testing & Validation Workflow

### ⚠️ **MANDATORY SAFETY TESTING** ⚠️

**Before ANY code deployment:**
1. **Isolation Test**: Verify >1MΩ resistance between AC and DC sections
2. **Thermal Test**: Monitor ESP32 temperature under full WiFi load (must stay <75°C)
3. **Emergency Stop**: Verify GPIO4 switch immediately disables vacuum relay
4. **Ground Continuity**: Confirm <0.1Ω resistance from IEC ground to enclosure
5. **Power Budget**: Measure actual 3.3V current draw vs. calculated values

### Standard Testing Sequence
1. **Component verification**: Test ESP32 3.3V output capacity before assembly
2. **Thermal testing**: Monitor ESP32 temperature under full WiFi load
3. **Safety testing**: Isolation resistance, ground continuity, thermal shutdown
4. **Integration testing**: ESPHome + Home Assistant entity discovery
5. **Load testing**: Full vacuum startup current through SSR

### ⚠️ **EMERGENCY PROCEDURES FOR AI AGENTS** ⚠️

**If thermal shutdown is triggered:**
1. **IMMEDIATE**: Log thermal event with timestamp and temperature
2. **IMMEDIATE**: Disable vacuum relay (GPIO5 = LOW)
3. **IMMEDIATE**: Initiate deep sleep mode for cooldown
4. **REQUIRED**: Do not restart until ESP32 temperature <50°C
5. **ANALYSIS**: Review what caused thermal event before restart

**If emergency disable activated:**
1. **IMMEDIATE**: All vacuum control must cease
2. **IMMEDIATE**: Log emergency stop event
3. **REQUIRED**: Display clear "EMERGENCY STOP" message on OLED
4. **REQUIRED**: Remain in safe state until emergency switch reset
5. **FORBIDDEN**: No automatic restart - requires manual intervention

**Remember**: This project switches 120V AC - electrical safety is paramount. When in doubt, consult the detailed safety procedures in `INSTALLATION_GUIDE.md`.
