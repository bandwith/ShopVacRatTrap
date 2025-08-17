// ShopVac Rat Trap 2025 - Main Trap Body
// Engineer: Gemini
// Date: 2025-08-15
//
// ========== REVISION HIGHLIGHTS ==========
// - NEW: Main body for the horizontal trap design.
// - NEW: Snap-fit receptacles on both ends for modular assembly.
// - NEW: Top-loading port for a removable bait station.
// - NEW: Integrated internal mount for the PIR motion sensor.
// =========================================

// ========== CORE PARAMETERS ==========

// [Dimensions]
tube_diameter = 101.6; // 4 inches
tube_wall_thickness = 4;
body_length = 300;
flat_base_height = 20;

// [Snap-Fit Connector Parameters - Must match trap_entrance.scad]
clip_width = 15;
clip_thickness = 3;
clip_hook_depth = 2;
receptacle_width = clip_width + 0.6; // Tolerance
receptacle_depth = clip_thickness + 0.6; // Tolerance

// [Bait Station Port]
bait_port_diameter = 40;
bait_port_length = 20;

// [PIR Sensor Mount]
pir_mount_width = 40;
pir_mount_height = 30;
pir_mount_thickness = 3;

// [Enclosure Mounting Plate]
mounting_plate_width = 100;
mounting_plate_height = 80;
mounting_plate_thickness = 5;
screw_hole_diameter = 4;
screw_hole_spacing_x = 80;
screw_hole_spacing_y = 60;

$fn = 128;

// ========== MODULES ==========

module snap_fit_receptacle() {
    // The negative space for the snap_fit_clip
    translate([-receptacle_depth/2, -receptacle_width/2, 0]) {
        cube([receptacle_depth, receptacle_width, clip_hook_depth]);
    }
}

module trap_body_main() {
    difference() {
        union() {
            // Main body
            cylinder(h = body_length, d = tube_diameter + (2 * tube_wall_thickness), center = false);

            // Flat base
            translate([- (tube_diameter / 2) - tube_wall_thickness, -tube_diameter / 2, 0]) {
                cube([tube_diameter + (2 * tube_wall_thickness), tube_diameter, flat_base_height]);
            }

            // Bait station port
            translate([0, 0, tube_diameter / 2 + tube_wall_thickness]) {
                rotate([90, 0, 0]) {
                    cylinder(h = bait_port_length, d = bait_port_diameter);
                }
            }
        }

        // Hollow out the inside
        translate([0, 0, -1]) {
            cylinder(h = body_length + 2, d = tube_diameter, center = false);
        }

        // Cut away the top of the flat base to match the tube
        translate([0, 0, flat_base_height]) {
            cylinder(h = body_length, d = tube_diameter + (2 * tube_wall_thickness) + 2, center = false);
        }

        // Snap-fit receptacles
        for (a = [90, 270]) {
            rotate([0, 0, a]) {
                // One at the front
                translate([tube_diameter / 2 + tube_wall_thickness - receptacle_depth, 0, 20]) {
                    snap_fit_receptacle();
                }
                // One at the back
                translate([tube_diameter / 2 + tube_wall_thickness - receptacle_depth, 0, body_length - 20 - clip_hook_depth]) {
                    snap_fit_receptacle();
                }
            }
        }
    }

    // PIR sensor mount
    translate([0, -pir_mount_width/2, body_length/2]) {
        rotate([90,0,0]){
            cube([pir_mount_thickness, pir_mount_width, pir_mount_height]);
        }
    }

    // Mounting plate for commercial enclosure
    translate([-(tube_diameter/2 + tube_wall_thickness + mounting_plate_thickness), -mounting_plate_width/2, body_length/2 - mounting_plate_height/2]) {
        difference() {
            cube([mounting_plate_thickness, mounting_plate_width, mounting_plate_height]);
            // Screw holes
            translate([-1, mounting_plate_width/2 - screw_hole_spacing_x/2, mounting_plate_height/2 - screw_hole_spacing_y/2]) {
                cylinder(h = mounting_plate_thickness + 2, d = screw_hole_diameter);
            }
            translate([-1, mounting_plate_width/2 + screw_hole_spacing_x/2, mounting_plate_height/2 - screw_hole_spacing_y/2]) {
                cylinder(h = mounting_plate_thickness + 2, d = screw_hole_diameter);
            }
            translate([-1, mounting_plate_width/2 - screw_hole_spacing_x/2, mounting_plate_height/2 + screw_hole_spacing_y/2]) {
                cylinder(h = mounting_plate_thickness + 2, d = screw_hole_diameter);
            }
            translate([-1, mounting_plate_width/2 + screw_hole_spacing_x/2, mounting_plate_height/2 + screw_hole_spacing_y/2]) {
                cylinder(h = mounting_plate_thickness + 2, d = screw_hole_diameter);
            }
        }
    }
}

// ========== ASSEMBLY CALL ==========
trap_body_main();
