# ShopVac Rat Trap 2025 - Consolidated Safety Reference

This document serves as the central safety reference for the ShopVac Rat Trap project. It consolidates critical safety information previously spread across multiple documents to ensure consistency and completeness.

## ⚠️ ELECTRICAL HAZARD WARNING ⚠️

This project involves 120V/230V AC electrical connections. Installation **MUST** be performed by qualified individuals with electrical experience. Improper installation can result in:
- Electrical shock or electrocution (potentially fatal)
- Fire hazard from overloaded circuits or motor overload
- Equipment damage from improper connections or overcurrent conditions
- Personal injury from mechanical failures or vacuum motor damage

## 🚨 MANDATORY SAFETY ENHANCEMENTS (August 2025)

### **CRITICAL: Current Monitoring Required**
All installations **MUST** include AC current monitoring for safety:
- **Component**: SCT-013-020 current transformer (20A rating)
- **Purpose**: Detect vacuum motor overload, clogged hoses, bearing failures
- **Action**: Automatic shutdown when current exceeds 12A (141% of normal)
- **Installation**: CT clamp around hot wire to vacuum outlet
- **Compliance**: Required for motor protection per NEC 430.32

## 1. Safety Standards Compliance

### North America (NEC/UL Standards)
- **Circuit Protection:** 15A breaker and **12A fuse** (enhanced selective coordination)
- **Wire Gauge:** 12 AWG minimum for all AC circuits (NEC Table 310.15(B)(16))
- **Current Monitoring:** SCT-013-020 CT mandatory for motor protection (NEC 430.32)
- **GFCI Protection:** Required for wet locations (NEC 210.8)
- **Ground Integrity:** Continuous ground path verification mandatory (NEC 250.114)
- **Disconnect Means:** Readily accessible per NEC 422.31(B)
- **Isolation:** >4000V between AC and DC sections per UL 508A
- **Surge Protection:** TVS diodes on GPIO pins recommended

### Europe (IEC/CE Standards)
- **Circuit Protection:** 10A MCB and **10A fuse** coordination per IEC 60364-4-43
- **Wire Gauge:** 1.5mm² minimum for all 230V connections (IEC 60364-5-52)
- **Current Monitoring:** SCT-013-020 CT mandatory for motor protection (IEC 60204-1)
- **RCD Protection:** 30mA RCD required for wet locations per IEC 60364-4-41
- **Protective Earth:** Continuous PE conductor per IEC 60364-6-61
- **Emergency Stop:** Category 0 disconnect per IEC 60204-1
- **CE Marking:** All components must be CE marked for EU compliance
- **EMC Compliance:** EN 55011 Class B emissions, ferrite cores required

## 2. Required Safety Equipment

### For Installation
- Safety glasses with side shields
- Insulated electrical gloves (rated for 600V minimum)
- Non-contact voltage tester
- Multimeter with CAT III 600V rating
- **AC current clamp meter** (for CT calibration)
- **GFCI outlet tester** (Klein RT105 or equivalent)
- First aid kit with electrical burn treatment

### For Regular Use
- Fire extinguisher suitable for electrical fires (Class C)
- Emergency contact information clearly posted
- Operational checklist for regular safety verification
- **Monthly current monitoring verification**

## 3. Lockout/Tagout Procedure

**MANDATORY: Follow this procedure before ANY maintenance work**

1. **Disconnect Power**
   - Unplug power cord from wall outlet
   - Verify E-stop illumination is OFF

2. **Verify Zero Energy State**
   - Use multimeter to confirm no voltage at AC terminals
   - Wait minimum 2 minutes for capacitors to discharge

3. **Lockout**
   - Apply lockout device to power plug if available
   - If no lockout device, remove plug from work area

4. **Tagout**
   - Apply tag stating "MAINTENANCE IN PROGRESS"
   - Include date, time and your name

5. **Test Verification**
   - Attempt to power on unit (should not activate)
   - Recheck voltage at critical points

## 4. Testing & Validation Procedures

### ⚠️ **MANDATORY Current Monitoring Calibration**
**CRITICAL SAFETY PROCEDURE - Required for all installations**

1. **CT Installation Verification**
   - Verify SCT-013-020 current transformer is clamped around HOT wire only
   - Confirm CT orientation matches current flow direction
   - Verify burden resistor (33Ω 1W) is properly connected
   - Check ESP32 GPIO35 ADC connection integrity

2. **Current Calibration Procedure**
   ```yaml
   # Use this procedure to calibrate current sensing
   # 1. Connect known load (8.5A shop vacuum)
   # 2. Measure actual current with calibrated clamp meter
   # 3. Record ADC reading in ESPHome logs
   # 4. Adjust calibration factors in YAML config
   # 5. Verify ±5% accuracy across 2A to 12A range
   ```

3. **Safety Threshold Testing**
   - Verify 10A warning triggers correctly (use resistive load)
   - Verify 12A shutdown activates within 2 seconds
   - Confirm vacuum disconnects immediately on overload
   - Test logging and fault reporting functionality

### Enhanced Electrical Safety Testing (MANDATORY)
1. **Isolation Test**: Confirm >4MΩ between AC and DC sections (UL 508A 8.5.4)
2. **Ground Continuity**: Verify <0.1Ω ground path integrity (NEC 250.6)
3. **Current Monitoring**: Calibrate and test CT clamp accuracy (±5% required)
4. **Polarity Check**: Verify correct L/N connections
5. **GFCI/RCD Test**: Confirm proper operation of protection devices
6. **Load Test**: Verify SSR operates with actual vacuum load
7. **Overload Test**: Confirm automatic shutdown at 12A threshold

### Emergency Systems Testing
1. **E-Stop Function**: Verify immediate cessation of all operations
2. **Thermal Protection**: Confirm shutdown if ESP32 temperature exceeds 85°C
3. **Power Loss Recovery**: Verify safe state is maintained after power cycle

## 5. Emergency Procedures

### Thermal Emergency
If thermal shutdown is triggered:
1. **IMMEDIATE**: Disconnect power to the system
2. **ASSESS**: Check for obstructions to ventilation
3. **WAIT**: Allow minimum 30 minutes cooling time
4. **INSPECT**: Look for signs of component damage
5. **DOCUMENT**: Record the incident with temperature data if available

### Emergency Stop Activation
If emergency stop is activated:
1. **IDENTIFY**: Determine reason for emergency stop activation
2. **SECURE**: Ensure area is safe before resetting
3. **INSPECT**: Check for physical damage or loose components
4. **RESET**: Only after confirming safe conditions
5. **TEST**: Verify all functions operate correctly

## 6. Wiring Best Practices

### North America (NEC Standards)
- **Color Coding**: Black=Hot, White=Neutral, Green=Ground (NEC 200.6, 250.119)
- **AC Connections**: Wire nuts (UL 486C) or terminal blocks for all AC connections
- **Strain Relief**: UL-listed strain relief on all external cables (NEC 400.10)
- **Separation**: Maintain separation between AC and DC circuits (NEC 300.3(C))

### Europe (IEC Standards)
- **Color Coding**: Brown=Line, Blue=Neutral, Green/Yellow=Earth (IEC 60446)
- **Strain Relief**: CE-marked cable glands per IEC 60529
- **AC Connections**: Terminal blocks with finger-safe barriers (IEC 60947-7-1)
- **Separation**: Separate routing for SELV and mains circuits (IEC 60364-5-52)

## 7. Component Safety Requirements

### Power Supply
- **UL/CE Listing**: Mandatory for all AC-DC converters
- **Isolation**: ≥4000V isolation recommended (e.g., LRS-35-5)
- **Enclosure**: Must be fully enclosed to prevent direct contact
- **Mounting**: Secure mounting with proper clearances for ventilation

### SSR (Solid State Relay)
- **Rating**: Minimum 25A for vacuum loads (NEC 430.109)
- **Heat Management**: Consider thermal pad if switching >10A regularly
- **Mounting**: Secure mounting to prevent movement
- **Isolation**: >4000V isolation between control and load sides

### Circuit Protection
- **Coordination**: Proper coordination between breaker and fuse
- **Accessibility**: Fuses must be accessible for replacement
- **Sizing**: Properly sized for the application (15A for US, 10A for EU)
- **Type**: Fast-blow fuses for equipment protection

## 8. International Compliance Information

### United States
- Follow NEC (National Electrical Code) requirements
- UL listed components mandatory
- Local electrical permits may be required

### European Union
- CE marking required for all components
- Compliance with Low Voltage Directive 2014/35/EU
- Compliance with EMC Directive 2014/30/EU
- Installation by qualified electrician may be required

### Australia/New Zealand
- Compliance with AS/NZS 3000 wiring rules
- RCD protection required
- Only licensed electricians can perform certain work

### Canada
- CSA certified components preferred
- Follow Canadian Electrical Code requirements
- Provincial regulations may apply

## 9. Safety Checklist Before Operation

- [ ] All AC connections tight and properly insulated
- [ ] DC voltages correct and stable
- [ ] I2C devices respond correctly
- [ ] All switches and controls functional
- [ ] Proper grounding throughout
- [ ] No exposed conductors
- [ ] Strain relief properly installed
- [ ] Enclosure properly sealed
- [ ] E-STOP clearly labeled with high-visibility markings
- [ ] E-stop illumination functional
- [ ] Heat sink properly installed on ESP32
- [ ] Circuit protection devices verified

## Emergency Contact Information

**For electrical emergencies:**
- Disconnect power immediately
- Call emergency services if injury occurs: [LOCAL EMERGENCY NUMBER]
- Contact project maintainers for technical support: [PROJECT CONTACT]

*If you are not qualified to perform electrical work, STOP and hire a licensed electrician.*

---

This consolidated safety document supersedes individual safety sections in other documents. Always refer to this document for the most up-to-date safety information.
