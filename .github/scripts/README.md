# GitHub Scripts for ShopVac Rat Trap

This directory contains automation scripts for the ShopVac Rat Trap project.

## STL Generation Scripts

### stl_generate.sh
Generates STL files from SCAD sources with error handling and validation.

**Usage:**
```bash
./stl_generate.sh "changed_files" "force_regenerate"
```

**Parameters:**
- `changed_files`: Space-separated list of changed SCAD files
- `force_regenerate`: "true" to regenerate all files, "false" for changed only

### stl_build_report.sh
Creates comprehensive build reports for STL generation tracking.

**Usage:**
```bash
./stl_build_report.sh
```

**Output:**
- Generates `build_report.md` in project root
- Includes file sizes, modification times, and build metadata

### stl_validate.sh
Validates generated STL files for integrity and quality.

**Usage:**
```bash
./stl_validate.sh
```

**Checks:**
- File existence and size validation
- STL format verification
- Triangle count reporting
- Common STL issue detection

## BOM Management Scripts

### bom_manager.py
Consolidated script for BOM management:

- **Validation**: Connects to Mouser API and validates components
- **Pricing Updates**: Updates BOM files with current pricing
- **Availability Checking**: Monitors stock levels for all components
- **Purchase Files**: Generates guides and distributor upload files

**Usage:**

```bash
# Full functionality
python .github/scripts/bom_manager.py --bom-file BOM_CONSOLIDATED.csv --all

# Specific operations
python .github/scripts/bom_manager.py --bom-file BOM_CONSOLIDATED.csv --validate --check-availability
python .github/scripts/bom_manager.py --bom-file BOM_CONSOLIDATED.csv --update-pricing
python .github/scripts/bom_manager.py --bom-file BOM_CONSOLIDATED.csv --generate-purchase-files
python .github/scripts/bom_manager.py --bom-file BOM_CONSOLIDATED.csv --generate-mouser-only
```

### mouser_api.py
Provides Mouser Electronics API integration for component sourcing.

## Workflow Integration

These scripts are automatically executed by GitHub Actions workflows:

### STL Generation (`.github/workflows/stl-generation.yml`)
- Triggered on SCAD file changes or manual dispatch
- Automatically generates and commits STL files
- Validates STL integrity and creates build reports

### BOM Validation & Monitoring (`.github/workflows/bom-validation.yml`)
- **Schedule**: Weekly on Mondays at 9 AM UTC
- **Triggers**: Manual dispatch with options
- **Actions**:
  - Validates pricing
  - Checks availability
  - Analyzes consolidation opportunities
  - Updates BOMs
  - Creates issues for significant changes or availability problems

## Local Development

To run these scripts locally:

1. **Install OpenSCAD (for STL generation):**
   ```bash
   # Ubuntu/Debian
   sudo apt-get install openscad

   # macOS
   brew install openscad
   ```

2. **Install Python dependencies (for BOM management):**
   ```bash
   pip install -r requirements.txt
   ```

3. **Make scripts executable:**
   ```bash
   chmod +x .github/scripts/*.sh
   ```

4. **Set up environment (for BOM scripts):**
   ```bash
   # Create .env file with your Mouser API key
   echo "MOUSER_API_KEY=your_key_here" > .env
   ```

5. **Run individual scripts as needed:**
   ```bash
   # STL generation
   ./.github/scripts/stl_generate.sh "3d_models/Side_Mount_Control_Box.scad" "false"
   ./.github/scripts/stl_validate.sh
   ./.github/scripts/stl_build_report.sh

   # BOM management
   python .github/scripts/bom_manager.py --bom-file BOM_CONSOLIDATED.csv --all
   ```

## Dependencies

**Required for STL generation:**
- OpenSCAD (installed automatically in GitHub Actions)
- bash shell
- GNU coreutils (stat, head, grep, etc.)

**Required for BOM management:**
- Python 3.8+
- requests library
- pandas library
- python-dotenv

**Optional for enhanced validation:**
- meshlab (for advanced STL validation)
- file command (for file type detection)

## GitHub Secrets Required

For BOM management workflows:
- `MOUSER_API_KEY`: Your Mouser API key

## Safety and Quality

All scripts include:
- Error handling and validation
- Comprehensive logging
- File integrity checks
- Build quality reporting
- Safety compliance verification
- Automatic retry with exponential backoff
- Data validation and consistency checks

## Scripts

### `bom_manager.py`

Consolidated script for BOM management:

- **Validation**: Connects to Mouser API and validates components
- **Pricing Updates**: Updates BOM files with current pricing
- **Availability Checking**: Monitors stock levels for all components
- **Purchase Files**: Generates guides and distributor upload files

**Usage:**

```bash
# Full functionality
python .github/scripts/bom_manager.py --bom-file BOM_CONSOLIDATED.csv --all

# Specific operations
python .github/scripts/bom_manager.py --bom-file BOM_CONSOLIDATED.csv --validate --check-availability
python .github/scripts/bom_manager.py --bom-file BOM_CONSOLIDATED.csv --update-pricing
python .github/scripts/bom_manager.py --bom-file BOM_CONSOLIDATED.csv --generate-purchase-files
python .github/scripts/bom_manager.py --bom-file BOM_CONSOLIDATED.csv --generate-mouser-only
```

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
