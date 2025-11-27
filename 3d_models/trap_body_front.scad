// ShopVac Rat Trap - Trap Body Front Half
//
// Description:
// Front half of the main trap body (125mm section).
// Connects to trap_entrance via flange at one end,
// and to trap_body_rear via center flange joint at the other.
// =========================================

include <trap_modules.scad>

// ========== CORE PARAMETERS ==========

// [Dimensions]
body_length = 125;  // Half of original 250mm
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

module trap_body_front() {
    difference() {
        union() {
            // Main tube body
            translate([0,0,body_length/2]) {
                tube(body_length, tube_outer_diameter, tube_wall_thickness);
            }

            // Flange at entrance end (connects to trap_entrance)
            translate([0, 0, 0]) {
                flange(flange_diameter, flange_thickness, flange_screw_hole_diameter, flange_screw_hole_inset);
            }

            // Flange at center joint (connects to trap_body_rear)
            translate([0, 0, body_length]) {
                flange(flange_diameter, flange_thickness, flange_screw_hole_diameter, flange_screw_hole_inset);
            }

            // Flat base for stability
            translate([0, -tube_outer_diameter/2, 0]) {
                cube([tube_outer_diameter, tube_outer_diameter, flat_base_height]);
            }

            // Alignment pins for center joint (male)
            for (a = [0, 180]) {
                rotate([0, 0, a]) {
                    translate([alignment_pin_radius, 0, body_length]) {
                        cylinder(d=alignment_pin_diameter, h=alignment_pin_length, $fn=20);
                    }
                }
            }
        }

        // Cut away top of base to match tube profile
        translate([0,0,-1]) {
            cylinder(d=tube_outer_diameter, h=flat_base_height+2);
        }

        // Bait station port (positioned in front half)
        translate([0, 0, body_length - 50]) {
            rotate([90, 0, 0]) {
                difference() {
                    cylinder(d=bait_port_diameter + (2*bait_port_wall_thickness), h=tube_outer_diameter+2, center=true);
                    cylinder(d=bait_port_diameter, h=tube_outer_diameter+4, center=true);
                }
            }
        }

        // O-ring groove at center joint
        translate([0, 0, body_length - oring_groove_depth/2]) {
            rotate_extrude(convexity=10) {
                translate([tube_outer_diameter/2 - oring_groove_width/2, 0, 0]) {
                    square([oring_groove_width, oring_groove_depth], center=true);
                }
            }
        }
    }

    // Internal PIR sensor mount
    translate([pir_mount_offset_x, 0, body_length/2]) {
        rotate([90,0,90]) {
            union() {
                cube([pir_mount_thickness, pir_mount_width, pir_mount_height], center=true);
                // Support strut
                translate([0, 0, -pir_mount_height/2])
                    cube([pir_mount_thickness, pir_mount_width, 5], center=true);
            }
        }
    }
}

// ========== ASSEMBLY CALL ==========
trap_body_front();
