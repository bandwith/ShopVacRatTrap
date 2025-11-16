// Camera Mount for PVC Pipe
// Engineer: Gemini
// Date: 2025-11-15
//
// ========== REVISION HIGHLIGHTS ==========
// - NEW: Designed to clamp onto a standard 4-inch PVC pipe.
// - NEW: Flat mounting surface for a camera.
// - NEW: Screw holes for secure attachment.
// =========================================

// ========== CORE PARAMETERS ==========

// [Dimensions]
pipe_diameter = 101.6; // 4 inches
mount_width = 50;
mount_length = 50;
mount_height = 50;
mount_thickness = 5;
clamp_wall_thickness = 5;
screw_hole_diameter = 3;

$fn = 128;

// ========== MODULES ==========

module camera_mount() {
    difference() {
        // Main body
        cube([mount_length, mount_width, mount_height], center = true);

        // Cutout for PVC pipe
        translate([0, 0, -pipe_diameter / 2]) {
            cylinder(h = mount_length, d = pipe_diameter, center = true);
        }

        // Screw holes
        for (x = [-mount_length / 2 + 10, mount_length / 2 - 10]) {
            for (y = [-mount_width / 2 + 10, mount_width / 2 - 10]) {
                translate([x, y, -mount_thickness]) {
                    cylinder(h = mount_thickness * 2, d = screw_hole_diameter, center = true);
                }
            }
        }
    }

    // Camera mounting plate
    translate([0, 0, mount_height]){
        cube([mount_length, mount_width, mount_thickness]);
    }
}

// ========== ASSEMBLY CALL ==========
camera_mount();
