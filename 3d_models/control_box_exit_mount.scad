// ShopVac Rat Trap - Exit-Mounted Control Box
// Houses ESP32, SSR, sensors, and PSU.
// Mounts to the vacuum adapter bracket.
// Features: sensor window with gasket groove, cable glands, internal mounts.
// Uses rounded_box() from helpers.scad.

include <trap_modules.scad>

// ========== CORE PARAMETERS ==========

box_wall = 4;                       // Box wall thickness
internal_length = 120;              // Internal cavity length (X)
internal_width = 100;               // Internal cavity width (Y)
internal_height = 65;               // Internal cavity height (Z)

// Derived outer dimensions
outer_length = internal_length + 2*box_wall;
outer_width = internal_width + 2*box_wall;
outer_height = internal_height + box_wall; // Open top (lid closes it)

// Sensor window (rear face, Y=0 side - faces trap)
window_width = 50;
window_height = 40;
window_center_x = outer_length / 2;
window_center_z = 30;              // Center height of window
gasket_recess_depth = 2;           // Depth of gasket groove ledge
gasket_recess_margin = 3;          // Extra margin around window for gasket

// Mounting holes (to vacuum adapter bracket)
mount_hole_spacing_x = 60;         // Horizontal spacing
mount_hole_spacing_z = 50;         // Vertical spacing
mount_hole_diameter = 3.5;         // M3 clearance

// Lid screw posts
lid_post_diameter = 8;             // OD of screw post
lid_screw_diameter = 3;            // M3 screw hole in post
lid_post_inset = 6;                // Distance from inner wall to post center

// Cable gland holes (PG7 = 12.5mm, PG9 = 15.2mm)
cable_gland_diameter = 12.5;       // PG7 gland

// ========== MODULES ==========

module control_box_exit_mount() {
    difference() {
        union() {
            // --- MAIN BOX SHELL ---
            rounded_box(outer_length, outer_width, outer_height, 3);

            // --- LID SCREW POSTS (inside corners, at top) ---
            translate([box_wall, box_wall, 0]) {
                // Four corner posts rising to top
                post_positions = [
                    [lid_post_inset, lid_post_inset],
                    [internal_length - lid_post_inset, lid_post_inset],
                    [lid_post_inset, internal_width - lid_post_inset],
                    [internal_length - lid_post_inset, internal_width - lid_post_inset]
                ];

                for (pos = post_positions) {
                    translate([pos[0], pos[1], box_wall])
                        difference() {
                            cylinder(d=lid_post_diameter, h=internal_height);
                            translate([0, 0, internal_height - 8])
                                cylinder(d=lid_screw_diameter, h=9);
                        }
                }
            }
        }

        // --- INTERNAL CAVITY ---
        translate([box_wall, box_wall, box_wall])
            rounded_box(internal_length, internal_width, internal_height + 10, 1);

        // --- SENSOR WINDOW (rear face, Y=0 side) ---
        // Main window cutout
        translate([window_center_x - window_width/2, -1, window_center_z - window_height/2])
            cube([window_width, box_wall + 2, window_height]);

        // Gasket groove recess (stepped ledge around window, on inside face)
        translate([window_center_x - window_width/2 - gasket_recess_margin,
                   box_wall - gasket_recess_depth,
                   window_center_z - window_height/2 - gasket_recess_margin])
            cube([window_width + 2*gasket_recess_margin,
                  gasket_recess_depth + 1,
                  window_height + 2*gasket_recess_margin]);

        // --- MOUNTING HOLES (rear face, to attach to vacuum adapter bracket) ---
        for (dx = [-mount_hole_spacing_x/2, mount_hole_spacing_x/2]) {
            for (dz = [-mount_hole_spacing_z/2, mount_hole_spacing_z/2]) {
                translate([window_center_x + dx, -1, window_center_z + dz])
                    rotate([-90, 0, 0])
                        cylinder(d=mount_hole_diameter, h=box_wall + 2);
            }
        }

        // --- CABLE GLAND HOLES (rear wall, Y=outer_width side) ---
        // Power cable gland (left side)
        translate([20, outer_width + 1, 20])
            rotate([90, 0, 0])
                cylinder(d=cable_gland_diameter, h=box_wall + 2);

        // Sensor/vacuum control cable gland (right side)
        translate([outer_length - 20, outer_width + 1, 20])
            rotate([90, 0, 0])
                cylinder(d=cable_gland_diameter, h=box_wall + 2);
    }

    // --- INTERNAL COMPONENT MOUNTS ---
    translate([box_wall, box_wall, box_wall]) {
        // ESP32 Feather mount posts (M2.5, spacing from BOM)
        // Board: 50.8 x 22.9mm, holes at 48.26 x 20.32mm
        translate([10, 50, 0]) {
            esp32_mount_positions = [
                [0, 0],
                [esp32_hole_spacing_y, 0],
                [0, esp32_hole_spacing_x],
                [esp32_hole_spacing_y, esp32_hole_spacing_x]
            ];
            for (pos = esp32_mount_positions) {
                translate([pos[0], pos[1], 0])
                    difference() {
                        cylinder(d=5, h=5);
                        translate([0, 0, -1])
                            cylinder(d=esp32_hole_diameter, h=7);
                    }
            }
        }

        // SSR mount posts (Panasonic AQA411VL)
        // Simple two-post mount at base
        translate([75, 50, 0]) {
            for (dx = [0, ssr_length - 10]) {
                translate([dx, 0, 0])
                    difference() {
                        cylinder(d=6, h=5);
                        translate([0, 0, -1])
                            cylinder(d=3.2, h=7);
                    }
            }
        }

        // Sensor mounting plate rails (behind window)
        // Two vertical rails that hold a removable sensor plate
        translate([internal_length/2 - 30, 2, 5]) {
            cube([4, 4, 50]); // Left rail
        }
        translate([internal_length/2 + 26, 2, 5]) {
            cube([4, 4, 50]); // Right rail
        }
    }
}

module sensor_mounting_plate() {
    // Removable plate that slides into box rails.
    // Holds camera, ToF sensor, and PIR behind the window.
    plate_width = 56;
    plate_height = 48;
    plate_thickness = 3;

    difference() {
        cube([plate_width, plate_thickness, plate_height]);

        // Camera lens hole (OV5640 M12 mount)
        translate([plate_width/2, -1, 35])
            rotate([-90, 0, 0])
                cylinder(d=camera_lens_clearance, h=plate_thickness + 2);

        // ToF sensor hole (VL53L4CX)
        translate([plate_width/2, -1, 20])
            rotate([-90, 0, 0])
                cylinder(d=stemma_qt_board_width, h=plate_thickness + 2);

        // PIR sensor hole
        translate([plate_width/2, -1, 8])
            rotate([-90, 0, 0])
                cylinder(d=pir_dome_clearance, h=plate_thickness + 2);

        // Mounting screw holes (M2.5, corners)
        for (dx = [4, plate_width - 4]) {
            for (dz = [4, plate_height - 4]) {
                translate([dx, -1, dz])
                    rotate([-90, 0, 0])
                        cylinder(d=stemma_qt_hole_diameter, h=plate_thickness + 2);
            }
        }
    }
}

// ========== RENDER ==========
control_box_exit_mount();
