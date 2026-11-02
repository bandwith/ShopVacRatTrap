> **⚠️ Work in Progress ⚠️**
>
> This project is under active development. The documentation, features, and hardware recommendations are subject to change. Please check back for updates.

# Component Sourcing Guide - ShopVac Rat Trap

<a id="automated-bom-management"></a>

## Adafruit Components
| Qty | Part Number | Description | Price | Link |
|-----|------------|-------------|-------|------|
| 1 | 5323 | ESP32-S3 Feather with 8MB Flash No PSRAM | $17.50 | [Buy](https://www.adafruit.com/product/5323) |
| 1 | 2830 | Feather Stacking Headers - 12-pin and 16-pin | $1.25 | [Buy](https://www.adafruit.com/product/2830) |
| 1 | 5946 | OV5640 5MP Camera 120° Autofocus (DVP Variant) | $19.95 | [Buy](https://www.adafruit.com/product/5946) |
| 1 | 5639 | High-Power IR LED - STEMMA JST PH 2mm | $3.95 | [Buy](https://www.adafruit.com/product/5639) |
| 1 | 5425 | VL53L4CX Time of Flight Distance Sensor - STEMMA QT | $14.95 | [Buy](https://www.adafruit.com/product/5425) |
| 1 | 6426 | STHS34PF80 IR Temperature & Presence Sensor - STEMMA QT | $14.95 | [Buy](https://www.adafruit.com/product/6426) |
| 1 | 3595 | APDS9960 Proximity, Light, RGB, and Gesture Sensor - STEMMA QT | $7.50 | [Buy](https://www.adafruit.com/product/3595) |
| 1 | 4438 | LSM6DSOX 6-DoF Accelerometer & Gyroscope - STEMMA QT | $11.95 | [Buy](https://www.adafruit.com/product/4438) |
| 1 | 3421 | I2S MEMS Microphone Breakout - SPH0645LM4H | $6.95 | [Buy](https://www.adafruit.com/product/3421) |
| 1 | 2652 | BME280 Temperature Humidity Pressure Sensor - STEMMA QT | $14.95 | [Buy](https://www.adafruit.com/product/2652) |
| 1 | 326 | Monochrome 0.96" 128x64 OLED Display - STEMMA QT | $17.50 | [Buy](https://www.adafruit.com/product/326) |
| 1 | 5625 | STEMMA QT / Qwiic 5-Port Hub | $2.50 | [Buy](https://www.adafruit.com/product/5625) |
| 3 | 4210 | STEMMA QT / Qwiic JST SH 4-pin Cable - 100mm Long | $0.95 | [Buy](https://www.adafruit.com/product/4210) |
| 1 | 3893 | STEMMA JST PH 2mm 3-Pin to Male Header Cable - 200mm | $1.25 | [Buy](https://www.adafruit.com/product/3893) |
| 1 | 471 | Arcade Button - 30mm Translucent Red | $5.95 | [Buy](https://www.adafruit.com/product/471) |
| 1 | 1877 | Silicone Cover Stranded-Core Wire - 2m 26AWG Red | $0.95 | [Buy](https://www.adafruit.com/product/1877) |
| 1 | 1881 | Silicone Cover Stranded-Core Wire - 2m 26AWG Black | $0.95 | [Buy](https://www.adafruit.com/product/1881) |
| 1 | 1833 | Micro SD Card 8GB Class 10 | $1.95 | [Buy](https://www.adafruit.com/product/1833) |

## Mouser & Distributor Sourced Components
| Qty | Part Number | Description | Price | Link |
|-----|------------|-------------|-------|------|
| 1 | 101021112 | Seeed Studio Grove Vision AI Module V2 (Mouser 713-101021112) | $19.99 | [Buy](https://www.mouser.com/ProductDetail/713-101021112) |
| 1 | LRS-35-5 | Mean Well 5V 7A Chassis Mount Switching Power Supply | $12.20 | [Buy](https://www.mouser.com/ProductDetail/709-LRS35-5) |
| 1 | AQA411VL | Panasonic 25A Solid State Relay (Mouser 769-AQA411VL) | $21.76 | [Buy](https://www.mouser.com/ProductDetail/769-AQA411VL) |
| 1 | HSP-7 | Crydom Thermal Pad for SSR (Mouser 558-HSP-7) | $1.65 | [Buy](https://www.mouser.com/ProductDetail/558-HSP-7) |
| 1 | 4N35-X007 | Vishay Optocoupler (Mouser 782-4N35-X007) | $0.79 | [Buy](https://www.mouser.com/ProductDetail/782-4N35-X007) |
| 1 | XB6ETN521P | Schneider Electric 16mm Red E-Stop Switch | $18.83 | [Buy](https://www.mouser.com/ProductDetail/996-XB6ETN521P) |
| 1 | TBC05-02-1-G-G | GCT 2.54mm Pitch PCB Terminal Block | $0.79 | [Buy](https://www.mouser.com/ProductDetail/640-TBC05-02-1-G-G) |
| 1 | PCS020-EE0502KS | Bourns 20A Split Core Current Transformer | $4.34 | [Buy](https://www.mouser.com/ProductDetail/652-PCS020-EE0502KS) |
| 1 | DF11.2078.0010.01 | Schurter IEC C14 Inlet with Integrated Circuit Breaker & Switch | $44.44 | [Buy](https://www.mouser.com/ProductDetail/693-DF112078001001) |
| 1 | 6600.3100 | Schurter Panel Mount IEC C13 Outlet | $2.22 | [Buy](https://www.mouser.com/ProductDetail/693-6600.3100) |

## 🚀 Quick Purchase Options

**UPDATED (August 2025)**: Automated purchase files using integrated BOM manager:

- **Setup**: First activate the virtual environment: `source .venv/bin/activate`
- **Run**: `python3 .github/scripts/bom_manager.py --bom-file BOM_CONSOLIDATED.csv --generate-purchase-files`
- **Files Created**:
  - `BOM_MOUSER_TEMPLATE.xlsx` - **Official Mouser template format (RECOMMENDED)**
  - `BOM_MOUSER_TEMPLATE.csv` - CSV version for review
  - `BOM_MOUSER_ONLY.csv` - Mouser-only consolidated BOM
  - `mouser_upload_consolidated_only.csv` - Simple upload format for compatibility
  - `PURCHASE_GUIDE.md` - Comprehensive purchase instructions

**Benefits of New System**:
- ✅ **Real-time pricing** via Mouser API
- ✅ **Dynamic part lookup** (no hardcoded mappings)
- ✅ **Official Mouser template format** for direct upload
- ✅ **Complete component data** (availability, datasheets, lifecycle)
- ✅ **Single command** replaces multiple shell scripts

**Requirements**: pandas and openpyxl (installed by `uv sync`)

**Bulk Ordering**: Upload BOM_MOUSER_TEMPLATE.xlsx to Mouser BOM tools for instant pricing and cart creation.

**Local Sourcing Note**: For certain common components like wire, terminal blocks, and some hardware, you may find more cost-effective options at local home improvement stores or general electronics retailers. However, ensure any locally sourced components meet the specified technical and safety requirements.

---

## Components and Hardware Options

### 1. Camera & Vision Intelligence Options

The system supports two distinct hardware vision architectures to balance simplicity, compute load, and data-logging depth:

#### Option A: Direct DVP Image Capture (High-Resolution Visual Confirmation)
* **Part**: Adafruit 5946 (120° autofocus) - [Adafruit 5946](https://www.adafruit.com/product/5946) / Mouser 485-5946 ($19.95)
* **Features**: 5MP OV5640 sensor, autofocus, 8-bit DVP parallel interface directly to ESP32-S3 PSRAM (`rat-trap.yaml`).
* **High-Power IR LED System**: Adafruit 5639 ($3.95) provides pulsed night-vision illumination.
* **Role**: High-resolution evidence capture dispatched directly to Home Assistant via MQTT/API.

#### Option B: Edge-AI Vision & Multi-Modal Data Logger (On-Device ML & Acoustic Logging)
* **Part**: Seeed Studio 101021112 (Grove Vision AI Module V2) - [Mouser 713-101021112](https://www.mouser.com/ProductDetail/713-101021112) ($19.99)
* **Features**: Himax WiseEye2 HX6538 processor (dual Arm Cortex-M55 cores + Arm Ethos-U55 NPU).
* **Onboard Telemetry & Logging**:
  * **Onboard Digital PDM Microphone**: Continuous acoustic rodent vocalization and squeak detection without taxing the host MCU.
  * **Onboard MicroSD Card Slot**: Stores local high-resolution event logs, raw images, and audio captures offline for remote or barn deployments.
  * **UART Telemetry Stream**: Connects to ESP32-S3 pins `GPIO16`/`GPIO17` (`rat-trap-stemma-camera.yaml` + `packages/camera.yaml`) transmitting real-time bounding boxes, rodent classifications, and confidence scores.

---

### 2. Time-of-Flight Sensor (Ranging Confirmation)
* **Primary**: VL53L4CX Time-of-Flight Distance Sensor - STEMMA QT
* **Adafruit 5425**: $14.95 - [Adafruit 5425](https://www.adafruit.com/product/5425) / Mouser 485-5425
* **Features**: Multi-target detection up to 6 meters, target distance filtering, and mm-accurate ranging inside the trap tube.

---

### 3. Thermal Presence & Motion Sensor
* **Primary**: STHS34PF80 IR Temperature & Presence Sensor - STEMMA QT
* **Adafruit 6426**: $14.95 - [Adafruit 6426](https://www.adafruit.com/product/6426) / Mouser 485-6426
* **Features**: High-sensitivity optical thermal thermopile detecting living rodent body heat and motion even in total darkness.

---

### 4. 6-DoF Vibration & Tamper Sensor
* **Primary**: LSM6DSOX 6-DoF Accelerometer and Gyroscope - STEMMA QT
* **Adafruit 4438**: $11.95 - [Adafruit 4438](https://www.adafruit.com/product/4438) / Mouser 485-4438
* **Features**: High-precision 6-axis inertial measurement unit detecting mechanical disturbance, gnawing, and rodent impact against the trap entrance.

---

### 5. Acoustic Detection & Environmental Telemetry
* **Acoustic Sensor**: Adafruit 3421 (SPH0645LM4H I2S MEMS Microphone) - $6.95 - [Adafruit 3421](https://www.adafruit.com/product/3421) / Mouser 485-3421
* **Environmental Sensor**: Adafruit 2652 (BME280 Temperature/Humidity/Pressure) - $14.95 - [Adafruit 2652](https://www.adafruit.com/product/2652) / Mouser 485-2652
* **Optical Proximity**: Adafruit 3595 (APDS9960 Proximity, Light, Gesture) - $7.50 - [Adafruit 3595](https://www.adafruit.com/product/3595) / Mouser 485-3595
**STEMMA QT upgrade alternatives** (keep zero-solder; need a one-line ESPHome
platform change):
- **BME680/BME688** (Adafruit 3660 / 5046) — adds VOC gas sensing (`bme680`).
- **BMP390** (Adafruit 4494) — better pressure, but no humidity (`bmp3xx`).
- **SHT41/SHT45** — best temp/humidity accuracy, cheap, no pressure (`sht4x`).
**SparkFun SEN-15440**: $19.95 - <https://www.sparkfun.com/products/15440>
**Note**: Only `env_temperature` is consumed by the firmware today, so any of
the above satisfy the project goal.

### 3. Power Supply
**Primary**: Mean Well LRS-35-5 (5V/7A)
**Mouser 709-LRS35-5**: $18.95 - <https://www.mouser.com/ProductDetail/709-LRS35-5>
**Digi-Key 1866-5012-ND**: $18.70
**Newark 85AC4189**: $19.25
**Alternative**: LRS-35-5 for higher capacity builds (7A vs 3A capacity)

### 4. Solid State Relay
**Primary**: Panasonic AQA411VL (25A, Panel Mount)
**Mouser 769-AQA411VL**: $25.61 - <https://www.mouser.com/ProductDetail/769-AQA411VL>
**Features**: 4-32V DC control, 25A @ 75-250V AC, LED indicator, zero-cross switching
**Alternative**: Sensata Crydom D2425-10 - $32.15
**Alternative**: Omron G3NA-210B-DC5-24 - $28.50
**⚠️ SAFETY CRITICAL**: Must be UL/CE listed for AC switching

### 5. Current Transformer
**Primary**: YHDC SCT-013-020 (20A, split-core)
**Amazon B07TXQBC1D**: $8.00 - <https://amazon.com/dp/B07TXQBC1D>
**AliExpress**: $5-8 (direct from YHDC)
**Alternative**: Magnelab SCT-0300-020 - $35 (US-made)
**Alternative**: CR Magnetics CR5220-20 - $32
**⚠️ SAFETY CRITICAL**: Verify 600V insulation rating

### 6. AC Inlets & Outlets
**AC Inlet (Primary)**: Schurter DF11.2078.0010.01 (IEC C14 with integrated TA45 circuit breaker & switch)
**Mouser 693-DF112078001001**: $44.44 - <https://www.mouser.com/ProductDetail/693-DF112078001001>
**Features**: Integrated rocker switch, overload thermal circuit breaker, IEC 60320 C14 standard.

**AC Outlet (Primary)**: Schurter 6600.3100 (IEC C13 Panel Mount Outlet)
**Mouser 693-6600.3100**: $2.22 - <https://www.mouser.com/ProductDetail/693-6600.3100>
**Features**: Snap-in/screw panel mount, 15A rating, mates with standard vacuum C14 plugs or C13/C14 appliance cords.

### 7. Controls & Terminal Blocks
**Arcade Button (Primary)**: Adafruit 471 (30mm Translucent Red Arcade Button)
**Mouser 485-471 / Adafruit 471**: $5.95 - <https://www.adafruit.com/product/471>
**Dimensions**: 30mm mounting hole diameter (replacing legacy 60mm button).

**Emergency Stop Switch (Primary)**: Schneider Electric XB6ETN521P (16mm Red E-Stop)
**Mouser 996-XB6ETN521P**: $18.83 - <https://www.mouser.com/ProductDetail/996-XB6ETN521P>
**Features**: Push-lock, turn-reset industrial safety rated switch.

**PCB Terminal Block (Primary)**: GCT TBC05-02-1-G-G (2.54mm Pitch)
**Mouser 640-TBC05-02-1-G-G**: $0.79 - <https://www.mouser.com/ProductDetail/640-TBC05-02-1-G-G>
**Features**: 2-position screw terminal block for robust signal interconnects.

### 9. STEMMA QT Cables & Accessories
**Primary**: STEMMA QT Cable - 100mm
**Adafruit 4397**: $0.95 - <https://www.adafruit.com/product/4397>
**Primary**: STEMMA JST PH Cable - 200mm
**Adafruit 3893**: $1.25 - <https://www.adafruit.com/product/3893>
**Alternative**: SparkFun Qwiic cables (compatible) - similar pricing
**Note**: Zero-solder modular connections throughout system

### 10. Micro SD Card (for camera storage)
**Primary**: SanDisk Ultra 8GB Class 10
**Adafruit 1833**: $9.95 - <https://www.adafruit.com/product/1833>
**Amazon**: $6-8 for equivalent Class 10 cards
**Alternative**: Higher capacity (16GB+) for extended storage
**Note**: Required for local image storage before Home Assistant upload

### 11. Heat Sink (Optional)
**Primary**: Wakefield-Vette 507-10ABPB (10x10mm)
**Mouser 532-507-10ABPB**: $3.15
**Digi-Key HS117-ND**: $3.25
**Alternative**: Aavid Thermalloy 531002B00000G - $2.85
**Alternative**: Generic TO-220 heat sinks - $1-2
**Note**: May not be required for ESP32 in this application

### 12. Thermal Interface Pad (Optional)
**Primary**: Bergquist SP400-0.010-00-1010 (0.010", 10x10mm)
**Mouser 539-SP400-010-001010**: $2.45
**Digi-Key BER157-ND**: $2.65
**Alternative**: 3M 8810 thermal pad - $2.20
**Alternative**: Generic thermal pads from Amazon - $0.50-1.00
**Note**: Only needed if heat sink is used

## Sourcing Strategy by Component Type

### STEMMA QT Camera System (NEW)
**Primary Sources**: Adafruit
**Requirements**: STEMMA QT connector compatibility, I2C interface
**Components**: OV5640 Camera, High-power IR LED, STEMMA cables, Micro SD card
**Budget**: ~$21 upgrade to standard configuration

### Safety-Critical Components (AC Power)
**Primary Sources**: Mouser, Digi-Key, Newark
**Requirements**: UL/CE listing mandatory
**Components**: PSU, SSR, Fuses, IEC inlet, NEMA outlet, Current transformer
**Budget**: ~75% of total project cost

### Development Modules (DC/Logic)
**Primary Sources**: Adafruit, SparkFun
**Secondary Sources**: Amazon, AliExpress
**Components**: ESP32, sensors, OLED display
**Budget**: ~20% of total project cost

### Mechanical/Hardware
**Primary Sources**: McMaster-Carr, Fastenal
**Secondary Sources**: Home Depot, Amazon
**Components**: Enclosure, mounting hardware, wire, terminals
**Budget**: ~5% of total project cost

## International Sourcing Notes

### 🇺🇸 North America
- **Primary**: Mouser, Digi-Key, Newark
- **Quick ship**: Adafruit, SparkFun
- **Local**: Home Depot, Lowe's (hardware)

### 🇪🇺 Europe
- **Primary**: RS Components, Farnell
- **Alternative**: Mouser Europe, Digi-Key Europe
- **Local**: Conrad, Reichelt (Germany)

### 🌏 Asia-Pacific
- **Primary**: Element14, RS Components
- **Local**: Digi-Key, local electronics distributors
- **Alternative**: AliExpress for non-safety components

## Bulk Pricing and Lead Times

### Bulk Pricing
- **10+ units**: 15-20% discount on major distributors
- **100+ units**: Contact distributors for volume pricing
- **1000+ units**: Direct manufacturer negotiations

### Lead Time Considerations
- **Standard components**: 1-2 weeks (Mouser/Digi-Key)
- **Specialty components**: 2-8 weeks (SSR, current transformer)
- **Generic alternatives**: 1-7 days (Amazon Prime)
- **International shipping**: Add 1-2 weeks



---

## Hybrid API Strategy (Nexar + Mouser)

### 🔄 **Intelligent API Selection**
The project now uses a **hybrid validation strategy** that automatically selects the best API for each situation:

**Primary Strategy: Nexar + Mouser Hybrid**
- ✅ **Nexar first** - comprehensive multi-supplier data
- 🛒 **Mouser fallback** - when Nexar quota exceeded
- 🔄 **Automatic switching** - no manual intervention required
- 📊 **Best of both worlds** - wide coverage + detailed pricing

**API Capabilities Comparison:**

| Feature | Nexar API | Mouser API | Hybrid Benefit |
|---------|-----------|------------|----------------|
| **Quota Limits** | 100 parts/day (free) | 1000 requests/hour | No validation failures |
| **Supplier Coverage** | Multi-supplier | Mouser only | Multi + single source |
| **Pricing Detail** | Basic median pricing | Detailed price breaks | Complete pricing data |
| **Availability** | General trends | Real-time stock | Accurate availability |
| **Lead Times** | Limited | Detailed | Comprehensive data |
| **Datasheets** | Sometimes | Always | Maximum coverage |

### 🚨 **Quota Management**
The GitHub Actions workflows now include intelligent quota management:

**Quota Exceeded Handling:**
- ✅ **Zero data loss** - automatic Mouser fallback
- 📊 **Prioritizes safety-critical components** first via Nexar
- 🏷️ **No workflow failures** due to quota limits
- 📈 **Detailed reporting** on API usage and fallback events

**Rate Limiting Protection:**
- ⏳ **Exponential backoff** with jitter (1s → 60s max delay)
- 🔄 **Automatic retries** (up to 5 attempts per component)
- 🐌 **Inter-request delays** (200ms between API calls)
- 💤 **Extended breaks** after consecutive failures

### 🔄 **Error Recovery Strategies**

| Error Type | Nexar Response | Mouser Fallback | Final Result |
|------------|----------------|-----------------|--------------|
| **Quota Exceeded** | Stop new requests | ✅ Continue validation | 100% coverage |
| **Rate Limited** | Exponential backoff | ✅ Switch to Mouser | No delays |
| **Network Timeout** | Retry 3x | ✅ Use Mouser | Reliable results |
| **Auth Failure** | Log & skip | ✅ Use Mouser | Graceful degradation |
| **Server Error (5xx)** | Backoff & retry | ✅ Use Mouser | High availability |

### 📊 **API Usage Optimization**

**Automatic Prioritization:**
- 🚨 **Safety-critical components** validated first (via Nexar for multi-supplier view)
- 📦 **Standard components** use best available API
- 🔄 **Quota-aware switching** to Mouser when needed
- 📈 **Cost-sensitive components** get detailed Mouser pricing

**Intelligent Caching:**
1. **Priority-based processing** - safety-critical components first
2. **Batch validation** - group similar components
3. **Smart fallback** - seamless API switching
4. **Detailed reporting** - track API usage and costs

### 🛠️ **Setup Instructions**

**Required API Keys:**
1. **Nexar API** (optional, but recommended):
   - Register at <https://nexar.com/api>
   - Get `NEXAR_CLIENT_ID` and `NEXAR_CLIENT_SECRET`
   - Free tier: 100 parts/day

2. **Mouser API** (recommended):
   - Register at <https://www.mouser.com/api-hub/>
   - Get `MOUSER_API_KEY`
   - Free tier: 1000 requests/hour

**GitHub Secrets Setup:**
```bash
# Add to repository secrets:
NEXAR_CLIENT_ID=your_nexar_client_id
NEXAR_CLIENT_SECRET=your_nexar_client_secret
MOUSER_API_KEY=your_mouser_api_key
```

### 🧪 **Local Testing & Development**

The consolidated BOM manager script supports **local testing** with automatic `.env` file loading:

**Setup for Local Testing:**
```bash
# 1. Copy the example environment file
cp .env.example .env

# 2. Edit .env with your API credentials
nano .env

# 3. Run the integrated BOM manager - it will automatically load .env
python3 .github/scripts/bom_manager.py --bom-file BOM_CONSOLIDATED.csv --validate
python3 .github/scripts/bom_manager.py --bom-file BOM_CONSOLIDATED.csv --check-availability
python3 .github/scripts/bom_manager.py --bom-file BOM_CONSOLIDATED.csv --generate-purchase-files

# 4. Or run everything at once
python3 .github/scripts/bom_manager.py --bom-file BOM_CONSOLIDATED.csv --all
```

**BOM Manager Script Features:**
- ✅ `--validate` - Real-time Mouser pricing validation
- ✅ `--check-availability` - Component availability checking
- ✅ `--generate-purchase-files` - Generate all purchase files and templates
- ✅ `--generate-mouser-template` - Official Mouser template format (RECOMMENDED)
- ✅ `--all` - Complete validation, pricing, and file generation
- ✅ `update-pricing` - Update BOM with current pricing
- ✅ `generate-reports` - Create summary reports

**Benefits of Local Testing:**
- 🔧 **No GitHub Actions consumption** - test scripts locally
- 🚀 **Faster iteration** - immediate feedback without CI/CD
- 🔍 **Debug mode available** - add print statements and breakpoints
- 📊 **Real API testing** - verify credentials and quotas before pushing

**Usage Examples:**
```bash
# Validate with hybrid APIs (recommended)
python .github/scripts/hybrid_bom_validator.py \
  --bom-files BOM_CONSOLIDATED.csv \
  --priority-components ESP32-S3-Feather COM-14456 LRS-35-5

# Mouser-only validation
NEXAR_CLIENT_ID="" python .github/scripts/hybrid_bom_validator.py \
  --bom-files BOM_CONSOLIDATED.csv

# Check API connectivity
curl -X GET "https://api.mouser.com/api/v1/search/partnumber?apiKey=YOUR_KEY&partnumber=ESP32-S3-Feather"
```

### 🛠️ **Troubleshooting API Issues**

**Common Issues & Solutions:**

| Problem | Nexar Solution | Mouser Solution | Hybrid Benefit |
|---------|----------------|-----------------|----------------|
| **Quota exceeded** | Wait 24 hours | Continue normally | ✅ No interruption |
| **Rate limited** | Wait 1 hour | Slow down requests | ✅ Automatic switching |
| **Auth failure** | Check credentials | Check API key | ✅ Fallback options |
| **Network timeout** | Retry later | Try different endpoint | ✅ Higher reliability |
| **Component not found** | Try different spelling | Search suggestions | ✅ Better coverage |

**Debugging Commands:**
```bash
# Test Nexar connectivity
python bom_manager.py validate --bom-files BOM_CONSOLIDATED.csv --max-components 5 --api nexar

# Test Mouser connectivity
python bom_manager.py validate --bom-files BOM_CONSOLIDATED.csv --api mouser

# Test hybrid approach
python bom_manager.py validate --bom-files BOM_CONSOLIDATED.csv

# Check API usage stats
grep -E "(nexar_calls|mouser_calls)" validation_*.json
```

**Workflow Debugging:**
1. **Check artifacts** - validation results always saved
2. **Review API usage** - detailed statistics in reports
3. **Monitor quotas** - automatic tracking and warnings
4. **Verify credentials** - test both API keys separately

### 💡 **Best Practices for Large BOMs**

**For BOMs >100 components:**
1. **Use hybrid validation** - automatic fallback prevents quota issues
2. **Set up both APIs** - Nexar + Mouser for maximum coverage
3. **Prioritize critical components** - safety-critical parts validated first
4. **Monitor API usage** - detailed reporting in workflow artifacts

**Recommended Workflow Strategy:**
```yaml
# Example workflow configuration
- name: Validate with priority handling
  run: |
    python bom_manager.py validate \
      --bom-files BOM_CONSOLIDATED.csv \
      --priority-components ESP32-S3-Feather COM-14456 LRS-35-5 \
      --output-dir validation_results
```

**Cost Optimization:**
- **Free tier coverage**: Nexar (100 parts) + Mouser (1000 requests) = excellent coverage
- **API upgrade priorities**:
  1. Mouser API for larger BOMs (higher quota)
  2. Nexar Pro for multi-supplier insights
- **Workflow efficiency**: Hybrid approach uses optimal API for each component

---
