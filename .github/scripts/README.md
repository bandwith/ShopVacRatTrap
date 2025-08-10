# ShopVacRatTrap BOM Automation Scripts

This directory contains scripts for automated BOM validation, pricing updates, and availability monitoring using the Mouser API.

## Scripts

### `bom_validator.py`

Main validation script that:

- Connects to Mouser API
- Validates all components in BOM files
- Retrieves current pricing information
- Checks stock availability
- Generates validation reports

**Usage:**

```bash
python .github/scripts/bom_validator.py --bom-file BOM_CONSOLIDATED.csv
```

### `mouser_consolidation_analyzer.py`

Analyzes consolidation opportunities:

- Maps Adafruit components to Mouser alternatives
- Calculates potential cost savings
- Generates consolidated BOM options
- Creates detailed analysis reports

**Usage:**

```bash
python .github/scripts/mouser_consolidation_analyzer.py --bom-file BOM_CONSOLIDATED.csv
```

### `generate_purchase_files.py`

Creates purchase guides and distributor upload files:

- Generates markdown purchase guides with direct links
- Creates Mouser BOM upload files
- Organizes components by distributor

### `update_bom_pricing.py`

Updates BOM CSV files with current pricing data:

- Compares current vs. validated prices
- Updates prices with significant differences
- Preserves BOM file formatting

### `check_availability.py`

Monitors component availability:

- Focuses on safety-critical components
- Checks stock levels at Mouser
- Generates availability alerts

## GitHub Actions Workflow

### BOM Validation & Monitoring (`.github/workflows/bom-validation.yml`)

- **Schedule**: Weekly on Mondays at 9 AM UTC
- **Triggers**: Manual dispatch with options
- **Actions**:
  - Validates pricing
  - Checks availability
  - Analyzes consolidation opportunities
  - Updates BOMs
  - Creates issues for significant changes or availability problems

## Setup

### Required Secrets

Add this to your GitHub repository secrets:

- `MOUSER_API_KEY`: Your Mouser API key

### Local Development

1. Create a `.env` file with your Mouser API key
2. Install dependencies: `pip install -r requirements.txt`
3. Run scripts locally for testing

## Workflow Features

### Automated Actions

- ✅ **Price Validation**: Weekly validation of all BOM components
- ✅ **Automatic Updates**: BOM files updated with current pricing
- ✅ **Change Detection**: Issues created for significant price changes
- ✅ **Availability Monitoring**: Weekly checks for critical components
- ✅ **Supply Chain Alerts**: Notifications for stock issues
- ✅ **Consolidation Analysis**: Identifies single-supplier opportunities

### Reporting

- 📊 **Pricing Reports**: Detailed analysis of cost changes
- 📦 **Availability Reports**: Stock status for components
- 🔄 **Backup System**: Previous pricing preserved before updates
- � **Consolidation Reports**: Analysis of cost-saving opportunities

## Benefits

1. **Simplified Maintenance**: Single API integration with Mouser
2. **Cost Management**: Automatic tracking of component price changes
3. **Supply Chain Risk**: Regular warning for availability issues
4. **Project Planning**: Updated cost estimates for accurate budgeting
5. **Consolidation Opportunities**: Analysis of single-supplier options

## Error Handling

- **API Failures**: Graceful degradation with detailed error reporting
- **Rate Limiting**: Automatic retry with exponential backoff
- **Data Validation**: Comprehensive checks for data integrity
- **Retry Logic**: Built-in retry mechanisms for transient errors

## Key Improvements

- **Simplified Architecture**: Single workflow instead of multiple
- **Reduced API Dependencies**: Mouser-only instead of multiple APIs
- **Simplified Code Structure**: Reduced script complexity
- **Improved Reliability**: No dependency on Nexar quota limits
- **Better Maintainability**: Fewer moving parts to maintain
