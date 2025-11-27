# Supplier Consolidation Documentation

## Overview

This document details the consolidation of component suppliers to primarily use **Adafruit** as the international vendor, with specific rationale for each component category.

## Consolidation Strategy

### Primary Vendor: Adafruit Industries

**Rationale:**
- ✅ International shipping to 150+ countries
- ✅ Complete STEMMA QT ecosystem (zero-solder assembly)
- ✅ Consistent quality and documentation
- ✅ Single-source procurement reduces shipping costs
- ✅ Excellent technical support and community
- ✅ Educational focus with detailed tutorials

### Secondary Sources

**Power & Safety Components:**
- Amazon (global availability)
- AliExpress (international, budget option)
- Local electrical suppliers (for AC components)

**Rationale:** Adafruit does not manufacture high-power AC switching components or industrial safety equipment.

---

## Component-by-Component Analysis

### 1. Microcontroller & Core Electronics

| Component | Previous Source | New Source | Part Number | Reason |
|-----------|----------------|------------|-------------|---------|
| ESP32-S3 Feather | Adafruit | **Adafruit** | 5323 | No change - perfect fit |
| Feather Headers | Adafruit | **Adafruit** | 2830 | No change |

**Status:** ✅ No change required

---

### 2. Sensors (STEMMA QT Ecosystem)

| Component | Previous Source | New Source | Part Number | Reason |
|-----------|----------------|------------|-------------|---------|
| VL53L0X ToF | Adafruit/Mouser | **Adafruit** | 3317 | STEMMA QT, direct source |
| APDS9960 | Adafruit/Mouser | **Adafruit** | 3595 | STEMMA QT, direct source |
| PIR Motion | Adafruit | **Adafruit** | 4871 | STEMMA connector |
| BME280 Env | Adafruit/Mouser | **Adafruit** | 4816 | STEMMA QT |
| STEMMA QT Hub | Adafruit/Mouser | **Adafruit** | 5625 | Direct source |

**Status:** ✅ All consolidated to Adafruit
**Benefit:** Guaranteed STEMMA QT compatibility, no adapter boards needed

---

### 3. Display & User Interface

| Component | Previous Source | New Source | Part Number | Reason |
|-----------|----------------|------------|-------------|---------|
| OLED 128x64 | Adafruit/Mouser | **Adafruit** | 326 | STEMMA QT |
| Arcade Button 60mm | Adafruit | **Adafruit** | 368 | Direct source |

**Status:** ✅ No change required

---

### 4. Camera System (Optional)

| Component | Previous Source | New Source | Part Number | Reason |
|-----------|----------------|------------|-------------|---------|
| OV5640 5MP Camera | Adafruit | **Adafruit** | 5945 | STEMMA QT, 5MP |
| IR LED High-Power | Adafruit | **Adafruit** | 5639 | STEMMA JST PH |
| MicroSD 8GB | Adafruit | **Adafruit** | 1833 | Standard component |

**Status:** ✅ No change required

---

### 5. Cables & Interconnects

| Component | Previous Source | New Source | Part Number | Reason |
|-----------|----------------|------------|-------------|---------|
| STEMMA QT 500mm | Adafruit/Mouser | **Adafruit** | 4401 | Direct source |
| STEMMA QT 100mm | Adafruit/Mouser | **Adafruit** | 4397 | Direct source |
| STEMMA QT 50mm | Adafruit/Mouser | **Adafruit** | 4399 | Direct source |
| STEMMA JST 200mm | Adafruit/Mouser | **Adafruit** | 3893 | For IR LED |
| Wire 26AWG Red | Adafruit/Mouser | **Adafruit** | 1877 | Silicone cover |
| Wire 26AWG Black | Adafruit/Mouser | **Adafruit** | 1881 | Silicone cover |

**Status:** ✅ All consolidated to Adafruit

---

### 6. Power Supply ⚠️ CRITICAL COMPONENT

| Component | Previous Source | New Source | Part Number | Reason |
|-----------|----------------|------------|-------------|---------|
| 5V 7A PSU | Mean Well (Mouser) | **Amazon/Local** | Mean Well LRS-50-5 | Not available Adafruit |

**Previous:** Mean Well LRS-35-5 (5V/7A) - $11.80 Mouser
**New:** Mean Well LRS-50-5 (5V/10A) - $15-20 Amazon

**Rationale:**
- Mean Well is industry-standard, UL/CE certified
- Available internationally via Amazon, AliExpress
- LRS-50-5 provides more headroom (10A vs 7A)
- Camera variant peaks at ~4A, 10A provides safety margin
- Local electrical suppliers may stock Mean Well

**Specifications Required:**
- Output: 5V DC, 10A minimum
- Input: 100-240V AC (universal)
- Certifications: UL/CE/TUV
- Protection: OVP, OCP, SCP
- Mounting: Chassis/PCB mount

**Alternative Sources:**
- Amazon: $15-20 (global shipping)
- AliExpress: $12-18 (longer shipping)
- Mouser: $13-16 (limited international)
- Local: Varies by region

---

### 7. Solid State Relay (SSR) 🔴 MOST CRITICAL COMPONENT

| Component | Previous Source | New Source | Part Number | Reason |
|-----------|----------------|------------|-------------|---------|
| SSR 25A | Panasonic (Mouser) | **See Options Below** | Multiple | Critical safety analysis |

#### SSR Requirements Analysis

**Load Requirements:**
- Shop vacuum: typically 8-12A at 120V (up to 15A surge)
- Continuous rating needed: 12A minimum (15A preferred)
- Surge rating: 20A+ recommended
- Operating voltage: 120V AC or 230V AC
- Control voltage: 3.3V DC (ESP32 output)

**Safety Requirements:**
- Zero-cross switching (reduce EMI)
- Optical isolation >2500V
- Thermal management (heatsink required for bare SSRs)
- UL/CE certification preferred
- Failure mode: Open (safe)

#### SSR Option 1: Adafruit IoT Power Relay (2935) ⭐ RECOMMENDED for North America

**Specifications:**
- **Part:** Adafruit 2935 - $29.95
- **Rating:** 30A/40A relay with 12A thermal breaker
- **Control:** 3-60V DC or 12-120V AC input
- **Protection:** Built-in thermal breaker, MOV surge protection
- **Housing:** Fully enclosed with 4 outlets
- **Input:** C13 detachable cord
- **Output:** 1× always-on, 1× normally-on, 2× normally-off outlets
- **Isolation:** Optical isolator built-in
- **Dimensions:** 170mm × 95mm × 35mm

**Advantages:**
- ✅ Complete solution (no external wiring needed)
- ✅ Thermal breaker prevents overload (12A continuous safe)
- ✅ Zero-cross switching built-in
- ✅ No heatsink required (fully enclosed)
- ✅ Direct from Adafruit
- ✅ Multiple outlets (can power display, etc.)
- ✅ Over 400,000 operation lifespan at 12A

**Limitations:**
- ❌ 120V only (not suitable for 230V regions)
- ❌ 12A thermal limit (adequate but not excessive margin)
- ❌ Larger footprint (170mm × 95mm)
- ❌ Higher cost than bare SSR

**Use Case:** Ideal for North American builds where simplicity and safety are paramount

**Note:** The 12A thermal breaker provides protection but means vacuum must draw <12A continuously

---

#### SSR Option 2: Fotek SSR-25 DA (Amazon/AliExpress) ⭐ RECOMMENDED for International

**Specifications:**
- **Rating:** 25A @ 24-380V AC (universal voltage)
- **Control:** 3-32V DC input (3.3V compatible)
- **Brand:** Fotek (Taiwan) or equivalent
- **Price:** $8-12 (Amazon/AliExpress)
- **Mounting:** DIN rail or chassis
- **Dimensions:** 60mm × 45mm × 30mm (bare SSR)

**Advantages:**
- ✅ Universal voltage (works 120V and 230V globally)
- ✅ Higher current rating (25A continuous)
- ✅ Widely available internationally
- ✅ Low cost
- ✅ Compact size
- ✅ Works with 3.3V ESP32 directly

**Requirements:**
- ⚠️ **Requires heatsink** (critical for >10A loads!)
- ⚠️ Requires snubber circuit (RC network across AC terminals)
- ⚠️ Quality varies (buy from reputable seller, check reviews)
- ⚠️ Must verify optical isolation rating
- ⚠️ Requires proper AC wiring (user responsibility)

**Heatsink Required:**
- Thermal resistance: <2°C/W
- Size: minimum 100mm × 50mm aluminum
- Mounting: Thermal paste required
- Thermal management critical above 10A
- Example: Generic aluminum heatsink ~$5

**Snubber Circuit:**
- 0.1µF 250V capacitor + 47Ω 1/2W resistor in series
- Connect across output terminals (AC side)
- Reduces inductive kickback from motor loads

**Use Case:** International builds, 230V regions, budget-conscious, DIY-comfortable users

---

#### SSR Option 3: Omron G3NA-210B (Mouser/DigiKey) - Premium Option

**Specifications:**
- **Rating:** 10A @ 24-240V AC
- **Control:** 5-24V DC (requires 5V, not 3.3V)
- **Brand:** Omron (Japan) - Industry gold standard
- **Price:** $15-20 (Mouser)
- **Certifications:** UL, CE, CSA certified

**Advantages:**
- ✅ Highest quality and reliability
- ✅ Excellent documentation and support
- ✅ Zero-cross switching built-in
- ✅ Built-in LED indicator
- ✅ Long lifespan (100M+ operations)
- ✅ Universal voltage (120V/230V)

**Limitations:**
- ❌ 10A continuous rating (marginal for some vacuums)
- ❌ Requires 5V control signal (need voltage level shifter or use 5V pin)
- ❌ Higher cost than generic options
- ❌ Still requires heatsink for continuous high loads

**Use Case:** Commercial/professional builds requiring maximum reliability, certified components

---

#### Recommended SSR Configuration by Region

**North America (120V):**
- Primary: **Adafruit IoT Power Relay (2935)** - $29.95
  - Complete plug-and-play solution
  - Adequate for most shop vacuums <12A
- Alternative: Fotek SSR-25 DA + heatsink - $15-20 total
  - For higher power vacuums or budget builds

**Europe/Asia (230V):**
- Primary: **Fotek SSR-25 DA** with heatsink - $15-20 total
  - Only practical option for 230V
  - Ensure proper heatsink and thermal management
- Alternative: Omron G3NA-210B (if 10A sufficient) - $15-20

**Universal/International Build:**
- Use **Fotek SSR-25 DA** (24-380V AC rated)
- Include proper heatsink and thermal paste
- Add RC snubber circuit for motor protection
- Document thermal management requirements

---

#### Important Safety Notes for SSRs

1. **Heatsink is NOT optional** for bare SSRs at >5A loads
2. **Thermal runaway** can occur without adequate cooling
3. **Verify isolation voltage** - minimum 2500V for safety
4. **Test under load** before final installation
5. **Monitor temperature** during initial testing
6. **Use thermal paste** between SSR and heatsink
7. **Ensure airflow** in enclosure if using bare SSR

---

#### 3D Model Impact: SSR Mounting

**Adafruit IoT Power Relay (2935):**
- Dimensions: 170mm × 95mm × 35mm
- Mounting: **External to main enclosure** (has own case)
- 3D Model: Not required (complete unit)
- Installation: Plug into wall, control via 3-wire connection
- Enclosure Impact: Needs 3-wire pass-through only

**Fotek SSR-25 DA + Heatsink:**
- SSR: 60mm × 45mm × 30mm
- Heatsink adds: ~50-60mm height total
- Total footprint: ~100mm × 50mm × 80-90mm
- Mounting: Direct to enclosure back panel
- 3D Model: **Requires SSR mount bracket with heatsink provision**
- Enclosure Impact: Must accommodate heatsink inside

**Design Decision:**
- Create modular SSR mount design
- Support both IoT Power Relay (external) and Fotek (internal)
- Ensure adequate ventilation for heatsink variant


---

#### SSR Option 2: Fotek SSR-25 DA (Amazon/AliExpress)

**Specifications:**
- **Rating:** 25A @ 24-380V AC
- **Control:** 3-32V DC input (compatible with 3.3V)
- **Brand:** Fotek (Taiwan) or equivalent
- **Price:** $8-12 (Amazon/AliExpress)
- **Mounting:** DIN rail or chassis

**Advantages:**
- ✅ Universal voltage (works 120V and 230V)
- ✅ Higher current rating (25A)
- ✅ Widely available internationally
- ✅ Low cost
- ✅ Standard DIN rail mounting

**Requirements:**
- ⚠️ Requires heatsink (critical!)
- ⚠️ Requires snubber circuit (RC network)
- ⚠️ Quality varies (buy from reputable seller)
- ⚠️ Must verify optical isolation

**Heatsink Required:**
- Thermal resistance: <2°C/W
- Size: minimum 100x50mm aluminum
- Mounting: Thermal paste required
- Example: Adafruit 3083 ($4.95) or equivalent

**Use Case:** International builds, higher power requirements

---

#### SSR Option 3: Omron G3NA-420B (Mouser/DigiKey)

**Specifications:**
- **Rating:** 20A @ 24-240V AC
- **Control:** 5-24V DC (use 5V, not 3.3V directly)
- **Brand:** Omron (Japan) - Industry standard
- **Price:** $18-25 (Mouser)
- **Certifications:** UL, CE, CSA

**Advantages:**
- ✅ Highest quality and reliability
- ✅ Excellent documentation
- ✅ Zero-cross switching
- ✅ Built-in LED indicator
- ✅ Long lifespan (100M+ operations)

**Requirements:**
- ⚠️ Requires 5V control (add voltage divider or use 5V pin)
- ⚠️ Higher cost
- ⚠️ Requires heatsink for >10A

**Use Case:** Commercial/professional builds, maximum reliability

---

#### Recommended SSR Configuration by Region

**North America (120V):**
- Primary: **Adafruit PowerSwitch Tail II** (268) - $24.95
- Alternative: Fotek SSR-25 DA - $8-12

**Europe/Asia (230V):**
- Primary: **Fotek SSR-25 DA** with heatsink - $15-20 total
- Alternative: Omron G3NA-420B - $18-25

**Universal Build:**
- Use **Fotek SSR-25 DA** (24-380V AC rated)
- Include proper heatsink and thermal management
- Add RC snubber circuit

---

#### 3D Model Impact: SSR Mounting

**PowerSwitch Tail II:**
- Dimensions: 70mm × 55mm × 35mm
- Mounting: External to enclosure (has own case)
- 3D Model: External bracket/holder

**Fotek SSR-25 DA:**
- Dimensions: 60mm × 45mm × 30mm (SSR only)
- Heatsink adds: +50mm height
- Mounting: DIN rail or direct to enclosure back panel
- 3D Model: Internal enclosure mount with heatsink space

**Design Decision:** Create modular SSR mount that supports both types

---

### 8. AC Power Connectors

| Component | Previous Source | New Source | Part Number | Reason |
|-----------|----------------|------------|-------------|---------|
| IEC C14 Inlet | Schurter (Mouser) | **Amazon/Local** | Generic w/switch | Not available Adafruit |
| IEC C13 Outlet | Schurter (Mouser) | **Amazon/Local** | Generic panel mount | Not available Adafruit |

**Rationale:**
- Standard IEC connectors universally available
- Amazon carries international variants
- Local electrical suppliers stock these
- Region-specific options (NEMA, Schuko, etc.)

**Specifications:**
- Rating: 15A minimum @ 250V AC
- Features: Integral switch and fuse for inlet
- Mounting: Panel mount, snap-in preferred

---

### 9. Emergency Stop & Safety

| Component | Previous Source | New Source | Part Number | Reason |
|-----------|----------------|------------|-------------|---------|
| E-Stop Switch | Schneider (Mouser) | **Amazon/Local** | 16mm mushroom | Not available Adafruit |

**Previous:** Schneider XB6ETN521P - $22.13
**New:** Generic 16mm E-stop - $5-8

**Rationale:**
- Emergency stops are commodity items
- Local industrial suppliers stock these
- Amazon has numerous compliant options
- Must meet: latching, NC contacts, red mushroom

**Specifications:**
- Type: Latching mushroom
- Contacts: 1× NC (normally closed)
- Mounting: 16mm panel hole
- Color: Red with yellow background
- Standards: IEC 60947-5-5 or equivalent

---

### 10. Project Enclosure

| Component | Previous Source | New Source | Part Number | Reason |
|-----------|----------------|------------|-------------|---------|
| Enclosure | Hammond (Mouser) | **Amazon/Local** | 200×120×75mm ABS | Not available Adafruit |

**Previous:** Hammond PN-1334-C (8"×6"×4") - $16.20
**New:** Generic ABS project box - $10-15

**Rationale:**
- Standard sizes available globally
- Amazon, AliExpress stock extensively
- Local electronics stores carry these
- 3D models can adapt to standard sizes

**Specifications:**
- Minimum interior: 194mm × 114mm × 69mm
- Material: ABS plastic
- Features: Removable lid, mounting bosses
- Color: Gray or white preferred

---

### 11. Terminal Blocks & Connectors

| Component | Previous Source | New Source | Part Number | Reason |
|-----------|----------------|------------|-------------|---------|
| Terminal Blocks | Mouser | **Adafruit** | 724 | Available at Adafruit! |

**Adafruit 724:** 2.54mm pitch screw terminal block kit - $7.50

**Rationale:**
- Adafruit sells terminal block kits
- Perfect for low-voltage DC connections
- Alternative: Local suppliers for AC terminals

---

## Summary of Changes

### Fully Consolidated to Adafruit (17 items)
- ESP32-S3 Feather + headers
- All sensors (VL53L0X, APDS9960, PIR, BME280)
- OLED display
- STEMMA QT hub and all cables
- Camera system (OV5640 + IR LED)
- Arcade button
- Wire and terminal blocks

**Adafruit Total:** ~$113

### Alternative Sources Required (6 items)
- Power supply (Mean Well LRS-50-5) - Amazon/local - $15-20
- SSR (PowerSwitch Tail II or Fotek) - Adafruit or Amazon - $8-25
- IEC connectors (inlet + outlet) - Amazon/local - $5-8
- Emergency stop switch - Amazon/local - $5-8
- Project enclosure - Amazon/local - $10-15
- Heatsink & thermal paste (if using Fotek SSR) - $5-8

**Alternative Sources Total:** ~$48-84

### Grand Total: $161-197

**Cost Comparison:**
- Previous (multi-vendor): ~$150-170
- New (Adafruit focused): ~$161-197
- Increase: ~$11-27 (7-16%)

**Benefits:**
- Single main order (Adafruit)
- International shipping simplified
- Better component compatibility
- Improved documentation
- No-solder assembly throughout

---

## Regional Sourcing Guide

### North America
- **Primary:** Adafruit (USA shipping)
- **Power/Safety:** Amazon.com
- **Local:** Home Depot, Lowe's (AC components)

### Europe
- **Primary:** Adafruit (ships to EU)
- **Power/Safety:** Amazon.de/.uk/.fr
- **Local:** Conrad Electronics, RS Components

### Asia/Pacific
- **Primary:** Adafruit (international shipping)
- **Power/Safety:** AliExpress (budget) or local distributors
- **Local:** Tokopedia, Lazada, regional electronics markets

### Australia/NZ
- **Primary:** Adafruit or local Adafruit distributors
- **Power/Safety:** AliExpress or Jaycar Electronics
- **Local:** Element14, Altronics

---

## Procurement Workflow

### Step 1: Adafruit Order
1. Go to adafruit.com
2. Add all electronic components (17 items)
3. Select international shipping to your region
4. Expect delivery: 1-3 weeks international

### Step 2: Power & Safety Components
1. Check Amazon in your region
2. Order PSU, SSR, connectors, enclosure
3. Verify AC voltage compatibility (120V vs 230V)
4. Expect delivery: 1-2 weeks

### Step 3: Local Components (Optional)
1. Visit local electrical/industrial supplier
2. Purchase E-stop, connectors, wire as needed
3. Immediate availability

**Total Procurement Time:** 2-4 weeks including international shipping

---

## Bill of Materials Files

### Updated Files
- `BOM_CONSOLIDATED.csv` - Full list with Adafruit part numbers
- `BOM_ADAFRUIT_ONLY.csv` - Adafruit order list
- `BOM_AMAZON_SUPPLEMENTS.csv` - Power/safety components
- `SUPPLIER_CHANGES.md` - This document

### BOM Manager Compatibility
The existing BOM manager scripts will be updated to:
- Prioritize Adafruit part numbers
- Flag non-Adafruit components
- Generate region-specific sourcing guides
- Validate international availability

---

## Next Steps

1. **Update BOM_CONSOLIDATED.csv** with new part numbers
2. **Test Adafruit shopping cart** to verify availability
3. **Update 3D models** for actual component dimensions
4. **Create SSR mount** supporting both PowerSwitch Tail and Fotek
5. **Update documentation** with sourcing links

---

**Document Version:** 1.0
**Last Updated:** 2024-11-23
**Status:** Ready for implementation
