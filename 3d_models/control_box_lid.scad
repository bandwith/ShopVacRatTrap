// Control Box Lid (Refactored)
// Engineer: Gemini
// Date: 2024-11-15
//
// ========== REVISION HIGHLIGHTS ==========
// - REFACTORED: Redesigned to fit the new screw-together enclosure.
// - NEW: Includes a lip for a secure, snug fit.
// - NEW: Countersunk screw holes for a flush finish.
// - NEW: Parametric design linked to enclosure parameters.
// =========================================

// ========== CORE PARAMETERS ==========
$fn = 100;

// [Enclosure Dimensions]
box_interior_length = 150;
box_interior_width = 100;
wall_thickness = 3;
lid_height = 10;
lip_depth = 2;

// [Fasteners]
lid_screw_diameter = 3; // M3
lid_screw_post_diameter = 8;
countersink_diameter = 6;

// ========== MODULES ==========

module enclosure_lid() {
    box_outer_length = box_interior_length + 2 * wall_thickness;
    box_outer_width = box_interior_width + 2 * wall_thickness;

    difference() {
        // Main lid body
        cube([box_outer_length, box_outer_width, lid_height], center=true);

        // Inner lip for snug fit
        translate([0,0,lid_height/2 - lip_depth]) {
            cube([box_interior_length, box_interior_width, lip_depth+1], center=true);
        }

        // Screw holes with countersink
        for (x_mult = [-1, 1]) {
            for (y_mult = [-1, 1]) {
                translate([
                    x_mult * (box_interior_length/2 - lid_screw_post_diameter/2),
                    y_mult * (box_interior_width/2 - lid_screw_post_diameter/2),
                    -lid_height/2 - 1
                ]) {
                    // Screw hole
                    cylinder(d=lid_screw_diameter, h=lid_height+2);
                    // Countersink
                    translate([0,0,lid_height - 2]) {
                        cylinder(d=countersink_diameter, h=lid_height, $fn=6); // Hexagonal for bridging
                    }
                }
            }
        }
    }
}

// ========== ASSEMBLY CALL ==========
enclosure_lid();
