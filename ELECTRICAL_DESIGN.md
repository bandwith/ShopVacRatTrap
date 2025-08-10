# ShopVac Rat Trap 2025 - Electrical Design & BOM

> **Note:** For all purchasing details, vendor part numbers, and direct links, see [BOM_OCTOPART.csv](BOM_OCTOPART.csv) and [PURCHASE_LINKS.md](PURCHASE_LINKS.md).

## **Design Overview**

This updated design focuses on safety, reliability, and simplified assembly with integrated components and standardized thermal management.

## **Design Features**

The following design improvements enhance safety and simplify assembly:

1. **Integrated IEC Inlet with Fuse & Switch**
   - Single integrated component with IEC C14 + fuse holder + rocker switch
   - Simplified assembly with single panel cutout
   - UL/CE listed as complete assembly for improved safety compliance

2. **Optimized Terminal Connections**
   - Push-in terminal blocks for simplified wiring
   - Direct wiring for AC side through integrated IEC inlet
   - Improved reliability by reducing connection points

3. **Professional Control Interface**
   - Emergency stop button for improved safety
   - Software-based testing via Home Assistant interface
   - Streamlined user interface with clear safety controls

4. **Environmental Monitoring**
   - BME280 sensor for temperature, humidity, and pressure monitoring
   - Integrated into existing I2C bus (no additional wiring complexity)
   - Provides valuable environmental data correlation with rodent activity

## **Electrical Safety & Compliance** ⚠️

**Note:** For comprehensive safety information and full compliance details, please refer to the [SAFETY_REFERENCE.md](SAFETY_REFERENCE.md) document.

This design meets all applicable electrical safety codes including NEC Article 422 (Appliances), Article 430 (Motors), and international standards for IEC/CE compliance.

### **IEC Appliance Inlet Solution**

| Qty | Component | Part Number | Description |
|-----|-----------|-------------|-------------|
| 1 | Enhanced IEC Inlet w/ EMI + MOV | 4304.6093 | Integrated: IEC C14 + EMI filter + MOV + fuse + switch |
| 1 | NEMA 5-15R Outlet | 5262 | 120V AC vacuum output (15A rated) |
| 2 | Fast Blow Fuse 15A | 5x20mm 15A | Fuse elements (15A, 250V) |

**Safety Updates:**

- **Circuit Breaker:** Upgraded from 5A to **15A** for proper shop vacuum protection (NEC 422.11)
- **Fuses:** Upgraded from 5A to **15A** to match breaker rating (NEC 240.4)
- **Compliance:** Proper sizing for 8-12A shop vacuum loads with safety margin
- **Grounding:** Continuous equipment grounding conductor per NEC 250.114

### **🇪🇺 European/CE Components (230V AC, 50Hz)**

| Qty | Component | Part Number | Description |
|-----|-----------|-------------|-------------|
| 1 | Enhanced IEC Inlet w/ EMI + MOV | 4304.6063 | 230V: IEC C14 + EMI + MOV + fuse + switch |
| 2 | Fast Blow Fuse 10A | 5x20mm 10A | 230V: 10A fuses (T10A 250V) |
| 1 | Mean Well LRS-35-5 | LRS-35-5 | 230V input, 5V/7A output |
| 1 | BME280 Env. Sensor | BME280 | Temperature/humidity/pressure |
| 1 | SSR 25A 230V AC | D2425-10 | Panel/chassis mount, zero-crossing |
| 1 | Illuminated E-Stop Button | ZB5AS844 | Integrated emergency stop with LED indicator |

**European Design Notes:**

- **CE Marking**: All components must be CE marked for EU compliance
- **RoHS Compliance**: Lead-free construction required
- **EMC Directive**: EMI filter mandatory (EN 55011 Class B)
- **Low Voltage Directive**: EN 60204-1 machine safety standard
- **Wire Colors**: Brown=Line, Blue=Neutral, Green/Yellow=Earth (IEC 60446)

## **Primary Electronics Components**

### **Core Processing & Control**

| Qty | Component | Part Number | Description |
|-----|-----------|-------------|-------------|
| 1 | ESP32 DevKit | ESP32-DevKitC-32E | Main microcontroller |
| 1 | VL53L0X ToF Sensor | VL53L0X | 2m range sensor |
| 1 | OLED Display 128x64 | SSD1306 | Status display |
| 1 | BME280 Env. Sensor | BME280 | Temperature/humidity/pressure sensor |
| 1 | Zero-Crossing SSR 25A | D2425-10 | AC switching with EMI reduction |
| 1 | ESP32 Heat Sink Kit | 507-10ABPB | Thermal management (10x10mm, adhesive mount) |
| 1 | Thermal Interface Pad | SP400-0.010-00-1010 | ESP32 heat dissipation |

### **Current Monitoring & Protection**

| Qty | Component | Part Number | Description |
|-----|-----------|-------------|-------------|
| 1 | Current Transformer | SCT-013-020 | 20A AC current monitoring for overload protection |
| 1 | Burden Resistor | 33Ω 1W | Current sensing calibration resistor |
| 1 | TVS Diode Array | PESD5V0S1BA | GPIO surge protection |

### **Power Supply**

#### **LRS-15-5 + ESP32 Built-in 3.3V Regulator**

| Qty | Component | Part Number | Description |
|-----|-----------|-------------|-------------|
| 1 | Mean Well LRS-15-5 | LRS-15-5 | 15W 5V/3A chassis mount |

> Note: To comply with the “no SMD/through-hole” assembly requirement, only chassis or DIN rail power supplies are specified. PCB-mount AC/DC modules are not used in this design.

**Design Features:**

- Uses ESP32 built-in 3.3V regulator (600mA capacity)
- No external 3.3V regulator required
- Simplified assembly with single power supply
- Better thermal efficiency with lower power dissipation

**3.3V Load Analysis:**

```
VL53L0X ToF Sensor:    15mA typical, 30mA peak (-5mA vs VL53L1X)
SSD1306 OLED Display:  10mA typical, 20mA peak
DHT22 Env. Sensor:     1mA typical, 2.5mA active (-1.6mA vs BME280)
ESP32 Internal:        50-80mA WiFi active
Pull-up Resistors:     1.0mA (3x 10kΩ @ 3.3V, reduced from 4x)
Current Monitor LED:   2mA typical (via GPIO pin)
**TOTAL LOAD:          54-84mA typical (-43mA improvement)**
**SAFETY MARGIN:       516mA available (86% headroom, +8% improvement)**
**E-Stop/LED Eliminated**: Status integrated into OLED display (-15mA)
Screw Terminals:       Negligible (passive components)
**SIMPLIFIED DESIGN TOTAL**: 69-117mA typical
**FINAL SAFETY MARGIN**: 483mA available (80% headroom)
```

### **Control Interface Components**

| Qty | Component | Part Number | Description |
|-----|-----------|-------------|-------------|
| 1 | Panel Mount Tactile Switch | PV5S640NN | Panel mount reset button |
| 1 | Wago Lever Connectors | 221-412 | 4-port lever connector |

### **Safety Enhancement Components**

| Qty | Component | Part Number | Safety Function |
|-----|-----------|-------------|-----------------|
| 1 | Current Transformer | SCT-013-020 | AC current monitoring for overload/fault detection |
| 1 | Burden Resistor | 33Ω 1W Metal Film | Current sensing calibration |
| 1 | TVS Diode Array | PESD5V0S1BA | GPIO surge protection |
| 1 | GFCI Outlet Tester | Klein RT105 | Installation safety verification |

**Protection Features:**

- Primary: 15A circuit breaker (NA) / 10A MCB (EU)
- Secondary: 12A fast-blow fuse for selective coordination
- Tertiary: Current transformer monitoring with software shutdown
- Quaternary: TVS diode protection on all GPIO pins

### **Power & Safety Components**

| Qty | Component | Part Number | Description |
|-----|-----------|-------------|-------------|
| 1 | Enhanced IEC Inlet | 4304.6093 | All-in-one: IEC + EMI + MOV + fuse + switch |
| 1 | NEMA 5-15R Outlet | 5262 | 120V AC vacuum output (15A rated) |
| 2 | Fast Blow Fuse 12A | 0218012.MXP | Enhanced selective coordination (12A, 250V) |
| 1 | Ferrite Core Set | Fair-Rite 0443164251 | EMI suppression for I2C cables |
| 1 | RC Snubber Network | 0.1µF + 47Ω | SSR switching transient suppression |

### **Terminal & Connection Components**

| Qty | Component | Part Number | Description |
|-----|-----------|-------------|-------------|
| 1 | Phoenix Contact DIN Terminal Set | PTFIX-L-BOXX | Integrated DIN terminal system with jumpers |
| 2 | DIN Rail Terminal Block 2-pos | NSYTRV42 | DIN rail power connections |
| 4 | DIN Rail Terminal Block 4-pos | NSYTRV44 | DIN rail sensor connections |

### **Wiring & Hardware**

| Qty | Component | Description |
|-----|-----------|-------------|
| 20ft | 12 AWG Stranded Wire | AC wiring (15A rated, NEC compliant) |
| 10ft | 22 AWG Solid Wire | Low voltage wiring |
| 4 | M3x8mm Screws | ESP32 mounting |
| 4 | M3x16mm Screws | Enclosure lid |
| 8 | M3 Threaded Inserts | For 3D printed parts |
| 4 | M3 Standoffs 6mm | Board standoffs |
| 1 | Heat Shrink Tubing | Various sizes |

## Power Specifications Summary

**Note:** For comprehensive electrical safety details, protection requirements, and wiring standards, please refer to the [SAFETY_REFERENCE.md](SAFETY_REFERENCE.md) document.

### **North America (120V AC):**

- **Voltage**: 120V AC ±10%
- **Frequency**: 60Hz
- **Current**: 15A maximum (circuit breaker protected)
- **Wire Size**: 12 AWG for AC circuits

### **Europe (230V AC):**

- **Voltage**: 230V AC ±10%
- **Frequency**: 50Hz
- **Current**: 10A maximum
- **Wire Size**: 1.5mm² for AC circuits

### **Protection Features:**

- Primary: 15A circuit breaker (NA) / 10A MCB (EU)
- Secondary: Fast-blow fuse backup protection
- Isolation: >4000V between control and power circuits
- Emergency Stop: E-stop button with direct relay disconnect

## Detailed Circuit Connections

## **Circuit Connections Summary**

For detailed wiring diagrams and connection standards, refer to the [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md) document.

### **AC Power Distribution (Simplified)**

```
IEC Inlet → EMI Filter → Fuse → Power Supply + SSR Input
SSR Output → Vacuum Outlet
```

```
Enhanced Integrated IEC Inlet (120V AC):
├─ Line (Hot - Black) → Internal EMI Filter → Internal Fuse (12A) → Internal MOV → Mean Well PSU AC Input (L)
│                                                                                └─ SSR Common Terminal
├─ Neutral (White) → Internal EMI Filter → Mean Well PSU AC Input (N) → NEMA 5-15R Outlet Neutral
└─ Ground (Green) → NEMA 5-15R Outlet Ground → Enclosure Ground → Earth Stake

SSR Output (120V AC, 25A rated):
└─ NO Terminal → NEMA 5-15R Outlet Line (Hot - Black)

NEC Compliance Notes:
- Wire sizing per NEC Table 310.15(B)(16): 12 AWG for 15A circuits
- Equipment grounding per NEC 250.114: 12 AWG minimum
- Emergency disconnect per NEC 422.31(B): Within sight of appliance (integrated switch + E-stop)
- Overcurrent protection per NEC 422.11(A): Selective coordination with 12A fuse and 15A breaker
- EMI compliance per FCC Part 15: Integrated filter eliminates conducted emissions
- Surge protection: Integrated MOV provides transient voltage protection
```

### **🇪🇺 AC Power Distribution (230V AC - IEC Compliant)**

```
Enhanced Integrated IEC Inlet (230V AC):
├─ Line (Brown) → Internal EMI Filter → Internal Fuse (10A) → Internal MOV → Mean Well PSU AC Input (L)
│                                                                          └─ SSR Common Terminal
├─ Neutral (Blue) → Internal EMI Filter → Mean Well PSU AC Input (N) → CEE 7/3 Outlet Neutral
└─ Earth (Green/Yellow) → CEE 7/3 Outlet Earth → Enclosure → Protective Earth

SSR Output (230V AC, 25A rated):
└─ NO Terminal → CEE 7/3 Outlet Line (Brown)

IEC Compliance Notes:
- Wire sizing per IEC 60364-5-52: 1.5mm² for 10A circuits
- Protective earthing per IEC 60364-5-54: 1.5mm² minimum
- Emergency stop per IEC 60204-1: Category 0 disconnect (E-stop button)
- RCD protection per IEC 60364-4-41: 30mA if wet locations
- EMC compliance per EN 55011: Integrated filter eliminates conducted emissions
- Overvoltage protection: Integrated MOV provides Class III surge protection
```

### **Optimized Single Power Supply Design** ⭐

#### **LRS-35-5 + ESP32 Built-in 3.3V Regulator (Recommended)**

```
Mean Well LRS-35-5 Chassis Mount PSU:
├─ AC Input: 120V AC (from breaker & fuse)
├─ +5V/7A Output → ESP32 VIN
│                └─ ESP32 Built-in 3.3V Regulator (600mA capacity)
│                   ├─ VL53L1X VCC (20mA typical)
│                   ├─ OLED VCC (10mA typical)
│                   ├─ Pull-up Resistors (1.3mA)
│                   └─ 458mA Available (76% safety margin)
└─ GND → Common Ground Bus

Benefits:
- Simplified design: Single PSU eliminates external regulators
- Cost savings: -$27 compared to dual-rail solutions
- Proven reliability: ESP32 regulator handles all 3.3V loads
- Adequate capacity: 600mA >> 82-142mA actual load
- Better thermal: No external regulator heat generation
```

## Circuit Connections Summary

For detailed wiring diagrams and connection standards, refer to the [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md) document.

### **GPIO Connections**

```
GPIO21 → I2C SDA → VL53L0X SDA + OLED SDA + BME280 SDA (shared I2C bus)
GPIO22 → I2C SCL → VL53L0X SCL + OLED SCL + BME280 SCL (shared I2C bus)
GPIO5  → SSR Control Input (3.3V logic, SAFETY CRITICAL)
GPIO34 → Reset Button (Active Low, 10kΩ pull-up to 3.3V)
GPIO36 → Current Sensor Input for vacuum load monitoring (ADC)
```

**Status Display Integration:**
All status information consolidated into OLED display with visual highlighting:

- System Armed/Disarmed state
- Rodent detection alerts
- Vacuum operation status
- WiFi connectivity
- Capture count statistics

### **I2C Device Addresses**

```
VL53L0X ToF Sensor: 0x29 (default)
SSD1306 OLED: 0x3C (default)
BME280 Environmental: 0x76 (default)
```

## 3D Design Recommendations

### **High Voltage Section (Isolated)**

- Keep all AC components in dedicated area
- Minimum 5mm clearance from low voltage
- Use proper creepage distances per IPC standards
- Ground plane under AC section for EMI shielding

### **Low Voltage Section (Component Organization)**

- ESP32 DevKit mounted centrally for easy USB access
- VL53L1X and BME280 sensors positioned at front-facing area
- Organize components in logical functional groups:
  - Power section: Power supply, illuminated E-stop
  - Control section: ESP32, buttons, E-stop
  - Sensor section: VL53L1X, BME280, OLED display
- Use cable channels or wire guides between sections
- Label all connections with permanent markers or labels
- Maintain minimum 5mm separation between AC and DC components

### **Enhanced Thermal Management** 🔥

- **ESP32 Standard Cooling Package:**
  - 10x10mm heat sink with thermal adhesive (now standard equipment)
  - Ventilation channels in enclosure directly above ESP32
  - Temperature monitoring with progressive throttling before shutdown
  - ESP32 placement optimized for natural convection cooling
- **Power Supply Thermal Design:**
  - AC-DC converter with designated ventilation zone
  - Minimum 25mm clearance around heat-generating components
  - Heat flow modeling to prevent hot spots

- **SSR Thermal Considerations:**
  - Thermal compound application between SSR and mounting surface
  - Metal mounting plate acts as additional heat sink
  - Airflow path design to cool SSR during long duty cycles
  - Temperature monitoring near SSR for overload detection

## Safety & Compliance Notes

### **Electrical Safety (NEC/UL Standards)**

- **UL/CE Compliance**: Use only UL-listed/CE-marked AC components per NEC 110.3(B)
- **Isolation**: Minimum 4000V isolation between AC and DC sections per UL 508A
- **Grounding**: Continuous ground from IEC inlet to outlet and enclosure per NEC 250.114
- **Protection**: Dual protection with circuit breaker and fuse per NEC 240.4
- **Wiring**: 12AWG minimum for 15A circuits, 22AWG for Class 2 circuits per NEC 725.121
- **Disconnect**: Emergency disconnect within sight per NEC 422.31(B)
- **Overcurrent**: Circuit protection at 125% of motor FLA per NEC 430.32(A)

### **🇪🇺 Electrical Safety (IEC/CE Standards)**

- **CE Marking**: All components CE marked per EU Machinery Directive 2006/42/EC
- **Isolation**: Minimum 4000V galvanic isolation per IEC 61010-1
- **Earthing**: Protective earth continuity per IEC 60364-6-61
- **Protection**: MCB + fuse coordination per IEC 60364-4-43
- **Wiring**: 1.5mm² minimum for mains, 0.5mm² for SELV per IEC 60364-5-52
- **EMC**: EN 55011 Class B emissions, EN 61000-6-1 immunity
- **Safety**: EN 60204-1 electrical equipment of machines standard

### **Installation Requirements (North America)**

- **GFCI Protection**: Install on GFCI-protected circuit per NEC 210.8 (wet locations)
- **Enclosure Rating**: NEMA 4X minimum for outdoor installations
- **Temperature**: Operating range -10°C to +50°C per UL 508A
- **Altitude**: <2000m for proper insulation ratings per UL 508A
- **Permits**: Electrical permit may be required - consult local AHJ (Authority Having Jurisdiction)

### **🇪🇺 Installation Requirements (Europe)**

- **RCD Protection**: 30mA RCD required per IEC 60364-4-41 (wet locations)
- **Enclosure Rating**: IP54 minimum per IEC 60529 for outdoor installations
- **Temperature**: Operating range -10°C to +50°C per EN 60204-1
- **Altitude**: <1000m standard, >1000m requires derating per IEC 60664-1
- **Declaration**: EU Declaration of Conformity required for CE marking

### **Testing & Validation (NEC/UL Requirements)**

1. **Pre-Energization Test**: Verify all voltages before connecting devices per UL 508A
2. **Isolation Test**: Confirm >4MΩ between AC and DC sections per UL 508A 8.5.4
3. **Ground Continuity**: Verify <0.1Ω ground path integrity per NEC 250.6
4. **Function Test**: Test all switches and sensor operation per manufacturer specs
5. **Load Test**: Verify relay switching with actual vacuum load per UL 508A 51.1
6. **GFCI Test**: Verify GFCI trips at 4-6mA per UL 943
7. **Arc Flash**: Label per NFPA 70E if >50V exposed

### **🇪🇺 Testing & Validation (IEC/CE Requirements)**

1. **PAT Testing**: Portable appliance testing per IEC 61010-1
2. **Insulation Test**: 500V DC insulation resistance >1MΩ per IEC 60364-6-61
3. **Earth Continuity**: <0.1Ω resistance per IEC 60364-6-61
4. **Function Test**: Operational testing per EN 60204-1
5. **EMC Testing**: Emissions and immunity per EN 55011 and EN 61000-6-1
6. **RCD Test**: Trip test at 30mA per IEC 61008
7. **Declaration**: Technical file and DoC per EU Machinery Directive

## Assembly Notes

### **Wiring Best Practices (NEC Compliant)**

- **Color Coding**: Black=Hot, White=Neutral, Green=Ground per NEC 200.6 and 250.119
- **Strain Relief**: UL-listed strain relief on all external cables per NEC 400.10
- **AC Connections**: Wire nuts (UL 486C) or terminal blocks for all AC connections
- **DC Connections**: Heat shrink tubing and solder for low-voltage connections
- **Cable Management**: Organized routing with cable ties, separated AC/DC per NEC 300.3(C)
- **Torque Specs**: Terminal torque per manufacturer specifications
- **Inspection**: Visual and electrical inspection per NEC 110.7

### **🇪🇺 Wiring Best Practices (IEC Compliant)**

- **Color Coding**: Brown=Line, Blue=Neutral, Green/Yellow=Earth per IEC 60446
- **Strain Relief**: CE-marked cable glands per IEC 60529
- **AC Connections**: Terminal blocks with finger-safe barriers per IEC 60947-7-1
- **DC Connections**: Insulated crimp terminals per IEC 60947-7-4
- **Cable Management**: Trunking systems with segregation per IEC 60364-5-52
- **Testing**: Installation testing per IEC 60364-6 before energization

### **Component Mounting**

- ESP32 on standoffs for cooling airflow
- Power supply with vibration dampening
- SSR with thermal interface if high current
- Sensors with shock absorption mounting

### **Enhanced Safety Features** 🛑

#### **Improved Emergency Stop Labeling**

- Use high-visibility red E-STOP label around emergency button
- Add clear instructional text: "PRESS FOR EMERGENCY SHUTDOWN"
- Use universal emergency stop symbol per ISO 13850
- Include multi-language safety instructions where appropriate
- Ensure visibility in low-light conditions with reflective materials

#### **Comprehensive Cable Strain Relief System**

- Use UL-Listed cable glands for all external connections
- Implement service loops for internal cables to prevent tension
- Add cable tie anchor points at strategic locations
- Size all strain relief appropriate to cable diameter
- Follow NEC 400.10 requirements for all AC connections

#### **Integrated Power Indication** ⭐

- Illumination built into the E-stop provides power/status indication
- Reduces components and wiring while improving visibility

### **Quality Control Checklist**

- [ ] All AC connections tight and properly insulated
- [ ] DC voltages correct and stable
- [ ] I2C devices respond correctly
- [ ] All switches and LEDs functional
- [ ] Proper grounding throughout
- [ ] No exposed conductors
- [ ] Strain relief properly installed on ALL connections
- [ ] Enclosure properly sealed
- [ ] E-STOP clearly labeled with high-visibility markings

- [ ] All terminal screws torqued to specification
- [ ] Heat sink properly attached to ESP32

## **NEC/IEC Compliance Summary & Code References** 📋

### **North American Compliance (NEC/UL/CSA)**

| Code Section | Requirement | Design Implementation |
|--------------|-------------|----------------------|
| NEC 422.11(A) | Appliance disconnect within sight | Emergency switch on front panel |
| NEC 422.31(B) | Switch rated for appliance load | 25A SSR > 15A vacuum load |
| NEC 240.4(B) | Overcurrent protection coordination | 15A breaker + 15A fuse backup |
| NEC 250.114 | Equipment grounding | 12 AWG ground throughout |
| NEC 430.109(A) | Motor disconnect within sight | Emergency stop accessible |
| UL 508A | Industrial control panel standard | >4000V isolation, proper barriers |
| FCC Part 15 | EMI emissions | Zero-crossing SSR, EMI filtering |

### **🇪🇺 European Compliance (IEC/EN/CE)**

| Standard | Requirement | Design Implementation |
|----------|-------------|----------------------|
| IEC 60204-1 | Safety of machinery - Electrical | Category 0 emergency stop |
| EN 55011 Class B | EMC emissions | EMI filter mandatory |
| EN 61000-6-1 | EMC immunity | Shielded cables, filtering |
| IEC 60364-4-41 | Shock protection | RCD + protective earthing |
| IEC 60947-4-1 | Contactors and motor-starters | SSR ratings exceed requirements |
| EU 2006/42/EC | Machinery Directive | CE marking required |
| EU 2014/35/EU | Low Voltage Directive | Harmonized standards compliance |

### **International Builder Notes** 🌍

**🇺🇸 United States:**

- Use NEMA outlets and plugs
- Install on 15A circuit with GFCI if wet location
- Electrical permit may be required - check local codes
- Follow NEC Chapter 4 for equipment installation

**🇨🇦 Canada (CSA):**

- Similar to US but follow CEC (Canadian Electrical Code)
- CSA certification preferred over UL where available
- Provincial electrical inspection required

**🇪🇺 European Union:**

- CE marking mandatory for commercial use
- Use CEE 7/7 (Schuko) or country-specific outlets
- RCD protection typically required
- Declaration of Conformity required

**🇬🇧 United Kingdom:**

- Use BS 1363 outlets (13A fused plugs)
- Part P compliance for fixed installations
- 17th Edition Wiring Regulations (BS 7671)

**🇦🇺 Australia (AS/NZS):**

- Use AS/NZS 3112 outlets
- Install on RCD-protected circuit
- Electrical compliance certificate required

This enhanced design provides a professional-grade rat trap control system with comprehensive safety features, optimized component selection, and full compliance with international electrical codes and standards.

## **Environmental Monitoring & Analytics**

The BME280 environmental sensor provides accurate environmental monitoring, enabling correlation between environmental conditions and rodent activity.

### **BME280 Sensor Specifications**

- **Temperature Range**: -40°C to +85°C (±1.0°C accuracy)
- **Humidity Range**: 0-100% RH (±3% accuracy)
- **Pressure Range**: 300-1100 hPa (±1 hPa accuracy)
- **Power Consumption**: 1μA sleep mode, 3.6mA active mode
- **I2C Address**: 0x76 (default)

### **Environmental Analytics Benefits**

- **Behavior Pattern Recognition**: Correlate environmental conditions with rodent activity
- **Predictive Triggering**: Adjust sensitivity based on environmental factors
- **Home Assistant Integration**: Data visualization and trend analysis
- **Maintenance Notifications**: Monitor system for condensation risk or extreme temperatures
- **Operational Efficiency**: Optimize capture settings based on environmental data

### **Integration With Home Assistant**

```yaml
# Example Home Assistant automation
automation:
  - alias: "Alert When Conditions Favor Rodent Activity"
    trigger:
      - platform: state
        entity_id: sensor.environmental_humidity
        above: 70
    condition:
      - condition: time
        after: '22:00:00'
        before: '06:00:00'
    action:
      - service: automation.turn_on
        entity_id: automation.increase_trap_sensitivity
```
