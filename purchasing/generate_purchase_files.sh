#!/bin/bash
# Generate purchase files and upload CSVs for ShopVac Rat Trap 2025
# Current architecture: STEMMA QT hybrid detection with ESP32-S3

echo "🛒 Generating Purchase Files for ShopVac Rat Trap 2025..."
echo ""

# Check if consolidated BOM exists
if [ ! -f "../BOM_CONSOLIDATED.csv" ]; then
    echo "❌ Error: BOM_CONSOLIDATED.csv not found"
    echo "Please ensure you're running this from the purchasing directory and BOM_CONSOLIDATED.csv exists in the project root"
    exit 1
fi

# Check if virtual environment is activated
if [ -z "$VIRTUAL_ENV" ]; then
    echo "⚠️  Virtual environment not detected. Activating .venv..."
    cd ..
    source .venv/bin/activate
    cd purchasing
fi

# Generate purchase files using consolidated BOM
echo "📋 Processing consolidated BOM for current STEMMA QT hybrid detection system..."
python3 ../.github/scripts/bom_manager.py --bom-file ../BOM_CONSOLIDATED.csv --output-dir . --generate-purchase-files

echo ""
echo "✅ Purchase files generated successfully!"
echo ""
echo "📁 Generated Files:"
echo "   - BOM_MOUSER_TEMPLATE.xlsx (Official Mouser template format - RECOMMENDED)"
echo "   - BOM_MOUSER_TEMPLATE.csv (CSV version for review)"
echo "   - Purchase guides for all major distributors"
echo ""
echo "🛒 Ordering Process:"
echo "1. See COMPONENT_SOURCING.md for complete purchasing instructions"
echo "2. Upload BOM_MOUSER_TEMPLATE.xlsx to https://www.mouser.com/tools/bom-tool"
echo "3. Review PURCHASE_GUIDE.md for distributor-specific ordering notes"
echo "4. Follow INSTALLATION_GUIDE.md for assembly procedures"
echo ""
echo "🚀 Current System Benefits:"
echo "   ✅ STEMMA QT modular sensor system for easy assembly"
echo "   ✅ ESP32-S3 based controller with WiFi and extensive I/O"
echo "   ✅ Single power supply design reduces complexity and cost"
echo "   ✅ Enhanced safety with NEC/IEC compliance"
echo "   ✅ Simplified wiring with dedicated inlet sensor assembly"
echo ""
echo "🔄 Tip: Run this script weekly to get updated pricing and availability"
