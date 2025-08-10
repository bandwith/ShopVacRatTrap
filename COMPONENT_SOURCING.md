# Component Sourcing Guide - ShopVac Rat Trap 2025

## 🚀 Quick Purchase Options

**NEW**: Automated purchase files and links are now available for streamlined ordering:

- **Run**: `./purchasing/generate_purchase_files.sh` to generate current purchase files
- **Files Created**:
  - `PURCHASE_GUIDE.md` - Complete purchase guide with direct links
  - `mouser_upload_consolidated.csv` - Mouser bulk upload file
  - `adafruit_order_consolidated_cart_url.txt` - One-click Adafruit cart
  - `sparkfun_order_consolidated_cart_url.txt` - One-click SparkFun cart

**Bulk Ordering**: Upload CSV files to supplier BOM tools for instant pricing and availability.

---

## Components Previously Not Found in Nexar - Updated Sources

### 1. Time-of-Flight Sensor
**Primary**: VL53L0X ToF Sensor Module
**Adafruit 3317**: $7.95 - https://www.adafruit.com/product/3317
**SparkFun SEN-14722**: $9.95 - https://www.sparkfun.com/products/14722
**Alternative**: Generic VL53L0X modules on Amazon ($3-5)
**Note**: 4m range sufficient for rat detection, cost-optimized professional sensor

### 2. Environmental Sensor
**Primary**: BME280 Temperature/Humidity/Pressure Sensor - STEMMA QT
**Adafruit 4816**: $14.95 - https://www.adafruit.com/product/4816
**SparkFun SEN-15440**: $19.95 - https://www.sparkfun.com/products/15440
**Alternative**: DHT22/AM2302 (legacy design) - $4.95
**Note**: BME280 STEMMA QT provides professional no-solder assembly

### 3. Power Supply
**Primary**: Mean Well LRS-35-5 (5V/7A)
**Mouser 709-LRS35-5**: $18.95 - https://www.mouser.com/ProductDetail/709-LRS35-5
**Digi-Key 1866-5012-ND**: $18.70
**Newark 85AC4189**: $19.25
**Alternative**: LRS-15-5 for budget builds (ensure adequate capacity)

### 4. Solid State Relay
**Primary**: Sensata Crydom D2425-10 (25A, Zero-crossing)
**Mouser 558-D2425-10**: $32.15 - https://www.mouser.com/ProductDetail/558-D2425-10
**Digi-Key 2057-D2425-10-ND**: $33.42
**Alternative**: Omron G3NA-210B-DC5-24 - $28.50
**Alternative**: Carlo Gavazzi RM1A23D25 - $30.75
**⚠️ SAFETY CRITICAL**: Must be UL/CE listed for AC switching

### 5. Current Transformer
**Primary**: YHDC SCT-013-020 (20A, split-core)
**Amazon B07TXQBC1D**: $8.00 - https://amazon.com/dp/B07TXQBC1D
**AliExpress**: $5-8 (direct from YHDC)
**Alternative**: Magnelab SCT-0300-020 - $35 (US-made)
**Alternative**: CR Magnetics CR5220-20 - $32
**⚠️ SAFETY CRITICAL**: Verify 600V insulation rating

### 6. NEMA Outlet
**Primary**: Kycon KPJX-5262-BK (NEMA 5-15R, Black)
**Mouser 163-KPJX-5262-BK**: $3.20
**Digi-Key 163-KPJX-5262-BK-ND**: $3.35
**Alternative**: Schurter 4301.1405 - $4.50
**Alternative**: Hubbell HBL5262 - $5.25
**Note**: Panel-mount version for control box integration

### 7. Fuses
**Primary**: Littelfuse 0218012.MXP (12A, 250V, Fast-blow)
**Mouser 576-0218012.MXP**: $1.95
**Digi-Key F2073-ND**: $2.10
**Alternative**: Bel Fuse 5ST 12-R - $1.85
**Alternative**: Cooper Bussman GMA-12A - $1.50
**⚠️ SAFETY CRITICAL**: UL/CE listed for safety compliance

### 8. Heat Sink (Optional)
**Primary**: Wakefield-Vette 507-10ABPB (10x10mm)
**Mouser 532-507-10ABPB**: $3.15
**Digi-Key HS117-ND**: $3.25
**Alternative**: Aavid Thermalloy 531002B00000G - $2.85
**Alternative**: Generic TO-220 heat sinks - $1-2
**Note**: May not be required for ESP32 in this application

### 9. Thermal Interface Pad (Optional)
**Primary**: Bergquist SP400-0.010-00-1010 (0.010", 10x10mm)
**Mouser 539-SP400-010-001010**: $2.45
**Digi-Key BER157-ND**: $2.65
**Alternative**: 3M 8810 thermal pad - $2.20
**Alternative**: Generic thermal pads from Amazon - $0.50-1.00
**Note**: Only needed if heat sink is used

## Sourcing Strategy by Component Type

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

## Cost Optimization Notes

### Budget Version Substitutions
1. **VL53L0X**: Use generic modules ($3 vs $8) - verify I2C compatibility
2. **BME280**: Use DHT22 for budget builds ($5 vs $15) - no pressure sensing
3. **Power supply**: LRS-15-5 for smaller builds ($12 vs $19) - ensure adequate capacity
4. **Heat sink/thermal pad**: Omit for indoor applications - monitor ESP32 temperature

### Bulk Pricing
- **10+ units**: 15-20% discount on major distributors
- **100+ units**: Contact distributors for volume pricing
- **1000+ units**: Direct manufacturer negotiations

### Lead Time Considerations
- **Standard components**: 1-2 weeks (Mouser/Digi-Key)
- **Specialty components**: 2-8 weeks (SSR, current transformer)
- **Generic alternatives**: 1-7 days (Amazon Prime)
- **International shipping**: Add 1-2 weeks

## Verified Alternatives Summary

| Original Component | Alternative 1 | Alternative 2 | Cost Savings |
|-------------------|---------------|---------------|--------------|
| VL53L0X Module | Generic module | Sharp GP2Y0A21YK0F | -$4 to -$5 |
| BME280 STEMMA QT | DHT22 Legacy | SHT30 Alternative | -$10 to +$5 |
| LRS-15-5 | Generic 5V PSU | Recom RAC03-05SK | -$4 to +$3 |
| D2425-10 | Omron G3NA | Carlo Gavazzi RM1A | -$3 to +$2 |
| SCT-013-020 | CR Magnetics | Magnelab | +$24 to +$27 |

**Total potential savings with alternatives**: $10-15 per unit
**Recommended approach**: Use alternatives for non-safety-critical components only

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
   - Register at [nexar.com/api](https://nexar.com/api)
   - Get `NEXAR_CLIENT_ID` and `NEXAR_CLIENT_SECRET`
   - Free tier: 100 parts/day

2. **Mouser API** (recommended):
   - Register at [Mouser API Hub](https://www.mouser.com/api-hub/)
   - Get `MOUSER_API_KEY`
   - Free tier: 1000 requests/hour

**GitHub Secrets Setup:**
```bash
# Add to repository secrets:
NEXAR_CLIENT_ID=your_nexar_client_id
NEXAR_CLIENT_SECRET=your_nexar_client_secret
MOUSER_API_KEY=your_mouser_api_key
```

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
python .github/scripts/nexar_validation.py --bom-files BOM_CONSOLIDATED.csv --max-components 5

# Test Mouser connectivity
python .github/scripts/mouser_api.py --bom-files BOM_CONSOLIDATED.csv

# Test hybrid approach
python .github/scripts/hybrid_bom_validator.py --bom-files BOM_CONSOLIDATED.csv

# Check API usage stats
grep -E "(nexar_calls|mouser_calls)" hybrid_validation_*.json
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
    python .github/scripts/hybrid_bom_validator.py \
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

**Last Updated**: August 9, 2025
**Verification Status**: All part numbers and prices verified as of update date
**API Integration**: Hybrid Nexar + Mouser implementation active
**Error Handling**: Comprehensive retry logic and fallback systems
**Next Review**: September 2025 (quarterly price/availability check)
