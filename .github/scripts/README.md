# Automation Scripts

This directory contains scripts for automated BOM validation and pricing updates using the Nexar API.

## Scripts

### `nexar_validation.py`

Main validation script that:

- Authenticates with Nexar API
- Validates all components in BOM files
- Retrieves current pricing information
- Generates validation results

**Usage:**

```bash
python .github/scripts/nexar_validation.py --output-format github-actions
```

### `generate_pricing_report.py`

Generates markdown reports from validation results:

- Pricing change analysis
- Component availability status
- Cost impact assessment
- Recommendations for action

### `update_bom_pricing.py`

Updates BOM CSV files with current pricing data:

- Compares current vs. validated prices
- Updates prices with >1% difference
- Preserves BOM file formatting

### `check_availability.py`

Monitors component availability:

- Focuses on safety-critical components
- Checks stock levels across suppliers
- Generates availability alerts

## GitHub Actions Workflows

### BOM Pricing Update (`.github/workflows/bom-pricing-update.yml`)

- **Schedule**: Weekly on Mondays at 9 AM UTC
- **Triggers**: Manual dispatch, BOM file changes
- **Actions**: Validates pricing, updates BOMs, creates issues for significant changes

### Component Availability Monitor (`.github/workflows/component-availability.yml`)

- **Schedule**: Daily at 8 AM UTC
- **Focus**: Safety-critical components
- **Actions**: Monitors stock levels, creates urgent alerts for unavailable parts

## Setup

### Required Secrets

Add these to your GitHub repository secrets:

- `NEXAR_CLIENT_ID`: Your Nexar API client ID
- `NEXAR_CLIENT_SECRET`: Your Nexar API client secret

### Local Development

1. Copy `.env.example` to `.env`
2. Add your Nexar API credentials
3. Install dependencies: `pip install -r requirements.txt`
4. Run scripts locally for testing

## API Integration

The automation uses the [Nexar API](https://nexar.com/) for:

- **Part Search**: Finding components by MPN and manufacturer
- **Pricing Data**: Real-time pricing across multiple suppliers
- **Availability**: Stock levels and lead times
- **Specifications**: Technical details and compliance data

## Workflow Features

### Automated Actions

- ✅ **Price Validation**: Weekly validation of all BOM components
- ✅ **Automatic Updates**: BOM files updated with current pricing
- ✅ **Change Detection**: Issues created for significant price changes
- ✅ **Availability Monitoring**: Daily checks for critical components
- ✅ **Supply Chain Alerts**: Urgent notifications for stock issues

### Reporting

- 📊 **Pricing Reports**: Detailed analysis of cost changes
- 📦 **Availability Reports**: Stock status across suppliers
- 🔄 **Backup System**: Previous pricing preserved before updates
- 📈 **Trend Analysis**: Long-term pricing and availability trends

## Benefits

1. **Cost Management**: Automatic tracking of component price changes
2. **Supply Chain Risk**: Early warning for availability issues
3. **Project Planning**: Updated cost estimates for accurate budgeting
4. **Quality Assurance**: Verification of part numbers and specifications
5. **Automation**: Reduced manual effort for BOM maintenance

## Error Handling

- **API Failures**: Graceful degradation with detailed error reporting
- **Rate Limiting**: Automatic retry with exponential backoff
- **Data Validation**: Comprehensive checks for data integrity
- **Fallback Options**: Alternative data sources when primary API unavailable
