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

#### Adafruit BME280 Environmental (4816)
- **PCB:** 17.78mm × 25.4mm (STEMMA QT standard)
- **Mounting Holes:** 4× M2.5
- **STEMMA QT:** Side-mounted
- **Sensor:** Top surface, needs airflow
- **3D Model Impact:** Standard mount with ventilation

### Camera System (Optional)

#### Adafruit OV5640 Camera (5945)
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

## Summary Table

| Component | Key Dimension | Mounting | Notes |
|-----------|--------------|----------|-------|
| Panasonic SSR | 40×58×25.5mm | Panel screws | Needs heatsink |
| Hammond Enclosure | 200×120×75mm ext | Wall mount | 192×112×69mm usable |
| Schneider E-stop | 16mm cutout | Snap-in | 32mm mushroom |
| ESP32 Feather | 50.8×22.9mm | M2.5, 4 holes | 5mm standoffs |
| STEMMA QT Sensors | 17.78×25.4mm | M2.5, 4 holes | Standard |
| PIR Sensor | 32×24mm | M3, 2 holes | Dome clearance |
| OLED Display | 27×27.5mm | M2.5, 2 holes | Front mount |
| OV5640 Camera | 32×32mm | M2.5, 4 holes | Lens clearance |
| Arcade Button | 60mm face | 24mm cutout | Snap-in |

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
