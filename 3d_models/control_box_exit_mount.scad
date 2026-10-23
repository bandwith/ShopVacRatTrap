// ShopVac Rat Trap - Exit-Mounted Control Box
// Houses ESP32, SSR, sensors, and PSU.
// Mounts to the vacuum adapter bracket via shared control_box_bolt_pattern().
// Printable perspective: flat base on build plate (z=0), open top at +Z,
// 45-deg self-supporting sensor window and fused internal mounting rails/bosses.

include <trap_modules.scad>

// ========== CORE PARAMETERS ==========

box_wall = 4;                       // Box wall thickness (mm)
internal_length = 120;              // Internal cavity length (X)
internal_width = 100;               // Internal cavity width (Y)
internal_height = 65;               // Internal cavity height (Z)

// Derived outer dimensions
outer_length = internal_length + 2*box_wall; // 128mm
outer_width = internal_width + 2*box_wall;   // 108mm
outer_height = internal_height + box_wall;   // 69mm (open top, closed by lid)

// Sensor window (rear face, Y=0 side - faces vacuum adapter bracket)
window_width = sensor_window_width; // 44mm
window_center_x = outer_length / 2; // 64mm
gasket_recess_depth = 2;            // Depth of gasket groove ledge (mm)
gasket_recess_margin = 2.5;         // Extra margin around window for gasket (mm)

// Lid screw posts
lid_post_diameter = 8;              // OD of screw post (mm)
lid_screw_diameter = 3;             // M3 tap/insert hole in post (mm)
lid_post_inset = 6;                 // Distance from inner wall to post center (mm)

// Cable gland holes (PG7 = 12.5mm)
cable_gland_diameter = 12.5;        // PG7 gland clearance

// ========== MODULES ==========

module control_box_exit_mount() {
    difference() {
        union() {
            // --- MAIN BOX SHELL ---
            rounded_box(outer_length, outer_width, outer_height, 3);
        }

        // --- INTERNAL CAVITY ---
        translate([box_wall, box_wall, box_wall])
            rounded_box(internal_length, internal_width, internal_height + 10, 1);

        // --- SENSOR WINDOW (Y=0 wall, 45-deg gabled top for supportless printing) ---
        translate([window_center_x, box_wall/2, sensor_window_base_z])
            printable_sensor_window(depth=box_wall + 4, margin=0);

        // --- GASKET GROOVE RECESS (stepped ledge on inside face of Y=0 wall) ---
        translate([window_center_x, box_wall - gasket_recess_depth/2 + 0.5, sensor_window_base_z])
            printable_sensor_window(depth=gasket_recess_depth + 1, margin=gasket_recess_margin);

        // --- MOUNTING HOLES (Y=0 wall, attaches to vacuum adapter bracket) ---
        translate([window_center_x, -1, mount_bolt_center_z])
            control_box_bolt_pattern()
                rotate([-90, 0, 0])
                    cylinder(d=mount_bolt_diameter, h=box_wall + 2);

        // --- CABLE GLAND HOLES (Y=outer_width wall) ---
        // Power cable gland (left side)
        translate([24, outer_width + 1, 22])
            rotate([90, 0, 0])
                cylinder(d=cable_gland_diameter, h=box_wall + 2);

        // Sensor/vacuum control cable gland (right side)
        translate([outer_length - 24, outer_width + 1, 22])
            rotate([90, 0, 0])
                cylinder(d=cable_gland_diameter, h=box_wall + 2);
    }

    // --- LID SCREW POSTS (4x inside corners, fused into walls and floor) ---
    translate([box_wall, box_wall, 0]) {
        post_positions = [
            [lid_post_inset, lid_post_inset],
            [internal_length - lid_post_inset, lid_post_inset],
            [lid_post_inset, internal_width - lid_post_inset],
            [internal_length - lid_post_inset, internal_width - lid_post_inset]
        ];

        for (pos = post_positions) {
            translate([pos[0], pos[1], box_wall - 1])
                difference() {
                    cylinder(d=lid_post_diameter, h=internal_height + 1);
                    translate([0, 0, internal_height - 9])
                        cylinder(d=lid_screw_diameter, h=11);
                }
        }
    }

    // --- INTERNAL COMPONENT MOUNTS (fused 1mm into floor at z=box_wall) ---
    translate([box_wall, box_wall, box_wall]) {
        // ESP32 Feather mount posts (M2.5, spacing from BOM: 48.26 x 20.32mm)
        translate([8, 48, -1]) {
            esp32_mount_positions = [
                [0, 0],
                [esp32_hole_spacing_y, 0],
                [0, esp32_hole_spacing_x],
                [esp32_hole_spacing_y, esp32_hole_spacing_x]
            ];
            for (pos = esp32_mount_positions) {
                translate([pos[0], pos[1], 0])
                    difference() {
                        cylinder(d=5.5, h=6);
                        translate([0, 0, 0.5])
                            cylinder(d=esp32_hole_diameter, h=6);
                    }
            }
        }

        // SSR mount posts (Panasonic AQA411VL, positioned at X_int=64..112 inside 120mm cavity)
        translate([64, 50, -1]) {
            for (dx = [0, ssr_length - 10]) {
                translate([dx, 0, 0])
                    difference() {
                        cylinder(d=6.5, h=6);
                        translate([0, 0, 0.5])
                            cylinder(d=3.2, h=6);
                    }
            }
        }

        // Sensor mounting plate U-channel rails (fused to Y=0 inner wall and Z=0 floor,
        // positioned at X_int = 23..28 and 92..97 outside the mounting bolts at X_int = 30, 90)
        // Left rail
        translate([internal_length/2 - 37, -1, -1])
            difference() {
                cube([5, 8, 56]);
                translate([2, 2.5, 1])
                    cube([4, 3.6, 56]);
            }

        // Right rail
        translate([internal_length/2 + 32, -1, -1])
            difference() {
                cube([5, 8, 56]);
                translate([-1, 2.5, 1])
                    cube([4, 3.6, 56]);
            }
    }
}

module sensor_mounting_plate() {
    // Removable plate that slides into box rails behind the sensor window.
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
