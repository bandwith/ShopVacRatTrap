#!/bin/bash
# STL Generation Script for ShopVac Rat Trap
# Generates STL files from SCAD sources with proper error handling

set -e  # Exit on error

CHANGED_FILES="$1"
FORCE_REGENERATE="$2"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🏗️ Starting STL generation...${NC}"

cd "3D Models"

# Function to generate STL with error handling
generate_stl() {
    local scad_file="$1"
    local base_name=$(basename "$scad_file" .scad)
    local stl_file="${base_name}.stl"

    echo -e "${YELLOW}🔧 Generating $stl_file from $scad_file...${NC}"

    # Generate STL with verbose output and error checking
    if openscad -o "$stl_file" "$scad_file" --render --quiet; then
        if [ -f "$stl_file" ] && [ -s "$stl_file" ]; then
            echo -e "${GREEN}✅ Successfully generated $stl_file${NC}"

            # Get file size for verification
            local file_size=$(stat -c%s "$stl_file")
            echo -e "${GREEN}📏 File size: $file_size bytes${NC}"

            # Basic STL validation - check for "solid" keyword
            if head -n 1 "$stl_file" | grep -q "solid\|STL"; then
                echo -e "${GREEN}✅ STL file appears valid${NC}"
            else
                echo -e "${YELLOW}⚠️  Warning: STL file may not be properly formatted${NC}"
            fi
        else
            echo -e "${RED}❌ Error: STL file was not created or is empty${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ Error: OpenSCAD failed to generate $stl_file${NC}"
        return 1
    fi
}

# Process changed files or all files if force regenerate
if [ "$FORCE_REGENERATE" = "true" ]; then
    echo -e "${BLUE}🔄 Force regenerating all STL files...${NC}"
    for scad_file in *.scad; do
        if [ -f "$scad_file" ]; then
            generate_stl "$scad_file"
        fi
    done
else
    echo -e "${BLUE}📝 Processing changed SCAD files...${NC}"
    echo "Changed files: $CHANGED_FILES"

    if [ -n "$CHANGED_FILES" ]; then
        for file_path in $CHANGED_FILES; do
            if [[ "$file_path" == *".scad" ]] && [[ "$file_path" == "3D Models"* ]]; then
                # Extract just the filename from the full path
                scad_filename=$(basename "$file_path")
                if [ -f "$scad_filename" ]; then
                    generate_stl "$scad_filename"
                fi
            fi
        done
    else
        echo -e "${YELLOW}⚠️  No SCAD files changed${NC}"
    fi
fi

echo -e "${GREEN}✅ STL generation completed!${NC}"
