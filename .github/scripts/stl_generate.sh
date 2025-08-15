#!/bin/bash
# STL Generation Script for ShopVac Rat Trap
# Generates a single STL file from a single SCAD source.
# Designed to be called from a GitHub Actions matrix build.

set -e  # Exit on error

SCAD_FILE_PATH="$1"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "$SCAD_FILE_PATH" ]; then
    echo -e "${RED}❌ Error: No SCAD file path provided.${NC}"
    exit 1
fi

echo -e "${BLUE}🏗️ Starting STL generation for $SCAD_FILE_PATH...${NC}"

# The `generate_stl` function needs to run inside the `3D Models` directory.
cd "3D Models"

# Function to generate STL with error handling and timeout
generate_stl() {
    local scad_file="$1"
    local base_name=$(basename "$scad_file" .scad)
    local stl_file="${base_name}.stl"

    echo -e "${YELLOW}🔧 Generating $stl_file from $scad_file...${NC}"

    # Set timeout based on file complexity
    local timeout_seconds=300  # 5 minutes default
    if [[ "$scad_file" == *"Complete_Trap_Tube_Assembly"* ]]; then
        timeout_seconds=1800  # 30 minutes for large unified assembly
        echo -e "${BLUE}⏱️  Using extended timeout for unified 3D printed design...${NC}"
    fi

    # Generate STL with timeout, verbose output and error checking
    if timeout "$timeout_seconds" openscad -o "$stl_file" "$scad_file" --render --quiet; then
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
        local exit_code=$?
        if [ $exit_code -eq 124 ]; then
            echo -e "${RED}❌ Error: OpenSCAD timed out after $timeout_seconds seconds for $stl_file${NC}"
            echo -e "${YELLOW}💡 Consider optimizing the SCAD file geometry or increasing timeout${NC}"
        else
            echo -e "${RED}❌ Error: OpenSCAD failed to generate $stl_file (exit code: $exit_code)${NC}"
        fi
        return 1
    fi
}

# Generate the single STL file
scad_filename=$(basename "$SCAD_FILE_PATH")
if [ -f "$scad_filename" ]; then
    if generate_stl "$scad_filename"; then
        echo -e "${GREEN}✅ STL generation for $scad_filename completed successfully!${NC}"
        exit 0
    else
        echo -e "${RED}❌ STL generation for $scad_filename failed.${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Error: File not found: $scad_filename in $(pwd)${NC}"
    exit 1
fi
