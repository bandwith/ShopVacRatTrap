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

### Core Electronics (~$95)

| Component | Qty | Est. Price |
|-----------|-----|------------|
| ESP32-S3 Feather | 1 | $17.50 |
| VL53L0X ToF Sensor | 1 | $14.95 |
| APDS9960 ProximitySensor | 1 | $7.95 |
| PIR Motion Sensor | 1 | $5.95 |
| BME280 Environmental | 1 | $14.95 |
| OLED Display 128x64 | 1 | $17.50 |
| STEMMA QT Hub | 1 | $7.50 |
| STEMMA QT Cables | 4 | $4.60 |

### Power & Safety (~$80)

| Component | Qty | Est. Price |
|-----------|-----|------------|
| Mean Well LRS-35-5 PSU | 1 | $18.95 |
| Solid State Relay 40A | 1 | $24.95 |
| IEC Inlet w/ CB & Switch | 1 | $37.50 |
| Emergency Stop Button | 1 | $19.57 |
| AC Outlet (Panel Mount) | 1 | $2.05 |
| Current Transformer | 1 | $3.46 |
| Optocoupler 4N35 | 1 | $0.58 |
| Fuses & Hardware | - | ~$10 |

### Optional Camera System (+$40)

| Component | Qty | Est. Price |
|-----------|-----|------------|
| OV5640 5MP Camera | 1 | $24.95 |
| High-Power IR LED | 1 | $3.95 |
| Additional STEMMA Cables | 2 | $3.20 |
| Micro SD Card 8GB | 1 | $9.95 |

## Total Project Cost

- **Standard Configuration**: ~$150
- **Camera Configuration**: ~$190

!!! note "Price Variability"
    Prices are estimates and may vary based on vendor, availability, and quantity discounts. Use the BOM Manager for current pricing.

## Component Sourcing

See the complete sourcing guide for vendor links, alternatives, and bulk ordering options:

[:material-shopping: Component Sourcing Guide](sourcing.md)
