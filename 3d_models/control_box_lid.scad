// ShopVac Rat Trap - Control Box Lid (Front Panel)
// Lid for the control box with OLED display cutout.
// Mounting holes align with screw posts in control_box_exit_mount.scad.
// Includes internal registration lip to prevent sliding.
// Uses rounded_box() from helpers.scad.

include <trap_modules.scad>

// ========== CORE PARAMETERS ==========

// Must match control_box_exit_mount.scad dimensions
box_wall = 4;
internal_length = 120;
internal_width = 100;
internal_height = 65;

// Lid dimensions
lid_thickness = 4;                  // Main plate thickness
lip_depth = 3;                      // Internal registration lip depth
lip_width = 2;                      // Registration lip wall thickness

// Derived outer dimensions (must match box)
outer_length = internal_length + 2*box_wall;
outer_width = internal_width + 2*box_wall;

// Lid mounting (must match screw post positions in box)
lid_post_inset = 6;                 // Same as box
screw_clearance = 3.5;             // M3 clearance hole
countersink_diameter = 6.5;         // M3 countersink
countersink_depth = 2;             // Depth of countersink

// OLED display cutout (Adafruit 326: 128x64 OLED)
// Using BOM dimensions from trap_modules.scad

// ========== MODULES ==========

module control_box_lid() {
    difference() {
        union() {
            // --- MAIN LID PLATE ---
            rounded_box(outer_length, outer_width, lid_thickness, 3);

            // --- INTERNAL REGISTRATION LIP ---
            // A thin wall that drops into the box opening to prevent lateral sliding.
            translate([box_wall + lip_width, box_wall + lip_width, -lip_depth])
                difference() {
                    rounded_box(internal_length - 2*lip_width,
                               internal_width - 2*lip_width,
                               lip_depth, 1);
                    // Hollow out center (only the perimeter wall remains)
                    translate([lip_width, lip_width, -1])
                        rounded_box(internal_length - 4*lip_width,
                                   internal_width - 4*lip_width,
                                   lip_depth + 2, 0.5);
                }
        }

        // --- MOUNTING HOLES (4x corners, countersunk M3) ---
        // Positions must match lid_post_inset in control_box_exit_mount.scad
        hole_positions = [
            [box_wall + lid_post_inset, box_wall + lid_post_inset],
            [box_wall + internal_length - lid_post_inset, box_wall + lid_post_inset],
            [box_wall + lid_post_inset, box_wall + internal_width - lid_post_inset],
            [box_wall + internal_length - lid_post_inset, box_wall + internal_width - lid_post_inset]
        ];

        for (pos = hole_positions) {
            translate([pos[0], pos[1], -1]) {
                // Through hole
                cylinder(d=screw_clearance, h=lid_thickness + 2);
                // Countersink from top
                translate([0, 0, lid_thickness - countersink_depth + 1])
                    cylinder(d1=screw_clearance, d2=countersink_diameter,
                             h=countersink_depth + 1);
            }
        }

        // --- OLED DISPLAY CUTOUT (centered on lid) ---
        translate([outer_length/2, outer_width/2, 0]) {
            // Viewing window (active display area)
            translate([-oled_active_width/2, -oled_active_height/2, -1])
                cube([oled_active_width, oled_active_height, lid_thickness + 2]);

            // PCB recess (from underside, for board to sit flush)
            translate([-oled_board_width/2, -oled_board_height/2, -1])
                cube([oled_board_width, oled_board_height, lid_thickness - 1]);
        }
    }
}

// ========== RENDER ==========
control_box_lid();
