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
            echo "❌ Error: $stl_file is too small (${file_size} bytes) - likely invalid"
            validation_passed=false
            continue
        fi

        # Check if file contains expected STL headers
        if ! (head -n 1 "$stl_file" | grep -q "solid\|STL" || file "$stl_file" | grep -q "STL"); then
            echo "❌ Error: $stl_file is not a valid STL file"
            validation_passed=false
            continue
        fi

        # Check for common STL issues
        triangle_count=$(grep -c "facet normal" "$stl_file" 2>/dev/null || echo "0")
        if [ "$triangle_count" -eq 0 ]; then
            echo "❌ Error: $stl_file contains no triangles"
            validation_passed=false
            continue
        fi

        # Check for minimum triangle count (complex geometry should have many triangles)
        if [ "$triangle_count" -lt 100 ]; then
            echo "⚠️  Warning: $stl_file has very few triangles (${triangle_count}) - geometry may be too simple"
        fi

        # Verify STL structure integrity
        if [ -f "$stl_file" ] && [ -s "$stl_file" ]; then
            # Count vertices and check structure
            vertex_count=$(grep -c "vertex" "$stl_file" 2>/dev/null || echo "0")
            expected_vertices=$((triangle_count * 3))

            if [ "$vertex_count" -ne "$expected_vertices" ]; then
                echo "❌ Error: $stl_file has inconsistent triangle/vertex count (triangles: $triangle_count, vertices: $vertex_count, expected: $expected_vertices)"
                validation_passed=false
                continue
            fi

            echo "✅ $stl_file is valid (${file_size} bytes, ${triangle_count} triangles)"
        else
            echo "❌ Error: $stl_file is not readable"
            validation_passed=false
        fi
    fi
done

if [ "$validation_passed" = true ]; then
    echo "✅ All STL files passed validation"
    exit 0
else
    echo "❌ Some STL files failed validation - build should fail"
    exit 1
fi
