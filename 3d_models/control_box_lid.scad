// ShopVac Rat Trap - Control Box Lid (Front Panel)
// Lid for the control box with OLED display cutout.
// Oriented in printable perspective: outer face flat on the build plate (z=0),
// internal registration lip extending upward (+Z, z=4..7mm) so the entire lid
// prints with zero supports and zero overhangs.
// Mounting holes align with screw posts in control_box_exit_mount.scad.

include <trap_modules.scad>

// ========== CORE PARAMETERS ==========

box_wall = 4;                       // Box wall thickness (mm, matches ctrl_box_wall)
internal_length = 120;              // Internal cavity length (X, matches ctrl_box_int_length)
internal_width = 100;               // Internal cavity width (Y, matches ctrl_box_int_width)
internal_height = 65;               // Internal cavity height (Z, matches ctrl_box_int_height)

// Lid dimensions
lid_thickness = ctrl_box_lid_thickness;
lip_depth = 3;                      // Internal registration lip height (z = 4..7mm)
lip_width = 2.4;                    // Registration lip wall thickness (mm)
lip_clearance = print_tolerance;    // Clearance inside box cavity (0.3mm)

// Derived outer dimensions (matches enclosure)
outer_length = ctrl_box_outer_length; // 128mm
outer_width = ctrl_box_outer_width;   // 108mm

// Lid mounting (matches screw posts in control_box_exit_mount.scad)
lid_post_diameter = ctrl_box_lid_post_diameter;
lid_post_inset = ctrl_box_lid_post_inset;
screw_clearance = ctrl_box_lid_screw_diameter;
countersink_diameter = 6.5;         // M3 countersink OD
countersink_depth = 1.8;            // Depth of 45-deg countersink

// ========== MODULES ==========

module control_box_lid() {
    hole_positions = [
        [box_wall + lid_post_inset, box_wall + lid_post_inset],
        [box_wall + internal_length - lid_post_inset, box_wall + lid_post_inset],
        [box_wall + lid_post_inset, box_wall + internal_width - lid_post_inset],
        [box_wall + internal_length - lid_post_inset, box_wall + internal_width - lid_post_inset]
    ];

    difference() {
        union() {
            // --- MAIN LID PLATE (outer face rests flat on build plate at z=0) ---
            rounded_box(outer_length, outer_width, lid_thickness, 3);

            // --- INTERNAL REGISTRATION LIP (extends upward from z=lid_thickness) ---
            // Drops into the box opening when flipped onto the box; corner cutouts
            // clear the 4 internal screw posts in control_box_exit_mount.scad.
            difference() {
                translate([box_wall + lip_clearance, box_wall + lip_clearance, lid_thickness - 0.5])
                    rounded_box(internal_length - 2*lip_clearance,
                                internal_width - 2*lip_clearance,
                                lip_depth + 0.5, 1);

                // Hollow interior of perimeter lip
                translate([box_wall + lip_clearance + lip_width,
                           box_wall + lip_clearance + lip_width,
                           lid_thickness - 1])
                    rounded_box(internal_length - 2*lip_clearance - 2*lip_width,
                                internal_width - 2*lip_clearance - 2*lip_width,
                                lip_depth + 3, 0.5);

                // Clearance around 4 corner screw posts (cut only from lip to avoid coplanar face)
                for (pos = hole_positions) {
                    translate([pos[0], pos[1], lid_thickness - 1])
                        cylinder(d=lid_post_diameter + 2*print_tolerance + 0.8, h=lip_depth + 3);
                }
            }
        }

        // --- MOUNTING HOLES (4x corners, M3 countersunk from z=0 outer face) ---
        for (pos = hole_positions) {
            translate([pos[0], pos[1], 0]) {
                // Through hole
                translate([0, 0, -1])
                    cylinder(d=screw_clearance, h=lid_thickness + lip_depth + 3);

                // 45-deg countersink on z=0 outer face (narrows going up -> zero overhang)
                translate([0, 0, -0.05])
                    cylinder(d1=countersink_diameter, d2=screw_clearance,
                             h=countersink_depth + 0.05);
            }
        }

        // --- OLED DISPLAY CUTOUT ---
        translate([outer_length/2, outer_width/2 + 20, 0]) {
            // Viewing window (active display area through full thickness)
            translate([-oled_cutout_width/2, -oled_cutout_height/2, -1])
                cube([oled_cutout_width, oled_cutout_height, lid_thickness + lip_depth + 2]);

            // PCB recess on inside face (faces +Z, zero overhang)
            translate([-oled_board_width/2, -oled_board_height/2, lid_thickness - 2])
                cube([oled_board_width, oled_board_height, lip_depth + 3]);
        }

        // --- ARCADE BUTTON CUTOUT (Adafruit 471, 30mm diameter) ---
        translate([outer_length/2 - 28, outer_width/2 - 16, -1])
            cylinder(d=arcade_button_cutout_dia, h=lid_thickness + lip_depth + 3);

        // --- EMERGENCY STOP SWITCH CUTOUT (Schneider XB6ETN521P, 16mm diameter) ---
        translate([outer_length/2 + 28, outer_width/2 - 16, -1])
            cylinder(d=estop_cutout_dia, h=lid_thickness + lip_depth + 3);
    }
}

// ========== RENDER ==========
control_box_lid();
