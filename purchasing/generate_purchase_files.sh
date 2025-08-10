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
python3 ../.github/scripts/bom_manager.py --bom-file ../BOM_CONSOLIDATED.csv --output-dir . --generate-purchase-files --generate-mouser-only

echo ""
echo "✅ Purchase files generated successfully!"
echo ""
echo "📁 Generated Files:"
echo "   - mouser_upload_consolidated.csv (Standard Mouser bulk upload file)"
echo "   - BOM_MOUSER_ONLY.csv (Mouser-only consolidated BOM)"
echo "   - mouser_upload_consolidated_only.csv (Mouser-only bulk upload file)"
echo ""
echo "🛒 Next Steps:"
echo "1. See COMPONENT_SOURCING.md for complete purchasing instructions"
echo "2. Upload mouser_upload_consolidated.csv to https://www.mouser.com/tools/bom-tool"
echo "3. Enjoy simplified single-distributor ordering!"
echo ""
echo "💡 Tip: Run this script weekly to get updated pricing and availability"
