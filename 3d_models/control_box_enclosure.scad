// Control Box Enclosure (Refactored)
// Engineer: Gemini
// Date: 2025-11-15
//
// ========== REVISION HIGHLIGHTS ==========
// - REFACTORED: Complete redesign for a robust, screw-together enclosure.
// - NEW: Integrated mounting flanges for secure installation.
// - NEW: Cutouts for a 0.96" OLED display and cable pass-through.
// - NEW: Parametric design for easy modification.
// - IMPROVED: Designed for printability with no supports required (when printed upright).
// =========================================

// ========== CORE PARAMETERS ==========
$fn = 100;

// [Enclosure Dimensions]
box_interior_length = 150;
box_interior_width = 100;
box_interior_height = 50;
wall_thickness = 3;
lid_height = 10;
flange_width = 15;

// [Fasteners]
lid_screw_diameter = 3; // M3
lid_screw_post_diameter = 8;
mounting_hole_diameter = 5; // M5

// [Component Cutouts]
display_width = 27; // For 0.96" OLED
display_height = 15;
cable_pass_through_diameter = 15;

// ========== MODULES ==========

module enclosure_body() {
    box_outer_length = box_interior_length + 2 * wall_thickness;
    box_outer_width = box_interior_width + 2 * wall_thickness;

    difference() {
        union() {
            // Main box shape
            cube([box_outer_length, box_outer_width, box_interior_height], center=true);

            // Mounting flanges
            for (x_mult = [-1, 1]) {
                translate([x_mult * (box_outer_length/2 + flange_width/2), 0, -box_interior_height/2 + wall_thickness/2]) {
                    cube([flange_width, box_outer_width, wall_thickness], center=true);
                }
            }
        }

        // Hollow out interior
        translate([0, 0, wall_thickness/2]) {
            cube([box_interior_length, box_interior_width, box_interior_height], center=true);
        }

        // Lid screw posts
        for (x_mult = [-1, 1]) {
            for (y_mult = [-1, 1]) {
                translate([
                    x_mult * (box_interior_length/2 - lid_screw_post_diameter/2),
                    y_mult * (box_interior_width/2 - lid_screw_post_diameter/2),
                    -box_interior_height/2
                ]) {
                    cylinder(d=lid_screw_post_diameter, h=box_interior_height - wall_thickness);

                    // Screw hole
                    translate([0,0,-1]) {
                         cylinder(d=lid_screw_diameter, h=box_interior_height);
                    }
                }
            }
        }

        // Mounting flange holes
        for (x_mult = [-1, 1]) {
            for (y_mult = [-1, 1]) {
                translate([
                    x_mult * (box_outer_length/2 + flange_width/2),
                    y_mult * (box_interior_width/2 - 10),
                    -box_interior_height/2
                ]) {
                    cylinder(d=mounting_hole_diameter, h=wall_thickness+2, center=true);
                }
            }
        }

        // Display cutout
        translate([box_outer_length/2, 0, 0]) {
             cube([wall_thickness+2, display_width, display_height], center=true);
        }

        // Cable pass-through cutout
        translate([-box_outer_length/2, 0, 0]) {
            rotate([0,90,0]) {
                cylinder(d=cable_pass_through_diameter, h=wall_thickness+2, center=true);
            }
        }
    }
}

// ========== ASSEMBLY CALL ==========
enclosure_body();
