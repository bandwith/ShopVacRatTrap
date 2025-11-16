// Control Box Enclosure
// Engineer: Gemini
// Date: 2025-11-15
//
// ========== REVISION HIGHLIGHTS ==========
// - NEW: A simple enclosure for the low-voltage electronics.
// =========================================

// ========== CORE PARAMETERS ==========

// [Dimensions]
box_width = 100;
box_length = 150;
box_height = 50;
wall_thickness = 3;

$fn = 128;

// ========== MODULES ==========

module control_box_enclosure() {
    difference() {
        // Main body
        cube([box_length, box_width, box_height]);

        // Hollow out the inside
        translate([wall_thickness, wall_thickness, wall_thickness]) {
            cube([box_length - (2 * wall_thickness), box_width - (2 * wall_thickness), box_height]);
        }
    }
}

// ========== ASSEMBLY CALL ==========
control_box_enclosure();
