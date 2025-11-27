# 3D Models

This directory contains all the 3D models for the ShopVac Rat Trap.

## Build Plate Compatibility

All models are designed to fit on **standard 220x220mm build plates** (e.g., Ender 3, Prusa i3).

| Model | Dimensions (X×Y×Z mm) | Build Plate Fit |
|-------|----------------------|-----------------|
| trap_entrance | 102×102×80 | ✅ Yes |
| trap_body_front | 142×102×125 | ✅ Yes |
| trap_body_rear | 142×102×125 | ✅ Yes |
| trap_funnel_adapter | ~90×90×80 | ✅ Yes |
| vacuum_funnel | ~80×80×60 | ✅ Yes |
| bait_station | 50×50×50 | ✅ Yes |
| sensor_mount | 80×80×60 | ✅ Yes |
| camera_mount | 60×60×60 | ✅ Yes |
| control_box_enclosure | 156×106×60 | ✅ Yes |
| control_box_lid | 156×106×10 | ✅ Yes |

## File Structure

### Main Trap Components

- `trap_entrance.scad`: 4-inch opening with sensor mounts and flange connector.
- **`trap_body_front.scad`**: Front half of main body (125mm) with PIR mount and bait port.
- **`trap_body_rear.scad`**: Rear half of main body (125mm) connects to funnel.
- `trap_funnel_adapter.scad`: Modular funnel to connect to shop vacuum.
- `bait_station.scad`: Removable bait station.

**Note**: The trap body is split into two halves to fit standard build plates. They connect via:
- Flanged joint with M4 screws (4 holes at 45°, 135°, 225°, 315°)
- Two 6mm alignment pins for precise positioning
- O-ring groove for airtight seal

### Electronics Enclosure

- `control_box_enclosure.scad`: Enclosure for ESP32 and low-voltage electronics (150×100×50mm interior).
- `control_box_lid.scad`: Lid for control box with display cutout.

### Sensor Mounts

- `sensor_mount.scad`: Universal mount for attaching sensors to PVC pipe.
- `camera_mount.scad`: Mount for OV5640 camera (camera variant only).

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
