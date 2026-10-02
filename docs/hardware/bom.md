# Bill of Materials

For the complete, up-to-date Bill of Materials, please refer to our consolidated BOM file:

[:material-file-table: View BOM_CONSOLIDATED.csv](https://github.com/bandwith/ShopVacRatTrap/blob/main/BOM_CONSOLIDATED.csv){ .md-button .md-button--primary}

## Automated BOM Management

The project uses an automated BOM management system with real-time pricing via the Mouser API.

### Generate Purchase Files

```bash
cd /home/bandwith/ShopVacRatTrap
source .venv/bin/activate
python .github/scripts/bom_manager.py --bom-file BOM_CONSOLIDATED.csv --generate-purchase-files
```

**Generated Files:**
- `BOM_MOUSER_TEMPLATE.xlsx` - Official Mouser template (recommended)
- `BOM_MOUSER_ONLY.csv` - Mouser-only components
- `PURCHASE_GUIDE.md` - Detailed purchasing instructions

### Current Pricing

The BOM is automatically validated and updated via GitHub Actions. Check the latest workflow run for current pricing:

[:octicons-play-24: View Latest Validation](https://github.com/bandwith/ShopVacRatTrap/actions/workflows/bom-validation.yml)

## Component Categories

> These tables mirror [`BOM_CONSOLIDATED.csv`](https://github.com/bandwith/ShopVacRatTrap/blob/main/BOM_CONSOLIDATED.csv), the single source of truth. If they ever disagree, the CSV wins.

### Core Electronics & Sensors

| Component | Part | Qty | Est. Price |
|-----------|------|-----|------------|
| ESP32-S3 Feather 8MB | 5323 | 1 | $17.50 |
| Feather Stacking Headers | 2830 | 1 | $1.25 |
| VL53L4CX ToF Distance Sensor | 5425 | 1 | $18.00 |
| STHS34PF80 IR Presence Sensor | 6426 | 1 | $11.95 |
| LSM6DSOX 6-DoF Accel/Gyro | 4438 | 1 | $10.95 |
| I2S MEMS Microphone (SPH0645) | 3421 | 1 | $6.95 |
| BME280 Environmental | 2652 | 1 | $14.95 |
| OLED Display 128x64 | 326 | 1 | $17.50 |
| STEMMA QT 5-Port Hub | 5625 | 1 | $2.50 |
| STEMMA QT Cable 100mm | 4210 | 3 | $7.50 |
| STEMMA JST PH Cable 200mm | 3893 | 1 | $1.25 |

### Power & Safety

| Component | Part | Qty | Est. Price |
|-----------|------|-----|------------|
| Mean Well LRS-35-5 PSU (5V/7A) | LRS-35-5 | 1 | $11.80 |
| Panasonic AQA411VL SSR 25A | AQA411VL | 1 | $25.61 |
| Crydom HSP-7 Thermal Pad | HSP-7 | 1 | $1.38 |
| IEC C14 Inlet w/ CB & Switch | DF11.2078.0010.01 | 1 | $37.27 |
| Panel Mount IEC C13 Outlet | 6600.3100 | 1 | $2.05 |
| Emergency Stop Switch 16mm | XB6ETN521P | 1 | $22.13 |
| 20A Split Core Current Transformer | PCS020-EE0502KS | 1 | $4.09 |
| Optocoupler 4N35 | 4N35-X007 | 1 | $0.76 |
| Arcade Button 30mm Red | 471 | 1 | $2.50 |
| PCB Terminal Block 2.54mm | TBC05-02-1-G-G | 1 | $0.61 |
| Wire - Red 26AWG | 1877 | 1 | $0.95 |
| Wire - Black 26AWG | 1881 | 1 | $0.95 |

### Camera System

| Component | Part | Qty | Est. Price |
|-----------|------|-----|------------|
| OV5640 5MP Camera (DVP, 120° AF) | 5946 | 1 | $19.95 |
| High-Power IR LED | 5639 | 1 | $3.95 |
| Micro SD Card 8GB | 1833 | 1 | $1.95 |

## Total Project Cost

**Budget**: ~$246 (all 26 line items; see the CSV for the authoritative total).

!!! note "Price Variability"
    Prices shown are from BOM_CONSOLIDATED.csv based on Mouser and Adafruit pricing. Actual costs may vary with availability and quantity discounts. Use the BOM Manager for current pricing.

!!! note "Integrated Cable Protection"
    All STEMMA QT cables route through built-in channels in the 3D printed trap structure. No external conduit or cable protection components needed - cables are protected by 4mm thick chew-resistant PETG/ASA walls. Cable gland (PG13.5) integrated in control box design.

## Component Sourcing

See the complete sourcing guide for vendor links, alternatives, and bulk ordering options:

[:material-shopping: Component Sourcing Guide](sourcing.md)
