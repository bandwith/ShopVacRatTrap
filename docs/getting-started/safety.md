# Safety Guidelines

!!! danger "CRITICAL: Read This First"
    This project involves potentially lethal 120V/230V AC electrical connections. **You must read and understand all safety information before beginning any work.**

## Electrical Hazard Warning

### Risks

Improper installation or use of this project can result in:

- **Electrical shock or electrocution** (potentially fatal)
- **Fire hazard** from overloaded circuits or improper wiring
- **Equipment damage** from incorrect connections
- **Personal injury** from mechanical or electrical failures

### Who Should Build This

This project is appropriate for individuals with:

✅ **Required Qualifications:**
- Understanding of AC electrical safety fundamentals
- Experience with electrical wiring and safety procedures
- Knowledge of local electrical codes (NEC, IEC, etc.)
- Access to proper safety equipment and tools
- Ability to read and understand electrical diagrams

❌ **NOT Appropriate If:**
- You've never worked with AC voltage before
- You're uncomfortable using electrical testing equipment
- You don't understand electrical safety procedures
- You don't have access to proper safety equipment

!!! warning "When in Doubt, Hire a Professional"
    If you have ANY doubts about your ability to safely complete the electrical work, **hire a licensed electrician**. Your safety is not worth the cost savings.

## Mandatory Safety Equipment

### Personal Protective Equipment (PPE)

- [ ] **Safety glasses with side shields** - Eye protection from arcs/debris
- [ ] **Insulated electrical gloves** - Rated for 600V minimum
- [ ] **Non-contact voltage tester** - Verify power is OFF
- [ ] **Insulated tools** - Screwdrivers, pliers rated for electrical work
- [ ] **Work boots** - Non-conductive soles
- [ ] **Fire extinguisher** - Class C (electrical fires)

### Testing Equipment

- [ ] **Multimeter** - CAT III 600V rated minimum
- [ ] **AC current clamp meter** - For current monitoring validation
- [ ] **GFCI outlet tester** - Klein RT105 or equivalent
- [ ] **Continuity tester** - For ground verification

## Safety Procedures

### Before Starting Work

1. **Power OFF** - Turn off circuit breaker
2. **Test Circuit** - Use voltage tester to confirm power is OFF
3. **Lock Out/Tag Out** - If possible, lock breaker in OFF position
4. **Discharge Capacitors** - Wait 5 minutes after power off
5. **Verify Again** - Double-check with voltage tester

### During Work

1. **One Hand Rule** - Keep one hand in pocket when testing live circuits
2. **Dry Conditions** - Never work on electrical systems in wet conditions
3. **Proper Lighting** - Ensure adequate lighting for all work
4. **No Shortcuts** - Follow procedures exactly, every time
5. **Stay Alert** - Never work when tired or distracted

### After Completion

1. **Visual Inspection** - Check all connections before power on
2. **Continuity Test** - Verify ground path
3. **Isolation Test** - Confirm AC/DC separation (\u003e1MΩ)
4. **Gradual Power-Up** - Test at each stage
5. **Monitor First Run** - Watch for smoke, sparks, unusual sounds

## Required Safety Features

### Electrical Protection

- ✅ **Circuit Breaker**: 15A (120V) or 10A (230V)
- ✅ **Fuse Protection**: Properly sized for load
- ✅ **Ground Fault Protection**: GFCI/RCD for wet locations
- ✅ **Emergency Stop**: Accessible, illuminated switch
- ✅ **Current Monitoring**: SCT-013-020 for motor protection
- ✅ **Optocoupler Isolation**: 4N35 between ESP32 and SSR
- ✅ **Proper Grounding**: Continuous earth/ground connection

### Thermal Protection

- ✅ **ESP32 Temperature Monitoring**: Auto-shutdown at 85°C
- ✅ **Warning Alerts**: Progressive warnings at 75°C
- ✅ **Ventilation**: Adequate airflow in enclosure
- ✅ **Component Spacing**: Proper clearances

## Wire and Component Ratings

### Wire Gauge Requirements

| Circuit | North America | Europe | Max Current |
|---------|---------------|--------|-------------|
| AC Power | 12 AWG | 2.5 mm² | 20A |
| AC Load | 12 AWG | 2.5 mm² | 15A |
| DC Low Voltage | 22-26 AWG | 0.3 mm² | 3A |

### Component Ratings

All safety-critical components **MUST** be rated for:

- **Voltage**: 250VAC minimum
- **Current**: 150% of maximum load
- **Isolation**: \u003e4000V (SSR), \u003e5000V (Optocoupler)
- **Certification**: UL/CE listed for intended use

## Safety Standards Compliance

### North America (NEC/UL)

- **NEC 240.4**: Overcurrent protection
- **NEC 250.114**: Grounding requirements
- **NEC 422.31(B)**: Disconnect means
- **NEC 430.32**: Motor protection
- **UL 508A**: Industrial control panels

### Europe (IEC/CE)

- **IEC 60364-4-41**: Protection against electric shock
- **IEC 60364-4-43**: Overcurrent protection
- **IEC 60204-1**: Safety of machinery
- **IEC 61010-1**: Safety requirements for electrical equipment
- **CE Marking**: Required for EU compliance

### Other Regions

- **UK**: BS 1363, Part P compliance
- **Australia**: AS/NZS 3112, RCD protection mandatory
- **Canada**: CSA standards, CEC compliance

## Emergency Procedures

### If Electrical Shock Occurs

1. **DO NOT TOUCH** the victim if still in contact with power source
2. **Cut Power** immediately at breaker
3. **Call Emergency Services** (911/112/000)
4. **Begin CPR** if trained and victim is unconscious
5. **Use AED** if available

### If Fire Occurs

1. **Cut Power** at circuit breaker if safe to do so
2. **Evacuate Area** if fire is spreading
3. **Use Class C Extinguisher** for electrical fires
4. **Call Fire Department** (911/112/000)
5. **Never Use Water** on electrical fires

### If Equipment Failure Occurs

1. **Activate Emergency Stop** immediately
2. **Disconnect Power** at circuit breaker
3. **Document Failure** - note conditions, symptoms
4. **Inspect Safely** - only after confirmed power off
5. **Seek Professional Help** if cause unknown

## Installation Checklist

Before applying power for the first time:

- [ ] All AC wiring uses proper gauge wire (12 AWG / 2.5mm²)
- [ ] All connections are tight and properly insulated
- [ ] No exposed conductors or sharp edges
- [ ] Ground/earth connection verified with continuity tester
- [ ] Circuit breaker and fuse properly sized and installed
- [ ] SSR mounted with thermal pad, adequate cooling
- [ ] Optocoupler properly installed for ESP32 protection
- [ ] Emergency stop button functional and accessible
- [ ] All components rated for voltage and current
- [ ] Enclosure properly sealed and labeled
- [ ] GFCI/RCD protection if required by code
- [ ] Current monitoring system calibrated
- [ ] Visual inspection completed
- [ ] Isolation test passed (\u003e1MΩ between AC and DC)

## Permits and Inspections

### When Required

Check with your local authority having jurisdiction (AHJ) about:

- **Electrical Permit**: May be required for permanent installations
- **Inspection**: Professional inspection may be mandatory
- **Insurance**: Check if installation affects home insurance
- **Code Compliance**: Local amendments to NEC/IEC standards

### Documentation

Maintain records of:

- Installation date and installer
- Component specifications and certifications
- Test results (ground continuity, isolation, etc.)
- Maintenance schedule and logs
- Any modifications or repairs

## Children and Pets

- **Keep Away**: Store out of reach when not supervised
- **Supervision**: Never operate unattended in accessible areas
- **Labels**: Clearly mark high voltage hazards
- **Training**: Ensure all users understand safety procedures

## Professional Resources

### When to Call a Professional

- AC wiring and breaker installation
- Electrical permit applications
- Code compliance verification
- Safety inspections
- Troubleshooting electrical faults

### Finding Qualified Help

- **Licensed Electricians**: Check local licensing board
- **Electrical Inspectors**: Contact local building department
- **Professional Organizations**: NECA, IEC, local trade associations

---

## Acknowledgment

By proceeding with this project, you acknowledge that:

1. You have read and understood all safety warnings
2. You have the necessary skills and equipment
3. You will follow all applicable electrical codes
4. You accept all risks and responsibility
5. You will seek professional help when needed

!!! danger "Final Warning"
    **If you have ANY doubts about electrical safety, STOP and hire a licensed electrician.**

    Your life is worth more than the cost of professional installation.

---

**Next Step**: If you've read and understood this safety information, proceed to the [Project Overview](overview.md).
