#!/bin/bash
# STL Validation Script
# Validates generated STL files for integrity and quality

set -e

cd "3D Models"

echo "🔍 Validating STL files..."

validation_passed=true

for stl_file in *.stl; do
    if [ -f "$stl_file" ]; then
        echo "Checking $stl_file..."

        # Basic checks
        if [ ! -s "$stl_file" ]; then
            echo "❌ Error: $stl_file is empty"
            validation_passed=false
            continue
        fi

        # Check file size (should be reasonable)
        file_size=$(stat -c%s "$stl_file")
        if [ "$file_size" -lt 1000 ]; then
            echo "⚠️  Warning: $stl_file is very small (${file_size} bytes)"
        fi

        # Check if file contains expected STL headers
        if ! (head -n 1 "$stl_file" | grep -q "solid\|STL" || file "$stl_file" | grep -q "STL"); then
            echo "⚠️  Warning: $stl_file may not be a valid STL file"
        else
            echo "✅ $stl_file appears valid (${file_size} bytes)"
        fi

        # Check for common STL issues
        triangle_count=$(grep -c "facet normal" "$stl_file" 2>/dev/null || echo "0")
        if [ "$triangle_count" -gt 0 ]; then
            echo "  📐 Triangle count: $triangle_count"
        fi
    fi
done

if [ "$validation_passed" = true ]; then
    echo "✅ All STL files passed validation"
    exit 0
else
    echo "❌ Some STL files failed validation"
    exit 1
fi
