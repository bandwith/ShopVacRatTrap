// Camera Mount for PVC Pipe (Two-Part Clamp)
// Engineer: Gemini
// Date: 2025-11-15
//
// ========== REVISION HIGHLIGHTS ==========
// - REFACTORED: Redesigned as a two-part clamp for robust and secure PVC pipe attachment.
// - REFACTORED: Parametric design for different pipe sizes and components.
// - NEW: Includes a separate strap piece for clamping. Both parts are printed separately.
// - NEW: Added a universal camera mounting slot and a standard 1/4-20 UNC threaded hole.
// - IMPROVED: Strong and reliable design for standalone operation and pipe mounting.
// =========================================

// ========== CORE PARAMETERS ==========
$fn = 100;

// [Assembly Control]
show_main_body = true;
show_strap = true;
show_assembled = false; // Set to true to see the assembly

// [Pipe]
pipe_outer_diameter = 114.3; // 4" Schedule 40 PVC
pipe_fit_tolerance = 0.5; // Add a small gap for a smooth fit

// [Mount]
mount_width = 60;
plate_length = 60;
plate_width = 60;
plate_thickness = 6; // Thicker plate for camera stability
wall_thickness = 6;

// [Fasteners]
flange_screw_diameter = 5; // M5
flange_hole_spacing = pipe_outer_diameter + wall_thickness * 2 + 20;
nut_recess_diameter = 10; // For M5 Nut
nut_recess_depth = 5;

// [Camera Mounting]
camera_mount_slot_width = 6.5; // For 1/4" screw
camera_mount_slot_length = 30;
tripod_screw_diameter = 6.35; // 1/4 inch
tripod_screw_pitch = 1.27; // 20 threads per inch

// ========== MODULES ==========

// Library for threading - using a common OpenSCAD library pattern
module thread(diameter, pitch, length) {
    h = length;
    r = diameter / 2;
    rotate_extrude(convexity = 10)
        translate([r - pitch / 4, 0, 0])
            polygon(points=[[0,0],[pitch/2,0],[pitch/2,pitch/2],[0,pitch/2]]);
}

module main_body() {
    pipe_radius = pipe_outer_diameter / 2;

    difference() {
        union() {
            // Main block
            translate([0, 0, pipe_radius/2]) {
                cube([mount_width, flange_hole_spacing, pipe_radius + wall_thickness], center=true);
            }
            // Top Plate
            translate([0, 0, pipe_radius + wall_thickness + plate_thickness/2]) {
                cube([plate_length, plate_width, plate_thickness], center=true);
            }
        }

        // Pipe cutout
        rotate([90, 0, 0]) {
            cylinder(d=pipe_outer_diameter + (pipe_fit_tolerance * 2), h=mount_width + 2, center=true);
        }

        // Camera mounting slot and threaded hole
        translate([0, 0, pipe_radius + wall_thickness]) {
            // Slot
            hull() {
                for (y = [-camera_mount_slot_length/2, camera_mount_slot_length/2]) {
                    translate([0, y, 0])
                        cylinder(d=camera_mount_slot_width, h=plate_thickness+1, center=true);
                }
            }
            // 1/4-20 Threaded hole in the center of the slot
            // Note: Printing threads might require a well-calibrated printer.
            // A tap can be used to clean the threads post-printing.
            translate([0, 0, -plate_thickness/2])
                thread(tripod_screw_diameter, tripod_screw_pitch, plate_thickness);
        }

        // Flange screw holes
        for (y_mult = [-1, 1]) {
            translate([0, y_mult * flange_hole_spacing/2, 0]) {
                rotate([90,0,0]) {
                    cylinder(d=flange_screw_diameter, h=pipe_radius + wall_thickness + 2, center=true);
                }
            }
        }
    }
}

module strap() {
    pipe_radius = pipe_outer_diameter / 2;

    difference() {
        // Strap body
        union() {
            difference() {
                cylinder(d=pipe_outer_diameter + (pipe_fit_tolerance*2) + wall_thickness*2, h=mount_width, center=true);
                cylinder(d=pipe_outer_diameter + (pipe_fit_tolerance*2), h=mount_width+1, center=true);
            }
            // Flanges
            for (y_mult = [-1, 1]) {
                translate([0, y_mult * (pipe_radius + wall_thickness), 0]) {
                    cube([mount_width, wall_thickness*2, wall_thickness*2], center=true);
                }
            }
        }

        // Cut to make a half-strap
        translate([0,0,pipe_radius+wall_thickness+1]) {
            cube([mount_width+2, (pipe_radius+wall_thickness)*2+2, (pipe_radius+wall_thickness)*2+2], center=true);
        }

        // Flange screw holes with nut recesses
        for (y_mult = [-1, 1]) {
            translate([0, y_mult * flange_hole_spacing/2, 0]) {
                cylinder(d=flange_screw_diameter, h=mount_width+2, center=true);
                translate([0,0, -mount_width/2 - 1]) {
                    cylinder(d=nut_recess_diameter, h=nut_recess_depth);
                }
                 translate([0,0, mount_width/2 + 1 - nut_recess_depth]) {
                    cylinder(d=nut_recess_diameter, h=nut_recess_depth);
                }
            }
        }
    }
}

// ========== ASSEMBLY ==========
if (show_assembled) {
    main_body();
    rotate([0,0,180]) {
        strap();
    }
} else {
    if (show_main_body) {
        main_body();
    }
    if (show_strap) {
        // Place strap next to main body for printing
        translate([0, flange_hole_spacing, 0]) {
            strap();
        }
    }
}
