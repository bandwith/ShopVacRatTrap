# 3D Printing Guidelines - ShopVac Rat Trap 2025

## Recent Design Enhancements (August 2025)

### ✅ VL53L0X Sensor Optimization Complete
The Pipe Inlet Assembly has been enhanced with optimized sensor placement and comprehensive rodent damage protection:

**Key Improvements**:
- **Sensor Repositioning**: VL53L0X moved from side-mount (40mm offset) to centerline placement for optimal pipe detection
- **Detection Angle**: 15-degree downward angle ensures comprehensive coverage of the 4" PVC pipe interior
- **Rodent Protection System**: Multi-layered defense against gnawing damage:
  - 3mm hardened outer shell (gnaw guard)
  - Armored cable protection conduit (12mm diameter)
  - Anti-gnaw surface texturing with protective ridges
  - Strain relief at all cable connection points

**Print Considerations for Enhanced Design**:
- **Support Requirements**: Sensor housing overhang now requires additional support
- **Infill Adjustment**: Increase to 25% for enhanced gnaw resistance
- **Surface Finish**: Anti-gnaw texturing is integral to the design - do not sand smooth
- **Cable Routing**: Test-fit STEMMA QT cables through protection conduit during assembly

### ✅ STEMMA QT Camera System Available
The system now supports modular camera operation with professional image capture:

**Camera-Enhanced Features**:
- **OV5640 5MP Camera**: Professional quality with autofocus triggered by VL53L0X detection
- **High-Power IR LED**: 10+ meter night vision range for complete coverage
- **Zero-Solder Assembly**: Complete STEMMA QT/JST ecosystem for easy maintenance
- **Coordinated Detection**: VL53L0X triggers immediate multi-shot camera capture
- **Home Assistant Native**: Images automatically uploaded with instant notifications

**Camera-Specific Print Requirements**:
- **Camera Mount**: Print with 30% infill for vibration resistance
- **IR LED Housing**: Heat dissipation fins require 0.2mm layer height
- **STEMMA Cable Management**: Integrated strain relief and routing channels
- **Enhanced Protection**: Weatherproof sealing with integrated drainage
- **Modular Design**: Individual components replaceable without full disassembly

---

## Material Selection (Critical for Rodent Resistance)

This document provides detailed printing recommendations for long-term outdoor field use with extensive UV exposure. **All designs use snap-fit assembly - NO FASTENERS REQUIRED.**

## 🔧 **Snap-Fit Assembly Advantages**

### **No Fasteners Required:**
- ❌ **No screws, bolts, or nuts needed**
- ❌ **No tools required for assembly**
- ✅ **Faster assembly time**
- ✅ **Lower cost (no hardware to buy)**
- ✅ **Reduced failure points**
- ✅ **Tool-free field maintenance**

## 🌞 **UV-Resistant Material Recommendations**

### **RECOMMENDED: PETG with UV Additives**
- **Material**: PETG with UV stabilizers (Prusament PETG, Overture PETG, etc.)
- **UV Rating**: 2-3 years outdoor exposure
- **Temperature Range**: -40°C to +70°C
- **Chemical Resistance**: Excellent
- **Cost**: Moderate ($25-35/kg)

### **PREMIUM: ASA (Acrylonitrile Styrene Acrylate)**
- **Material**: ASA filament (Prusament ASA, eSUN ASA+, etc.)
- **UV Rating**: 5+ years outdoor exposure
- **Temperature Range**: -40°C to +85°C
- **Chemical Resistance**: Excellent
- **Cost**: Higher ($30-45/kg)
- **Note**: Requires enclosed printer due to fumes

### **BUDGET: PLA+ with UV Protection**
- **Material**: PLA+ with UV stabilizers + UV-resistant coating
- **UV Rating**: 1-2 years with post-treatment
- **Temperature Range**: -10°C to +55°C
- **Chemical Resistance**: Good
- **Cost**: Lower ($20-25/kg)
- **Note**: Requires UV-resistant coating (Krylon UV-Resistant Clear, etc.)

## 📋 **Component-Specific Print Settings**

### **Inlet_Rodent_Detection_Assembly.scad Components**

#### **pipe_inlet()** - Primary 4" PVC Inlet with Snap-Fit Mounting
```
Material: ASA (recommended) or PETG
Layer Height: 0.2mm
Infill: 25-30%
Wall Lines: 4 (for 1.2mm wall thickness)
Top/Bottom Layers: 6-8
Print Speed: 50mm/s
Support: Yes (for overhangs >45°)
Orientation: Flange down, inlet up
Post-Processing:
  - Sand snap-fit surfaces smooth
  - Test snap-clip flexibility
  - NO FASTENERS NEEDED - snap clips engage pipe directly
```

#### **pipe_to_vacuum_adapter()** - Vacuum Connection with Snap Retention
```
Material: PETG or ASA
Layer Height: 0.15mm (for smooth hose connection)
Infill: 40%
Wall Lines: 4
Top/Bottom Layers: 8
Print Speed: 40mm/s (for precision)
Support: Minimal (tree supports only)
Orientation: Large end down
Post-Processing:
  - Sand hose connection surfaces
  - Test snap retention grooves
  - NO CLAMPS NEEDED - built-in snap retention
```

#### **control_box_mount()** - Snap-Fit Pipe Mounting Bracket
```
Material: ASA (high stress component)
Layer Height: 0.3mm (for strength)
Infill: 50%
Wall Lines: 5
Top/Bottom Layers: 6
Print Speed: 60mm/s
Support: Yes (for clamp section)
Orientation: Mounting plate flat
Post-Processing:
  - Test snap-clamp operation
  - Verify pipe fit
  - NO BOLTS NEEDED - snap clamps secure directly to pipe
```

#### **control_box_cover()** - Weatherproof Cover
```
Material: ASA or PETG
Layer Height: 0.2mm
Infill: 20%
Wall Lines: 4
Top/Bottom Layers: 8 (for weatherproofing)
Print Speed: 50mm/s
Support: Yes (minimal)
Orientation: Open side up
Post-Processing: Seal all layer lines with UV-resistant coating
```

### **Side_Mount_Control_Box.scad Components**

#### **control_box_enclosure()** - Main Electronics Housing with Snap-Fit Lid
```
Material: ASA (recommended for electronics protection)
Layer Height: 0.2mm
Infill: 25%
Wall Lines: 4 (total 1.6mm wall thickness)
Top/Bottom Layers: 8
Print Speed: 50mm/s
Support: Yes (for overhangs and mounting posts)
Orientation: Open top up
Post-Processing:
  - Sand all mating surfaces
  - Test snap-fit operation
  - Apply conformal coating to electronics areas
  - NO SCREWS NEEDED - snap-fit lid and component mounts
```

#### **control_box_lid()** - Snap-Fit Removable Lid
```
Material: ASA or PETG
Layer Height: 0.15mm (for tight fit)
Infill: 30%
Wall Lines: 4
Top/Bottom Layers: 8
Print Speed: 45mm/s
Support: Minimal
Orientation: Outside face down
Post-Processing:
  - Test snap-arm flexibility
  - Verify lid engagement
  - NO SCREWS NEEDED - snap arms engage catches directly
```

### **Outlet_Vacuum_Hose_Adapter.scad**

#### **Standard Hose Adapter with Snap Retention**
```
Material: PETG (chemical resistance for cleaning)
Layer Height: 0.2mm
Infill: 35%
Wall Lines: 4
Top/Bottom Layers: 6
Print Speed: 50mm/s
Support: Tree supports only
Orientation: Large end down
Post-Processing:
  - Sand connection surfaces smooth
  - Test snap retention grooves
  - NO CLAMPS NEEDED - built-in snap retention holds hoses securely
```

## 🔧 **BOM Component Compatibility Verification**

Before printing, verify these critical component fits:

### **Electronics (Adafruit Components)**
- [ ] **ESP32-S3 Feather** (Adafruit 5323): 51x23mm - verify mounting post spacing
- [ ] **VL53L0X Sensor** (Adafruit 3317): 18x18mm STEMMA QT board
- [ ] **OLED Display** (Adafruit 326): 27x27mm mounting cutout
- [ ] **BME280 Sensor** (Adafruit 4816): 18x18mm STEMMA QT board
- [ ] **Large Arcade Button** (Adafruit 368): 60mm diameter cutout
- [ ] **Terminal Block Kit** (Adafruit 4090): 2.54mm pitch mounting

### **Power Components**
- [ ] **Mean Well LRS-35-5**: 54x27x23mm chassis mount PSU
- [ ] **SparkFun SSR-40A**: 58x45x32mm chassis mount relay

### **Panel Components**
- [ ] **Schurter IEC Inlet** (4300.0030): 20x13mm cutout
- [ ] **Leviton NEMA Outlet** (5320-W): 15x20mm cutout

### **Wire Management**
- [ ] **Silicone Wire**: 8mm strain relief holes for 26AWG wire
- [ ] **STEMMA QT Cables**: 100mm and 200mm cable routing

## 🔧 **Advanced Print Settings**

### **Temperature Settings**
| Material | Nozzle Temp | Bed Temp | Chamber Temp |
|----------|-------------|----------|--------------|
| PETG     | 240-250°C   | 70-80°C  | Ambient      |
| ASA      | 250-260°C   | 90-100°C | 40-60°C      |
| PLA+     | 210-220°C   | 60°C     | Ambient      |

### **Critical Print Parameters**
- **First Layer**: 120% width, 50% speed for adhesion
- **Cooling**: Minimal for ASA/PETG, 50% for PLA+
- **Retraction**: 2-3mm @ 40mm/s
- **Z-Hop**: 0.2mm to prevent nozzle dragging

## 🛡️ **Field Durability Enhancements**

### **Post-Processing Steps**
1. **Surface Preparation**
   - Sand all surfaces with 220-400 grit
   - Remove support marks and layer lines
   - Clean with isopropyl alcohol

2. **UV Protection Treatment**
   - Apply 2-3 coats of UV-resistant clear coat
   - Recommended: Krylon UV-Resistant Clear Coating
   - Allow 24-48 hours cure time between coats

3. **Hardware Installation**
   - Use stainless steel fasteners (316 grade)
   - Apply marine-grade thread locker
   - Install EPDM or Viton O-rings for sealing

4. **Electrical Protection**
   - Apply conformal coating to electronics
   - Use IP67-rated cable glands
   - Ensure proper grounding connections

### **Quality Control Checklist for Snap-Fit Assembly**
- [ ] No visible layer separation or voids
- [ ] Smooth hose connection surfaces (Ra < 3.2μm)
- [ ] **Snap-fit arms flex without breaking**
- [ ] **Snap catches engage and disengage smoothly**
- [ ] **Component mounts hold securely without fasteners**
- [ ] Proper fit test with actual BOM components
- [ ] UV coating coverage complete
- [ ] **Tool-free assembly verification**
- [ ] **Snap retention force testing**

## 📊 **Expected Service Life**

| Material + Treatment | Expected Life | Replacement Indicators |
|---------------------|---------------|------------------------|
| ASA (untreated)     | 5+ years      | Surface chalking, brittleness |
| ASA + UV coating    | 7+ years      | Coating degradation |
| PETG + UV coating   | 3-4 years     | Color change, surface roughening |
| PLA+ + UV coating   | 1-2 years     | Warping, cracking |

## 🔍 **Inspection Schedule**

### **Monthly (First 6 months)**
- Visual inspection for cracks or UV damage
- Check mounting hardware torque
- Verify seal integrity

### **Quarterly (After 6 months)**
- Detailed inspection of all surfaces
- Hardware replacement if corroded
- Re-apply UV coating if showing wear

### **Annually**
- Complete disassembly and inspection
- Replace O-rings and gaskets
- Consider component replacement based on wear

## 📞 **Support and Updates**

For questions about print settings or field performance:
- Check project issues on GitHub
- Review latest updates in project documentation
- Consider material supplier recommendations for local climate conditions

**Remember**: Field conditions vary significantly. These recommendations are starting points - adjust based on your specific deployment environment and experience.
