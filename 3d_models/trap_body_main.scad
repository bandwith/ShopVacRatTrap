// ShopVac Rat Trap - Main Trap Body
//
// Description:
// Main body of the trap featuring a robust flanged connection system,
// modular design using shared components, and integrated mounting points.
// Includes a flat base for stability.
// =========================================

include <trap_modules.scad>

// ========== CORE PARAMETERS ==========

// [Dimensions]
body_length = 250;
flat_base_height = 20;

// [Bait Station Port]
bait_port_diameter = 40;
bait_port_length = 20;
bait_port_wall_thickness = 3;

// [PIR Sensor Mount]
pir_mount_offset_x = 50;
pir_mount_width = 30;
pir_mount_height = 25;
pir_mount_thickness = 3;

// ========== MODULES ==========

module trap_body_main() {
    difference() {
        union() {
            // Main tube body
            translate([0,0,body_length/2]) {
                tube(body_length, tube_outer_diameter, tube_wall_thickness);
            }

            // Flanges at both ends
            for (z_pos = [0, body_length]) {
                translate([0, 0, z_pos]) {
                    flange(flange_diameter, flange_thickness, flange_screw_hole_diameter, flange_screw_hole_inset);
                }
            }

            // Flat base for stability
            translate([0, -tube_outer_diameter/2, 0]) {
                cube([tube_outer_diameter, tube_outer_diameter, flat_base_height]);
            }
        }

        // Cut away top of base to match tube profile
        translate([0,0,-1]) {
            cylinder(d=tube_outer_diameter, h=flat_base_height+2);
        }

        // Bait station port
        translate([0, 0, body_length - 50]) {
            rotate([90, 0, 0]) {
                 difference() {
                    cylinder(d=bait_port_diameter + (2*bait_port_wall_thickness), h=tube_outer_diameter+2, center=true);
                    cylinder(d=bait_port_diameter, h=tube_outer_diameter+4, center=true);
                }
            }
        }
    }

    // Internal PIR sensor mount - Connected to body
    translate([pir_mount_offset_x, 0, body_length/2]) {
        rotate([90,0,90]) {
            union() {
                cube([pir_mount_thickness, pir_mount_width, pir_mount_height], center=true);
                // Support strut to connect to wall if needed, or ensure it intersects
                // In this case, we ensure the mount base intersects with the tube wall
                translate([0, 0, -pir_mount_height/2])
                    cube([pir_mount_thickness, pir_mount_width, 5], center=true);
            }
        }
    }
}

// ========== ASSEMBLY CALL ==========
trap_body_main();
