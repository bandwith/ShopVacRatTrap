# 3D Models

This directory contains all the 3D models for the ShopVac Rat Trap.

## Build Plate Compatibility

All models are designed to fit on **standard 220x220mm build plates** (e.g., Ender 3, Prusa i3).

| Model | Dimensions (X×Y×Z mm) | Build Plate Fit |
|-------|----------------------|-----------------|
| trap_entrance | 102×102×80 | ✅ Yes |
| trap_body_front | 142×102×125 | ✅ Yes |
# 3D Printable Models - ShopVac Rat Trap

This directory contains all 3D printable components for the rat trap system, designed for standard FDM printers with **actual BOM component dimensions**.

## 📋 Model Inventory

All models updated with precise dimensions from component datasheets.

### Core Trap Components

| Model | Description | Dimensions | Print Time* | Material |
|-------|-------------|------------|-------------|----------|
| `trap_entrance.scad` | Sensor and bait port assembly | ~130mm | 3-4h | PETG/ASA |
| `trap_body_front.scad` | Front body half (125mm) | 125×101mm | 8-10h | PETG/ASA |
| `trap_body_rear.scad` | Rear body half (125mm) | 125×101mm | 6-8h | PETG/ASA |
| `trap_funnel_adapter.scad` | Vacuum connection adapter | ~150mm | 10-12h | PETG/ASA |
| `vacuum_funnel.scad` | Shop vac funnel interface | ~180mm | 12-14h | PETG/ASA |
| `bait_station.scad` | External bait compartment | Small | 2-3h | PETG/ASA |

**Note:** `trap_body_main.scad` (250mm) is **legacy** - use split front/rear halves instead!

### Sensor & Electronics Mounts

| Model | Description | Component | Dimensions | STL |
|-------|-------------|-----------|------------|-----|
| `stemma_qt_mount.scad` | **NEW** Universal STEMMA QT mount | VL53L0X, APDS9960, BME280 | 17.78×25.4mm boards | 28K |
| `camera_mount.scad` | OV5640 camera mount | Adafruit 5945 | 32×32mm PCB | 138K |
| `sensor_mount.scad` | Universal pipe clamp mount | Generic sensors | 2-part clamp | 568K |

### Control Box

| Model | Description | Fits | Print Time* |
|-------|-------------|------|-------------|
| `control_box_enclosure.scad` | Main electronics enclosure | Hammond PN-1334-C footprint | 12-15h |
| `control_box_lid.scad` | Enclosure cover | Matches enclosure | 5-6h |

\* *Print times are estimates at 0.2mm layer height, 50mm/s*

## 🔧 Component Fitment

All models designed for **actual BOM components** with verified dimensions:

### STEMMA QT Sensors (Adafruit Standard)
- **Board Size:** 17.78mm × 25.4mm (0.7" × 1.0")
- **Mounting Holes:** M2.5, 12.7mm × 20.3mm spacing
- **Compatible Models:**
  - VL53L0X Time-of-Flight (3317)
  - APDS9960 Proximity/Gesture (3595)
  - BME280 Environmental (4816)
- **Mount:** `stemma_qt_mount.scad` - universal design

### Camera System
- **Board:** 32mm × 32mm square (Adafruit 5945 OV5640)
- **Lens:** M12 mount, 14mm clearance hole
- **Mounting:** 4× M2.5 corners, 28mm spacing
- **Mount:** `camera_mount.scad` - OV5640 specific

### PIR Motion Sensor
- **Board:** 32mm × 24mm (Adafruit 4871)
- **Mounting:** 2× M3 holes, 28mm spacing
- **Dome:** 12mm diameter, requires clearance
- **Parameters:** Defined in `trap_modules.scad`

### Control Box Components
- **Enclosure:** Hammond PN-1334-C (200×120×75mm ext, 192×112×69mm int)
- **ESP32 Feather:** 50.8×22.9mm, M2.5 holes at 48.26×20.32mm
- **OLED Display:** 27×27.5mm, 2× M2.5 holes
- **SSR:** Panasonic AQA411VL (40×58×25.5mm)

## 🖨️ Build Plate Compatibility

**Standard Build Plate:** 220mm × 220mm

| Status | Model | Max Dimension | Notes |
|--------|-------|---------------|-------|
| ✅ | trap_entrance | ~130mm | Fits easily |
| ✅ | trap_body_front | 125mm | Designed for compatibility |
| ✅ | trap_body_rear | 125mm | Designed for compatibility |
| ⚠️ | trap_body_main | 250mm | **LEGACY - DO NOT USE** |
| ✅ | trap_funnel_adapter | ~150mm | Diagonal fit |
| ✅ | vacuum_funnel | ~180mm | Fits on 220×220 |
| ✅ | control_box_enclosure | 200mm | Fits lengthwise |
| ✅ | stemma_qt_mount | ~26mm | Very small |
| ✅ | camera_mount | ~40mm | Small |

**Compatibility:** 11 of 12 models (91.7%)

## 🔨 Generating STL Files

### Build All Models

```bash
cd 3d_models
for file in *.scad; do
    [ "$file" = "trap_modules.scad" ] && continue  # Skip library
    openscad -o "${file%.scad}.stl" "$file"
done
```

### Build Single Model

```bash
openscad -o trap_entrance.stl trap_entrance.scad
```

## 📐 Shared Parameters

`trap_modules.scad` contains shared dimensions and modules:

### Core Parameters
```openscad
// Tube dimensions
tube_outer_diameter = 101.6;  // 4" PVC standard
tube_wall_thickness = 3.2;
flange_diameter = 120;

// STEMMA QT sensors (Adafruit standard)
stemma_qt_board_width = 17.78;   // 0.7"
stemma_qt_board_length = 25.4;   // 1.0"
stemma_qt_hole_diameter = 2.7;   // M2.5 clearance

// PIR sensor (Adafruit 4871)
pir_board_width = 24;
pir_board_length = 32;
pir_hole_diameter = 3.2;  // M3 clearance

// Center joint (for split body)
alignment_pin_diameter = 6;   // 6mm pins
oring_groove_width = 3;       // For 2.5mm O-ring
```

## 🛠️ Print Settings

### Recommended Settings
- **Material:** PETG or ASA (outdoor durability required)
- **Layer Height:** 0.2mm (standard) or 0.3mm (draft)
- **Infill:** 20% (structural) or 15% (non-structural)
- **Wall Count:** 3-4 perimeters
- **Top/Bottom Layers:** 4-5 layers
- **Supports:** Required for overhangs >45°
- **Bed Adhesion:** Brim recommended for large parts

### Post-Processing
1. Remove support material carefully
2. Test fit components before final assembly
3. Clean up layer lines on visible surfaces
4. Install threaded inserts while plastic is hot (M3/M4 holes)

## 📦 Assembly Notes

### Split Trap Body Assembly
The trap body is split into front and rear halves for build plate compatibility:

1. **Alignment:** 2× 6mm diameter pins on front half
2. **Joining:** Pins fit into holes on rear half
3. **Sealing:** O-ring groove in front half (use 2.5mm O-ring)
4. **Fastening:** Flanges with M4 screws at 4 positions

### Sensor Integration
- Mount STEMMA QT sensors to `stemma_qt_mount.scad` first
- Attach sensor mounts to trap entrance
- Route STEMMA QT cables (500mm main run from entrance to control box)
- PIR mounts internally in trap body front

## 📊 Bill of Materials Cross-Reference

See `../BOM_CONSOLIDATED.csv` for complete component list.

**Key 3D Model → BOM Mappings:**
- STEMMA QT sensors → Adafruit 3317, 3595, 4816
- Camera → Adafruit 5945 (OV5640)
- PIR → Adafruit 4871
- Display → Adafruit 326 (OLED 128×64)
- Enclosure → Hammond PN-1334-C (Bud Industries)

## 📖 Additional Documentation

- **Build Report:** `build_report.md` - Print time estimates and material usage
- **Component Dimensions:** `../docs/hardware/component-dimensions.md` - Full specs
- **Assembly Guide:** `../docs/hardware/assembly.md` - Step-by-step instructions

## 🚀 Quick Start

1. **Print structural parts first:** trap_body_front, trap_body_rear, funnel_adapter
2. **Print sensor mounts:** stemma_qt_mount (print 3× for all sensors)
3. **Print control box:** enclosure and lid
4. **Test fit components** as you print
5. **Assemble and integrate** following assembly guide

**Total Print Time:** ~48-60 hours
**Total Material:** ~1.5-2kg PETG/ASA filament

---

**Last Updated:** 2024-11-27
**STL Files Generated:** 12 models
**Build Plate Compatibility:** 11/12 models (220×220mm)

### Accessories

- `vacuum_funnel.scad`: Funnel for connecting PVC pipe to shop vacuum hose.

### Shared Modules

- `trap_modules.scad`: Shared parameters and reusable modules (tubes, flanges, joints).

## Generating STL Files

To generate the STL files for printing:

```bash
python .github/scripts/build.py --build
```

This script will generate STL files for all SCAD files in this directory.

## Printing Recommendations

### Material

- **PETG** (recommended) - Great strength, UV resistant, good layer adhesion
- **ASA** (outdoor use) - Excellent UV resistance, weatherproof
- **PLA** (not recommended) - Brittle, poor UV resistance, may deform in heat

### Print Settings

| Setting | Value | Notes |
|---------|-------|-------|
| Layer Height | 0.2mm | Good balance of speed vs quality |
| Infill | 40% | Gyroid pattern for strength |
| Wall Thickness | 4mm | Ensures durability |
| Top/Bottom Layers | 5 | For water resistance |
| Supports | Required | See orientation guide below |

### Print Orientations

| Model | Orientation | Supports | Notes |
|-------|-------------|----------|-------|
| trap_entrance | Flat base down | Minimal | Sensor mounts may need support |
| trap_body_front | Flat base down | Internal supports | For PIR mount overhang |
| trap_body_rear | Flat base down | Minimal | Simple geometry |
| trap_funnel_adapter | Wide end down | Yes | Funnel taper needs support |
| bait_station | Flat side down | No | Simple print |
| sensor_mount | Flat base down | Minimal | Clean underside |
| camera_mount | Flat base down | Yes | Camera slot overhang |
| control_box_enclosure | Upright (lid side up) | No | Prints well without supports |
| control_box_lid | Flat (outside down) | No | Screw posts print upward |
| vacuum_funnel | Wide end down | Yes | Conical shape |

## Assembly Notes

### Trap Body Assembly

1. Print both `trap_body_front` and `trap_body_rear`
2. Test fit alignment pins (should slide smoothly but not loose)
3. Install O-ring in groove on front half (2.5mm cross-section, ~95mm ID)
4. Align rear half onto pins
5. Secure with 4× M4×16mm screws and washers
6. Tighten evenly in cross pattern

### Hardware Required for Split Body

- 4× M4×16mm screws (stainless steel)
- 4× M4 washers
- 1× O-ring (2.5mm cross-section, 95-100mm inner diameter, Buna-N or Viton)

## Post-Processing

1. **Remove supports** carefully with pliers and flush cutters
2. **Clean holes** with appropriate drill bit (4mm for M4 holes)
3. **Test fit** alignment pins and adjust with file if needed
4. **Sand** flat surfaces for better gasket seal (220-400 grit)
5. **Acetone vapor smooth** (ASA only) for weatherproofing

## Design Philosophy

- **Modular**: Easy to modify individual components
- **Printable**: No supports needed for most parts
- **Robust**: 4mm wall thickness withstands rodent damage
- **Serviceable**: Flanged joints allow disassembly for cleaning
- **Standard sized**: All parts fit common 220×220mm build plates
