// ShopVac Rat Trap - Exit-Mounted Control Box
// Houses ESP32, SSR, sensors, and PSU.
// Mounts to the vacuum adapter bracket via shared control_box_bolt_pattern().
// Printable perspective: flat base on build plate (z=0), open top at +Z,
// 45-deg self-supporting sensor window and fused internal mounting rails/bosses.

include <trap_modules.scad>

// ========== CORE PARAMETERS ==========

box_wall = 4;                       // Box wall thickness (mm, matches ctrl_box_wall)
internal_length = 120;              // Internal cavity length (X, matches ctrl_box_int_length)
internal_width = 100;               // Internal cavity width (Y, matches ctrl_box_int_width)
internal_height = 65;               // Internal cavity height (Z, matches ctrl_box_int_height)

// Derived outer dimensions
outer_length = ctrl_box_outer_length; // 128mm
outer_width = ctrl_box_outer_width;   // 108mm
outer_height = ctrl_box_outer_height; // 69mm (open top, closed by lid)

// Sensor window (rear face, Y=0 side - faces vacuum adapter bracket)
window_width = sensor_window_width; // 44mm
window_center_x = outer_length / 2; // 64mm
gasket_recess_depth = 2;            // Depth of gasket groove ledge (mm)
gasket_recess_margin = 2.5;         // Extra margin around window for gasket (mm)

// Lid screw posts
lid_post_diameter = ctrl_box_lid_post_diameter; // 8mm
lid_screw_diameter = 3;             // M3 tap/insert hole in post (mm)
lid_post_inset = ctrl_box_lid_post_inset; // 6mm

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

        // --- IEC C14 INLET CUTOUT (X=0 left wall, Schurter DF11) ---
        translate([-1, outer_width/2, 32]) {
            rotate([0, 90, 0]) {
                cube([c14_inlet_cutout_h, c14_inlet_cutout_w, box_wall + 4], center=true);
                for (dy = [-c14_inlet_screw_spacing/2, c14_inlet_screw_spacing/2]) {
                    translate([0, dy, 0])
                        cylinder(d=3.5, h=box_wall + 4, center=true);
                }
            }
        }

        // --- IEC C13 OUTLET CUTOUT (X=outer_length right wall, Schurter 6600.3100) ---
        translate([outer_length + 1, outer_width/2, 32]) {
            rotate([0, -90, 0])
                cube([c13_outlet_cutout_h, c13_outlet_cutout_w, box_wall + 4], center=true);
        }
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

        // SSR mount posts (Panasonic AQA411VL, 47.5mm spacing + HSP-7 thermal pad elevation)
        translate([64, 50, -1]) {
            // Thermal pad relief platform (+1.65mm)
            translate([-4, -ssr_width/2, 0])
                cube([ssr_hole_spacing + 8, ssr_width, ssr_heat_pad_thickness + 1]);
            for (dx = [0, ssr_hole_spacing]) {
                translate([dx, 0, 0])
                    difference() {
                        cylinder(d=7.0, h=7.65);
                        translate([0, 0, 0.5])
                            cylinder(d=ssr_hole_diameter, h=8);
                    }
            }
        }

        // Mean Well LRS-35-5 Power Supply mounting posts (86mm x 70mm chassis spacing)
        translate([17, 15, -1]) {
            for (dx = [0, psu_mount_spacing_x]) {
                for (dy = [0, psu_mount_spacing_y]) {
                    translate([dx, dy, 0])
                        difference() {
                            cylinder(d=6.0, h=5);
                            translate([0, 0, 0.5])
                                cylinder(d=psu_mount_hole_dia, h=5.5);
                        }
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
