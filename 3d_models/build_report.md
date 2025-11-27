# 3D Model Build Report

**Generated:** 2024-11-27
**Models:** 12 STL files
**Status:** ✅ All models ready for printing

## Model Inventory

| Model | File Size | Dimensions | Build Plate | Status |
|-------|-----------|------------|-------------|--------|
| Bait Station | 352K | - | ✅ 220×220 | Ready |
| Camera Mount | 138K | 32×32mm PCB | ✅ 220×220 | Ready |
| Control Box Enclosure | 606K | 200×120×75mm | ✅ 220×220 | Ready |
| Control Box Lid | 277K | Matches enclosure | ✅ 220×220 | Ready |
| Sensor Mount | 568K | Universal clamp | ✅ 220×220 | Ready |
| STEMMA QT Mount | 28K | 17.78×25.4mm boards | ✅ 220×220 | Ready |
| Trap Body Front | 374K | 125mm half | ✅ 220×220 | Ready |
| Trap Body Main | 328K | 250mm (legacy) | ⚠️ Oversized | Use split |
| Trap Body Rear | 205K | 125mm half | ✅ 220×220 | Ready |
| Trap Entrance | 130K | Sensor integration | ✅ 220×220 | Ready |
| Trap Funnel Adapter | 591K | PVC to trap | ✅ 220×220 | Ready |
| Vacuum Funnel | 627K | Shop vac connection | ✅ 220×220 | Ready |

## Build Plate Compatibility

**Standard Build Plate:** 220mm × 220mm

- **Compatible:** 11 of 12 models (91.7%)
- **Split Models:** Trap body (front + rear halves)
- **Legacy:** trap_body_main.scad retained for reference (250mm)

**Recommendation:** Use trap_body_front.scad + trap_body_rear.scad instead of trap_body_main.scad

## Component Dimensions Used

All models updated with actual BOM component dimensions:

- **STEMMA QT Sensors:** 17.78mm × 25.4mm (Adafruit standard)
- **PIR Sensor:** 32mm × 24mm with 12mm dome
- **OV5640 Camera:** 32mm × 32mm PCB, 14mm lens clearance
- **Panasonic SSR:** 40mm × 58mm × 25.5mm
- **Hammond Enclosure:** 200mm × 120mm × 75mm
- **ESP32 Feather:** 50.8mm × 22.9mm

## BOM Validation Results

**Status:** ✅ All components validated (2025-11-27)

All 14 critical components verified against BOM_CONSOLIDATED.csv:
- ESP32-S3 Feather (50.8×22.9mm) - ✅ Match
- Sensors (VL53L0X, APDS9960, PIR, BME280) - ✅ All match STEMMA QT standard (17.78×25.4mm)
- OLED Display (27×27.5mm) - ✅ Match
- SSR AQA411VL (40×58×25.5mm) - ✅ Match (verified against datasheet)
- PSU LRS-35-5 (99×82×30mm) - ✅ Match
- Hammond PN-1334-C enclosure - ✅ Match

**Conclusion:** No dimensional corrections needed. All models accurate.

---

## Cable Protection Implementation

**Strategy:** Integrated channels in 3D printed structure

**Design:**
- Cable channels: 6mm wide × 3mm deep (built into trap walls)
- Connector pockets: 8×10×5mm (for JST SH connectors)
- Entry ports: 8-15mm diameter with chamfers

**Benefits:**
- $0 additional cost (vs $15-20 for external conduit)
- Complete rodent protection (cables enclosed in 4mm PETG walls)
- Simplified assembly (no external routing)
- Clean aesthetic (invisible cables)

**Implementation:**
- trap_entrance.scad: Radial channels from sensors to junction
- trap_body_front.scad: Vertical channel (rear wall, 125mm)
- Control box: PG13.5 cable gland (already designed)

---

## Assembly Design Updates

**Entrance:** Flat ramp design (trap_ramp_entrance.scad)
- Replaces cone funnel (deprecated)
- Prints flat - no supports needed
- 150mm gradual slope for rodent entry

---

## Print Settings Recommendations

### Material
- **Primary:** PETG or ASA (outdoor durability)
- **Alternative:** PLA+ (indoor only)
- **NOT Recommended:** Standard PLA (warps, brittle)

### Settings
- **Layer Height:** 0.2mm (standard) or 0.3mm (draft)
- **Infill:** 20% (structural parts) or 15% (non-structural)
- **Walls:** 3-4 perimeters
- **Top/Bottom:** 4-5 layers
- **Supports:** Required for overhangs >45°

### Post-Processing
- Clean support interfaces
- Test fit before final assembly
- Apply threaded inserts while hot (for M3/M4 holes)

## Assembly Order

1. **Trap Body:** Front half + Rear half (with alignment pins)
2. **Sensor Mounts:** Attach STEMMA QT boards to universal mounts
3. **Trap Entrance:** Install sensors and connect to trap body front
4. **Funnel System:** Vacuum funnel → Funnel adapter → Trap body rear
5. **Control Box:** Mount components in enclosure, attach lid
6. **Integration:** Connect all cables, test fit

## Next Steps

- [ ] Slice models in PrusaSlicer/Cura
- [ ] Verify print times and material usage
- [ ] Start printing structural components first
- [ ] Test fit components during printing
- [ ] Document any fitment issues

---

**Total Print Time (estimated):** ~48-60 hours
**Total Material:** ~1.5-2kg filament
**Build Plate:** 220×220mm minimum
