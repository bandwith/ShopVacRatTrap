#!/bin/bash
# Generate purchase files and upload CSVs for ShopVac Rat Trap 2025
# Quick script to regenerate purchase links when needed

echo "🛒 Generating Purchase Files for ShopVac Rat Trap 2025..."
echo ""

# Check if consolidated BOM exists
if [ ! -f "../BOM_CONSOLIDATED.csv" ]; then
    echo "❌ Error: BOM_CONSOLIDATED.csv not found"
    echo "Please ensure you're running this from the purchasing directory and BOM_CONSOLIDATED.csv exists in the project root"
    exit 1
fi

# Generate purchase files
echo "📋 Processing consolidated BOM..."
python3 ../.github/scripts/generate_bom_upload_files.py --bom-file ../BOM_CONSOLIDATED.csv --output-dir .

echo ""
echo "✅ Purchase files generated successfully!"
echo ""
echo "📁 Generated Files:"
echo "   - PURCHASE_GUIDE.md (Comprehensive purchase guide)"
echo "   - mouser_upload_consolidated.csv (Mouser bulk upload)"
echo "   - adafruit_order_consolidated.csv (Adafruit order list)"
echo "   - adafruit_order_consolidated_cart_url.txt (One-click cart link)"
echo "   - sparkfun_order_consolidated.csv (SparkFun order list)"
echo "   - sparkfun_order_consolidated_cart_url.txt (One-click cart link)"
echo ""
echo "🛒 Next Steps:"
echo "1. Open PURCHASE_GUIDE.md for complete purchasing instructions"
echo "2. Upload mouser_upload_consolidated.csv to https://www.mouser.com/tools/bom-tool"
echo "3. Use cart URL files for one-click Adafruit/SparkFun ordering"
echo ""
echo "💡 Tip: Run this script weekly to get updated pricing and availability"
