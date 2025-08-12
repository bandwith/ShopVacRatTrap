# 3D Models - ShopVac Rat Trap 2025

## Current Files (Ready to Print)

### **`Complete_Trap_Tube_Assembly.scad`** - PRIMARY DESIGN
- Unified 3D printed trap tube with integrated inlet mount
- Replaces all PVC pipe components
- Includes bait compartment and vacuum connection
- Print time: 18-24 hours

### **`Inlet_Sensor_Assembly.scad`** - HYBRID DETECTION SENSORS (NEW)
- Houses all detection sensors at trap inlet location
- STEMMA QT ecosystem: APDS9960, VL53L0X, PIR, BME280
- Weatherproof IP65 enclosure for outdoor deployment
- Single 500mm cable to control box
- Print time: 4-6 hours

### **`Side_Mount_Control_Box.scad`** - ELECTRONICS HOUSING
- Houses ESP32-S3, power supply, and user controls
- Simplified: Only OLED display, buttons, and AC components
- Mounts to side of main trap tube
- Print time: 4-5 hours

### **`Refillable_Bait_Cap.scad`** - BAIT SYSTEM
- Snap-fit cap for bait compartment
- O-ring sealed for airtight storage
- Print time: 2-3 hours

### **`Complete_System_Assembly.scad`** - REFERENCE ONLY
- Shows complete system integration including inlet sensors
- Use for visualization and alignment
- Print time: 1 hour

## Architecture Changes - August 2025 Update

**MAJOR SIMPLIFICATION**: Detection sensors moved from control box to inlet assembly:

- ✅ **Centralized Detection**: All sensors at optimal sensing location (inlet)
- ✅ **Simplified Wiring**: Single 500mm STEMMA QT cable control box ↔ inlet
- ✅ **Modular Design**: Inlet sensor assembly can be upgraded independently
- ✅ **Enhanced Weather Protection**: Dedicated weatherproof housing for sensors
- ✅ **Easier Maintenance**: Snap-fit sensor mounts for easy replacement

## Print Settings

**Material**: PETG Carbon Fiber (outdoor use) or ASA
**Layer Height**: 0.20mm
**Infill**: 25-30% (structural), 30% (inlet sensors for weather resistance)
**Support**: Minimal (optimized geometry)

## Assembly Order

1. Print `Complete_Trap_Tube_Assembly.scad` first
2. Print `Inlet_Sensor_Assembly.scad` (NEW - critical for detection)
3. Print `Side_Mount_Control_Box.scad`
4. Print `Refillable_Bait_Cap.scad`
5. Assemble inlet sensors per `INSTALLATION_GUIDE.md`
6. Install electronics and connect single STEMMA QT cable

Total print time: ~30-38 hours for complete system (including new inlet assembly)

## Sensor Mounting Guide

### Standard Configuration (4 Sensors at Inlet):
- **APDS9960** - Primary proximity/gesture detection
- **VL53L0X** - Secondary ToF distance confirmation
- **PIR Motion** - Tertiary backup detection
- **BME280** - Environmental monitoring

### Camera Configuration (+2 Additional):
- **OV5640 5MP Camera** - Evidence capture
- **High-Power IR LED** - Night vision illumination

**Connection**: All sensors → STEMMA QT 5-Port Hub → 500mm cable → ESP32-S3
