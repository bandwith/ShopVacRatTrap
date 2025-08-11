#!/bin/bash
# Generate purchase files and upload CSVs for ShopVac Rat Trap 2025
# Updated to use the new Mouser template format

echo "🛒 Generating Purchase Files for ShopVac Rat Trap 2025..."
echo ""

# Check if consolidated BOM exists
if [ ! -f "../BOM_CONSOLIDATED.csv" ]; then
    echo "❌ Error: BOM_CONSOLIDATED.csv not found"
    echo "Please ensure you're running this from the purchasing directory and BOM_CONSOLIDATED.csv exists in the project root"
    exit 1
fi

# Generate purchase files using new Mouser template format
echo "📋 Processing consolidated BOM with Mouser template format..."
python3 ../.github/scripts/bom_manager.py --bom-file ../BOM_CONSOLIDATED.csv --output-dir . --generate-mouser-template --generate-mouser-only

echo ""
echo "✅ Purchase files generated successfully!"
echo ""
echo "📁 Generated Files:"
echo "   - BOM_MOUSER_TEMPLATE.xlsx (Official Mouser template format - RECOMMENDED)"
echo "   - BOM_MOUSER_TEMPLATE.csv (CSV version for review)"
echo "   - BOM_MOUSER_ONLY.csv (Mouser-only consolidated BOM)"
echo "   - mouser_upload_consolidated_only.csv (Legacy simple upload format)"
echo ""
echo "🛒 Next Steps:"
echo "1. See COMPONENT_SOURCING.md for complete purchasing instructions"
echo "2. Upload BOM_MOUSER_TEMPLATE.xlsx to https://www.mouser.com/tools/bom-tool"
echo "3. Enjoy simplified single-distributor ordering with official template format!"
echo ""
echo "💡 Benefits of new format:"
echo "   ✅ Official Mouser template structure"
echo "   ✅ Complete component information (pricing, availability, datasheets)"
echo "   ✅ Direct Excel upload to Mouser BOM tools"
echo "   ✅ Real-time pricing via API"
echo ""
echo "🔄 Tip: Run this script weekly to get updated pricing and availability"
