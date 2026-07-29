# 3D Printable Models - ShopVac Rat Trap

This directory contains all 3D printable components for the IoT-enabled rat trap system. All parts are designed for standard FDM printers and fit on a **220x220mm build plate**.

## Requirements

- **OpenSCAD 2019.05 or later** is required. The bait station uses `rotate_extrude(angle=...)` which was introduced in 2019.05. Older versions silently ignore the `angle` parameter and produce a full 360-degree revolution, breaking bayonet slot geometry.

## Model Inventory

| File | Description | Supports Needed |
|------|-------------|-----------------|
| `trap_ramp_entrance.scad` | Flat ramp entrance with archway transition to tube | No |
| `trap_body_front.scad` | Front body half (125mm), includes bait port boss | No |
| `trap_body_rear.scad` | Rear body half (125mm), includes cable channel | No |
| `vacuum_adapter_universal.scad` | Stepped adapter for shop vac hoses (multi-size) | No |
| `bait_station.scad` | Tube section with external bait port and bayonet cap | No |
| `bait_cap.scad` | Standalone bayonet-twist cap for bait station port | No |
| `control_box_exit_mount.scad` | Electronics enclosure (ESP32, SSR, sensors) | No |
| `control_box_lid.scad` | Control box lid with OLED display cutout | No |
| `assembly.scad` | Full assembly visualization (not printed) | N/A |

### Shared Libraries (Not Printed)

| File | Purpose |
|------|---------|
| `trap_modules.scad` | All shared parameters, BOM dimensions, and reusable modules |
| `helpers.scad` | Geometry primitives: `tube()`, `flange()`, `rounded_box()` |

## Shared Parameters

All parts include `trap_modules.scad` which defines consistent dimensions:

### Core Tube Dimensions (4" PVC Standard)

```openscad
tube_od = 101.6;          // 4" PVC outer diameter (mm)
wall_thickness = 3.2;     // Tube wall thickness (mm)
tube_id = 95.2;           // Inner diameter (tube_od - 2*wall_thickness)
print_tolerance = 0.3;    // FDM clearance for mating parts (mm)
```

### Flange Joint Parameters

```openscad
flange_od = 120;          // Outer diameter of flange ring (mm)
flange_thickness = 5;     // Height of each flange plate (mm)
lip_length = 10;          // Length of male lip / female socket depth (mm)
bolt_hole_diameter = 4.5; // M4 clearance hole (mm)
bolt_count = 4;           // Bolts evenly spaced at 90 degrees
```

### Cable Channel

```openscad
cable_channel_od = 12;    // Outer diameter of external conduit (mm)
cable_channel_id = 8;     // Inner diameter - fits JST SH connectors (mm)
```

## Joint System

### Bolted Flange Joints (Main Tube Connections)

All major tube-to-tube connections use a **bolted flange joint** system:

1. **Male end**: A slightly undersized lip (tube_od - 2*print_tolerance) extends from a flange plate
2. **Female end**: A socket ring receives the male lip with clearance
3. **Fastening**: 4x M4x16mm bolts pass through aligned flange plates to clamp the joint
4. **Sealing**: The close-fitting lip provides a snug connection; O-ring groove available for split body joint

**Assembly procedure:**
1. Align male lip with female socket
2. Slide parts together until flanges meet
3. Insert 4x M4x16mm bolts through flange holes
4. Tighten evenly in a cross pattern

### Bayonet-Twist Cap (Bait Station Only)

The bait station cap uses a **bayonet-twist** system with 3 L-shaped slots for tool-free access. This is intentional -- the bait cap needs frequent removal and does not require bolt security.

## Print Settings

### Material

- **PETG** (recommended) - Good strength, UV resistant, excellent layer adhesion
- **ASA** (outdoor use) - Superior UV resistance and weatherproofing
- **PLA** (not recommended) - Brittle, poor UV resistance, may warp in heat

### Slicer Settings

| Setting | Value | Notes |
|---------|-------|-------|
| Layer Height | 0.2mm | 0.3mm acceptable for draft prints |
| Infill | 20-40% | 20% for non-structural, 40% for tube bodies |
| Wall Count | 3-4 perimeters | Ensures rodent resistance |
| Top/Bottom Layers | 4-5 | For water resistance |
| Supports | Not needed | Parts designed for supportless printing |
| Bed Adhesion | Brim recommended | For large tube parts |

### Print Orientations

| Model | Orientation | Notes |
|-------|-------------|-------|
| trap_ramp_entrance | Flat (ramp surface down) | Prints without supports |
| trap_body_front | Upright (tube axis vertical) | Flanges at top/bottom |
| trap_body_rear | Upright (tube axis vertical) | Flanges at top/bottom |
| vacuum_adapter_universal | Large end down | Steps print cleanly |
| bait_station | Upright (tube axis vertical) | Cap prints separately |
| control_box_exit_mount | Upright (open side up) | Screw posts print upward |
| control_box_lid | Flat (outside face down) | Clean top surface |

## Generating STL Files

> **Note:** OpenSCAD 2019.05+ is required. See [Requirements](#requirements) above.

### Build All Models

```bash
cd 3d_models
for file in *.scad; do
    [ "$file" = "trap_modules.scad" ] && continue  # Skip library
    [ "$file" = "helpers.scad" ] && continue        # Skip library
    [ "$file" = "assembly.scad" ] && continue       # Skip visualization
    openscad -o "${file%.scad}.stl" "$file"
done
```

### Build Single Model

```bash
openscad -o trap_body_front.stl trap_body_front.scad
```

### Using the Build Script

```bash
python .github/scripts/build.py --build
```

## Hardware Required

### Flange Joint Fasteners (per joint)

- 4x M4x16mm bolts (stainless steel)
- 4x M4 washers

The trap has 4 flange joints total (ramp-to-front, front-to-rear, rear-to-adapter, and bait station connections), requiring **16x M4x16mm bolts** and **16x M4 washers** for the complete assembly.

### Split Body Seal

- 1x O-ring (2.5mm cross-section, ~95mm ID, Buna-N or Viton)

### Alignment

- 2x 6mm diameter alignment pins (front/rear body joint)

## Cable Routing

All trap tube sections include an integrated **top-mounted external cable conduit** (12mm OD, 8mm ID). This conduit runs along the outside of the tube and carries STEMMA QT cables between sections.

### Cable Path

```
Ramp Entrance --> Front Body --> Rear Body --> Vacuum Adapter
                                                     |
                                              Control Box
```

### Cable Specifications

- **STEMMA QT cables**: ~1-2mm diameter (26AWG, 4-wire)
- **JST SH connectors**: 5x7x3.5mm (fit within 8mm channel ID)
- **Max bundle**: 5 cables fit in 6mm usable channel space
- **Service loop**: 10cm extra cable inside control box

### Maintenance Access

Disconnect any flange joint (4x M4 bolts) to access cables for repair or replacement.

## Assembly Order

1. **Print all tube sections** (ramp, front body, rear body, vacuum adapter)
2. **Print control box** (exit mount + lid)
3. **Print bait station** (optional, can be added later)
4. **Assemble tube** (ramp -> front -> rear -> adapter) using M4 bolts at each joint
5. **Mount control box** to vacuum adapter bracket
6. **Route cables** through conduit channels before final bolt-up
7. **Connect vacuum hose** to adapter (friction fit with ribs)
8. **Attach bait station** if used

## Component Fitment (BOM Cross-Reference)

All models use verified dimensions from BOM components:

| Component | Adafruit Part | Mount Location |
|-----------|---------------|----------------|
| VL53L0X ToF Sensor | 3317 | Trap entrance (sensor module) |
| APDS9960 Proximity | 3595 | Trap entrance (sensor module) |
| BME280 Environmental | 4816 | Control box |
| PIR Motion (4871) | 4871 | Front body (internal) |
| OV5640 Camera | 5945 | Control box (optional) |
| ESP32 Feather | - | Control box (internal mount) |
| OLED 128x64 | 326 | Control box lid (display cutout) |
| SSR (AQA411VL) | - | Control box (internal mount) |

See `../BOM_CONSOLIDATED.csv` for the complete bill of materials.

## Design Philosophy

- **Modular**: Each section is a separate print connected by bolted flanges
- **Supportless**: All parts designed to print without support material
- **Robust**: 3.2mm wall thickness resists rodent damage
- **Serviceable**: Flange joints allow full disassembly for cleaning and cable access
- **Standard sized**: Every part fits a 220x220mm build plate
- **Consistent**: All dimensions derive from `trap_modules.scad` shared library

## Post-Processing

1. **Clean holes** with a 4mm drill bit (for M4 bolt holes)
2. **Test fit** alignment pins and adjust with a file if needed
3. **Sand** flange faces for better sealing (220-400 grit)
4. **Dry-fit** all joints before final assembly with cables

---

**Last Updated:** 2025-01-15
**Models:** 8 printable parts + 1 assembly visualization
**Shared Libraries:** 2 (trap_modules.scad, helpers.scad)
**Build Plate:** All parts fit 220x220mm
