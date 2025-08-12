#!/bin/bash
# Build Report Generator for STL files
# Creates comprehensive build reports for tracking

set -e

cd "3D Models"

echo "## 🏗️ STL Generation Report" > build_report.md
echo "" >> build_report.md
echo "**Build Date:** $(date -u '+%Y-%m-%d %H:%M:%S UTC')" >> build_report.md
echo "**Commit:** ${GITHUB_SHA:-$(git rev-parse HEAD)}" >> build_report.md
echo "**Workflow:** STL Generation" >> build_report.md
echo "" >> build_report.md

# Check what triggered this build
stl_count=0
scad_count=0
missing_count=0

for stl_file in *.stl; do
    if [ -f "$stl_file" ]; then
        stl_count=$((stl_count + 1))
    fi
done

for scad_file in *.scad; do
    if [ -f "$scad_file" ]; then
        scad_count=$((scad_count + 1))
        base_name=$(basename "$scad_file" .scad)
        stl_file="${base_name}.stl"

        # Check if this STL was recently created (within last minute)
        if [ -f "$stl_file" ]; then
            # Check if file is very recent (likely just generated)
            if [ $(find "$stl_file" -mmin -1 2>/dev/null | wc -l) -gt 0 ]; then
                missing_count=$((missing_count + 1))
            fi
        fi
    fi
done

echo "### Build Summary:" >> build_report.md
echo "" >> build_report.md
echo "- **Total SCAD source files:** $scad_count" >> build_report.md
echo "- **Total STL files generated:** $stl_count" >> build_report.md
if [ $missing_count -gt 0 ]; then
    echo "- **Recently generated files:** $missing_count" >> build_report.md
fi
echo "" >> build_report.md

echo "### Generated Files:" >> build_report.md
echo "" >> build_report.md

for stl_file in *.stl; do
    if [ -f "$stl_file" ]; then
        file_size=$(stat -c%s "$stl_file")
        file_size_kb=$((file_size / 1024))
        mod_time=$(stat -c%y "$stl_file")
        echo "- **$stl_file**: ${file_size_kb}KB (modified: $mod_time)" >> build_report.md
    fi
done

echo "" >> build_report.md
echo "### SCAD Source Files:" >> build_report.md
echo "" >> build_report.md

for scad_file in *.scad; do
    if [ -f "$scad_file" ]; then
        file_size=$(stat -c%s "$scad_file")
        file_size_kb=$((file_size / 1024))
        mod_time=$(stat -c%y "$scad_file")
        echo "- **$scad_file**: ${file_size_kb}KB (modified: $mod_time)" >> build_report.md
    fi
done

echo "" >> build_report.md
echo "### Print Settings Reference:" >> build_report.md
echo "" >> build_report.md
echo "See [PRINT_SETTINGS.md](PRINT_SETTINGS.md) for detailed printing recommendations." >> build_report.md

echo "✅ Build report generated: 3D Models/build_report.md"
