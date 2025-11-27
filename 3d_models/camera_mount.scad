// ShopVac Rat Trap - OV5640 Camera Mount
// Adafruit 5945: 32mm × 32mm PCB with M12 lens mount
// Updated with actual component dimensions

use <trap_modules.scad>

// === OV5640 Camera Parameters (Adafruit 5945) ===
camera_pcb_size = 32;           // 32mm square PCB
camera_hole_spacing = 28;       // Mounting hole spacing (corner to corner)
camera_hole_diameter = 2.7;     // M2.5 clearance
camera_lens_diameter = 14;      // M12 lens housing clearance
camera_lens_height = 10;        // Lens projection above PCB
camera_pcb_thickness = 1.6;     // Standard PCB
stemma_clearance = 8;           // Space for STEMMA QT connector on side

// Mount parameters
mount_base_thickness = 4;
mount_standoff_height = 5;
mount_width = camera_pcb_size + 10;
mount_length = camera_pcb_size + stemma_clearance + 5;

// Tube mounting (if attaching to trap)
attach_to_tube = false;

module camera_mount() {
    difference() {
        union() {
            // Base plate
            translate([0, 0, mount_base_thickness/2])
                cube([mount_width, mount_length, mount_base_thickness], center=true);

            // PCB standoffs (4 corners)
            for (x = [-camera_hole_spacing/2, camera_hole_spacing/2]) {
                for (y = [-camera_hole_spacing/2, camera_hole_spacing/2]) {
                    translate([x, y, mount_base_thickness])
                        cylinder(d=6, h=mount_standoff_height, $fn=20);
                }
            }
        }

        // Mounting holes in standoffs (M2.5)
        for (x = [-camera_hole_spacing/2, camera_hole_spacing/2]) {
            for (y = [-camera_hole_spacing/2, camera_hole_spacing/2]) {
                translate([x, y, -1])
                    cylinder(d=camera_hole_diameter, h=mount_base_thickness + mount_standoff_height + 2, $fn=16);
            }
        }

        // Lens clearance hole in base
        translate([0, 0, -1])
            cylinder(d=camera_lens_diameter, h=mount_base_thickness + 2, $fn=32);

        // Cable channel for STEMMA QT connector
        translate([0, camera_pcb_size/2 + 2, mount_base_thickness/2])
            cube([10, stemma_clearance, mount_base_thickness + 1], center=true);

        // Wall mounting holes (for M3 screws)
        for (x = [-mount_width/2 + 5, mount_width/2 - 5]) {
            translate([x, -mount_length/2 + 5, -1])
                cylinder(d=3.2, h=mount_base_thickness + 2, $fn=16);
        }
    }

    // Lens hood (optional, helps with glare)
    if (false) {  // Set to true if needed
        translate([0, 0, mount_base_thickness + mount_standoff_height + camera_pcb_thickness]) {
            difference() {
                cylinder(d=camera_lens_diameter + 4, h=8, $fn=32);
                translate([0, 0, -1])
                    cylinder(d=camera_lens_diameter, h=10, $fn=32);
            }
        }
    }
}

// Assembly call
camera_mount();
