# Component Dimensions Reference

## Critical Components from BOM

### Power & Control

#### Panasonic AQA411VL Solid State Relay
- **Dimensions:** 40mm (W) × 58mm (L) × 25.5mm (H)
- **Mounting:** Panel mount with screw terminals
- **Control:** 4-32V DC (3.3V compatible)
- **Load:** 25A @ 75-250V AC
- **Features:** Built-in LED, zero-cross switching, 4000V isolation
- **Heatsink:** Crydom HSP-7 thermal pad required
- **3D Model Impact:** Must accommodate in enclosure with thermal clearance

#### Mean Well LRS-35-5 Power Supply
- **Dimensions:** 99mm (L) × 82mm (W) × 30mm (H)
- **Mounting:** Chassis mount, 4× M4 screw holes
- **Output:** 5V DC, 7A
- **Input:** 100-240V AC universal
- **3D Model Impact:** Must fit in Hammond enclosure with ventilation

#### Schneider XB6ETN521P Emergency Stop
- **Panel Cutout:** 16mm diameter
- **Mushroom Head:** 32mm diameter
- **Panel Thickness:** 0.5-6mm
- **Behind Panel Depth:** ~55mm
- **Minimum Clearance:** 41mm
- **Contacts:** 2NC + 2NO
- **3D Model Impact:** 16mm hole in control box front panel

### Enclosure

#### Hammond PN-1334-C (Note: Actually Bud Industries)
- **External:** 200mm (L) × 120mm (W) × 74.9mm (H)
- **Internal:** 192mm (L) × 112mm (W) × 68.6mm usable depth
- **Material:** Gray polycarbonate
- **Rating:** IP65, NEMA 1/2/4/4X/12/13
- **Mounting:** Wall mount holes, internal PCB bosses
- **Cover:** Clear, M4 stainless screws
- **3D Model Impact:** All internal components must fit within 192×112×68.6mm

### Microcontroller & Sensors

#### Adafruit ESP32-S3 Feather (5323)
- **PCB:** 50.8mm × 22.9mm (2.0" × 0.9")
- **Mounting Holes:** 48.26mm × 20.32mm spacing
- **Hole Size:** 2.5mm (M2.5 screws)
- **Standoff Height:** 5mm recommended
- **STEMMA QT:** Built-in connector on board
- **3D Model Impact:** Precise mounting plate needed

#### Adafruit VL53L0X ToF Sensor (3317)
- **PCB:** 17.78mm × 25.4mm (STEMMA QT standard 0.7" × 1.0")
- **Mounting Holes:** 4× holes, M2.5 compatible
- **STEMMA QT:** Side-mounted JST SH connector
- **Sensor Height:** ~3mm above PCB
- **Range:** 0.05-1.2m
- **3D Model Impact:** Standard STEMMA QT mount

#### Adafruit APDS9960 Proximity/Gesture (3595)
- **PCB:** 17.78mm × 25.4mm (STEMMA QT standard)
- **Mounting Holes:** 4× holes, M2.5 compatible
- **STEMMA QT:** Side-mounted
- **Sensor Window:** Top-facing, needs clear view
- **3D Model Impact:** Top-down orientation required

#### Adafruit PIR Motion Sensor (4871)
- **PCB:** ~32mm × 24mm
- **PIR Dome:** 10mm diameter hemisphere
- **Mounting:** 2× M3 holes, 28mm spacing
- **STEMMA:** 3-pin JST connector
- **Detection Range:** 120° cone, 3-7m
- **3D Model Impact:** Dome needs clearance, forward-facing

#### Adafruit OLED Display 128×64 (326)
- **PCB:** 27mm × 27.5mm
- **Display Area:** 21.7mm × 10.9mm (visible)
- **STEMMA QT:** Bottom-mounted
- **Mounting Holes:** 2× M2.5, 4mm from edges
- **Thickness:** ~7mm total
- **3D Model Impact:** Front panel bezel mount

#### Adafruit BME280 Environmental (2652)
- **PCB:** 17.78mm × 25.4mm (STEMMA QT standard)
- **Mounting Holes:** 4× M2.5
- **STEMMA QT:** Side-mounted
- **Sensor:** Top surface, needs airflow
- **3D Model Impact:** Standard mount with ventilation

### Camera System (Optional)

#### Adafruit OV5640 Camera (5946)
- **PCB:** 32mm × 32mm
- **Lens:** 8mm diameter, M12 mount
- **STEMMA QT:** Side-mounted
- **Mounting Holes:** 4× M2.5 in corners, 28mm spacing
- **Focal Distance:** Adjustable via lens rotation
- **3D Model Impact:** 32mm square mount with lens clearance

#### Adafruit High-Power IR LED (5639)
- **PCB:** Small breakout
- **LED:** 5mm high-power
- **Connector:** STEMMA JST PH (not QT)
- **Range:** 10+ meters
- **3D Model Impact:** Forward-facing mount near camera

### User Interface

#### Adafruit Large Arcade Button (368)
- **Button Diameter:** 60mm
- **Panel Cutout:** 24mm diameter
- **Mounting Depth:** ~40mm behind panel
- **Snap-in:** No screws required
- **Switch:** SPST momentary
- **3D Model Impact:** 24mm hole in control box panel

### Cables

#### STEMMA QT Cables
- **Connector:** JST SH 4-pin (1mm pitch)
- **Profile:** ~3mm height
- **Bend Radius:** 10mm minimum
- **Lengths Available:** 50mm, 100mm, 500mm

#### STEMMA JST PH Cables
- **Connector:** JST PH 4-pin (2mm pitch)
- **Profile:** ~5mm height
- **For:** IR LED only
- **Lengths:** 200mm

### AC Connectors

#### Schurter DF11.2078.0010.01 IEC Inlet
- **Panel Cutout:** 27.5mm × 47.5mm rectangular
- **Mounting:** Snap-in with locking tabs
- **Features:** Integrated circuit breaker + switch
- **Behind Panel:** ~60mm depth
- **3D Model Impact:** Rear panel cutout

#### Schurter 6600.3100 IEC Outlet
- **Panel Cutout:** Standard IEC C13 (~28mm × 50mm)
- **Mounting:** Snap-in or screw mount
- **Behind Panel:** ~35mm depth
- **3D Model Impact:** Rear panel cutout

## Summary Table & CAD Variation Allowances

All 3D models in `3d_models/` share a single parametric source of truth (`3d_models/trap_modules.scad`) using `print_tolerance = 0.3mm` for FDM dimensional variation:

| Component | Nominal Datasheet Size | Mounting Pattern | CAD Feature / Pocket Size | Variation Allowance & Purpose |
|-----------|------------------------|------------------|---------------------------|-------------------------------|
| **Adafruit ESP32-S3 Feather** (`5323`) | `50.8 × 22.9 × 7.0mm` | `48.26 × 20.32mm` (`4× M2.5`) | `esp32_hole_spacing_y = 48.26mm`, `esp32_hole_spacing_x = 20.32mm`, `d = 2.7mm` on `6mm` standoffs | **+0.2mm** hole clearance (`2.7mm` for `M2.5`), **+6.0mm** standoff for USB-C / STEMMA strain relief |
| **STEMMA QT Breakouts** (`VL53L4CX`, `STHS34PF80`, `LSM6DSOX`, `BME280`, `APDS9960`) | `25.4 × 17.78 × 1.6mm` (`1.0" × 0.7"`) | `20.3 × 12.7mm` (`4× M2.5`) | Pocket: `26.0 × 18.38mm` (`+2 × print_tolerance`), holes: `d = 2.7mm`, window bore: `d = 18.38mm` | **+0.6mm** (`±0.3mm`) XY pocket allowance for PCB breakaway tabs and FDM wall shrinkage |
| **PIR Motion Sensor** (`4871`) | `32.0 × 24.0mm` PCB, `12.0mm` lens dome | `28.0mm` (`2× M3`) | `pir_hole_diameter = 3.2mm`, `pir_dome_clearance = 14.0mm` | **+0.2mm** hole clearance (`3.2mm` for `M3`), **+2.0mm** dome clearance (`14mm` hole for `12mm` dome) |
| **OV5640 Camera Breakout** (`5946`) | `32.0 × 32.0mm` PCB, `8–12mm` M12 lens | `28.0 × 28.0mm` (`4× M2.5`) | `camera_hole_diameter = 2.7mm`, `camera_lens_clearance = 14.0mm` | **+2.0–6.0mm** lens barrel clearance (`14mm` bore) for manual focus adjustment |
| **Monochrome OLED `128×64`** (`326`) | `27.0 × 27.5 × 7.0mm` (`21.7 × 10.9mm` active) | `2× M2.5` (`4mm` inset) | `oled_board_width = 27.0mm`, `oled_active_width = 23.0 × 12.0mm`, `d = 2.7mm` | **+1.3 × 1.1mm** viewing bezel margin around active OLED glass |
| **Panasonic SSR** (`AQA411VL`) | `58.0 × 40.0 × 25.5mm` | `48.0mm` (`2× M3/M4` slots) | `ssr_length = 58.0mm`, `2× d = 3.2mm` posts on `48.0mm` centers (`6mm` standoff) | Placed at `X_int = 64..112mm` inside `120mm` cavity (**+8.0mm** wall clearance for `HSP-7` thermal pad) |
| **Removable Sensor Plate** (`sensor_mounting_plate`) | `56.0 × 48.0 × 3.0mm` | Tool-free vertical slide rails | U-channel rails: `3.6mm` slot width × `3.0mm` depth (`X_int = 25..85mm`) | **+0.6mm** (`0.3mm/side`) slide clearance in `3.6mm` U-channel for tool-free drop-in removal |
| **STEMMA QT / JST-SH Harness** | `~6.0mm` connector housing diagonal | Top conduit & PG7 glands | `cable_channel_id = 8.0mm` (`12.0mm` OD), PG7 glands: `d = 12.5mm` | **+2.0mm** bore clearance over `6mm` JST-SH shells so pre-crimped cables thread without depinning |
| **Control Box Lid** (`control_box_lid`) | `128.0 × 108.0 × 4.0mm` | `120.0 × 100.0mm` opening + `4× M3` | Lip outer: `119.4 × 99.4 × 3.0mm` (`-2 × print_tolerance`), holes: `d = 3.4mm` | **-0.6mm** (`0.3mm/side`) perimeter lip clearance into `120 × 100mm` box opening |
| **Tube Flange Joints** (`flange_joint_male` / `female`) | `101.6mm` (`4"` PVC OD) male lip | `4× M4` at `r = 58.5mm` (`45°/135°/225°/315°`) | Socket ID: `102.2mm` (`+2 × lip_clearance`), depth: `10.0mm` (`9.5mm` lip), holes: `d = 4.5mm` | **+0.6mm** diametral (`0.3mm` radial) spigot clearance, **+0.5mm** axial clearance, **+0.5mm** bolt clearance |

## Tool-Free Operation & Rodent-Resistance Verification

1. **Tool-Free Servicing & Disassembly:**
   - **Baiting (`bait_cap.scad`):** 3-lug `30°` bayonet twist-lock with `12×` external grip ribs (`0.3mm` radial/axial clearance) opens and locks by hand.
   - **Sensor Maintenance (`sensor_mounting_plate`):** Slides vertically into fused `3.6mm` U-channel rails inside `control_box_exit_mount.scad` without tools.
   - **Vacuum Connection (`vacuum_adapter_universal.scad`):** Stepped `2-1/2"`, `1-7/8"`, and `1-1/4"` friction-fit hose barbs with grip ribs.
   - **Tube Breakdown (`flange_joint_male` / `female`):** `4× M4` flange bolts at `r = 58.5mm` (`45°/135°/225°/315°`) provide `7.7mm` radial clearance from the `101.6mm` tube wall for tool-free `M4` thumbscrews or wing nuts.
2. **Rodent-Resistance Structural Invariants (Enforced in `tests/test_3d_models.py`):**
   - **Minimum Wall Thickness (`>= 3.0mm`):** Tube walls (`3.2mm`), flange plates (`5.0mm` single / `10.0mm` mated), and control box walls (`4.0mm`) resist Norway rat (*Rattus norvegicus*) gnawing.
   - **Shielded Telescoping Spigot Seams:** Each tube joint telescopes a `9.5mm` male spigot into a `10.0mm` female socket with a `45°` internal transition, leaving zero exposed flange seams inside the `95.2mm` tunnel for incisors to purchase.
   - **Anti-Tamper Bait Port:** Steps down from `36mm` outer bore to a `25mm` inner teardrop bore so the bayonet cap cannot be pushed out from inside the tunnel.
   - **Enclosed External Cable Conduit:** All sensor wiring runs inside the `12mm` OD / `8mm` ID external top conduit (`Y = +56.5mm`), leaving zero exposed wiring inside the rodent tunnel.

## 3D Model Priority

1. **Control Box Enclosure** - Most critical, defines everything else
2. **SSR Mount** - Must fit with heatsink in enclosure
3. **Feather Mount** - Precise hole spacing required
4. **Sensor Mounts** - STEMMA QT standard (reusable)
5. **Display Bezel** - Front panel integration
6. **Camera Mount** - Optional but important for camera variant

---

**Document Status:** Complete
**Source:** Manufacturer datasheets and Adafruit product pages
**Last Updated:** 2024-11-23
