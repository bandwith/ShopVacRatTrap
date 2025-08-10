#!/bin/bash
# Script to clean up stale scripts that have been consolidated into bom_manager.py

echo "🧹 Removing stale scripts that are now consolidated..."

# List of scripts that have been consolidated
STALE_SCRIPTS=(
  ".github/scripts/bom_validator.py"
  ".github/scripts/check_availability.py"
  ".github/scripts/consolidate_mouser_only.py"
  ".github/scripts/generate_purchase_files.py"
  ".github/scripts/generate_purchase_links.py"
  ".github/scripts/mouser_consolidation_analyzer.py"
)

# Check each file and remove if it exists
for script in "${STALE_SCRIPTS[@]}"; do
  if [ -f "$script" ]; then
    echo "Removing $script..."
    rm "$script"
  else
    echo "File $script not found, skipping"
  fi
done

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "All functionality has been consolidated into .github/scripts/bom_manager.py"
