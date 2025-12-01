// ShopVac Rat Trap - Flat Ramp Entrance
// Replaces cone funnel with printable flat ramp/archway design
// Date: 2025-11-29

include <trap_modules.scad>

// ========== CORE PARAMETERS ==========

// [Dimensions]
ramp_length = 150;          // Total length of ramp approach
ramp_width = 160;           // Wide base for stability
ramp_height = 40;           // Height at entrance (matches tube bottom)
wall_thickness = 3;

// [Ramp Profile]
ramp_angle = 15;            // Gentle slope for rodent entry
archway_height = 65;        // Height of archway opening
archway_width = 95;         // Width of archway opening

// ========== MODULES ==========

module trap_ramp_entrance() {
    difference() {
        union() {
            // Base ramp body (flat wedge)
            translate([0, -ramp_width/2, 0]) {
                hull() {
                    // Front edge (low, at origin)
                    cube([0.1, ramp_width, wall_thickness]);

                    // Back edge (connects to flange)
                    translate([ramp_length, 0, ramp_height])
                        cube([0.1, ramp_width, wall_thickness]);
                }
            }

            // Side walls (archway sides)
            translate([0, -ramp_width/2, 0]) {
                // Left wall
                hull() {
                    cube([0.1, wall_thickness, wall_thickness]);
                    translate([ramp_length, 0, archway_height])
                        cube([0.1, wall_thickness, wall_thickness]);
                }
            }

            translate([0, ramp_width/2 - wall_thickness, 0]) {
                // Right wall
                hull() {
                    cube([0.1, wall_thickness, wall_thickness]);
                    translate([ramp_length, 0, archway_height])
                        cube([0.1, wall_thickness, wall_thickness]);
                }
            }

            // Archway top
            translate([ramp_length - 10, -ramp_width/2, archway_height]) {
                cube([10, ramp_width, wall_thickness]);
            }

            // Connection to Trap Body (Twist Lock Female)
            translate([ramp_length, 0, tube_od/2]) {
                rotate([0, 90, 0])
                    twist_lock_female();
            }

            // Anti-roll feet / Wide Base
            translate([ramp_length - 20, -ramp_width/2, 0])
                cube([20, ramp_width, 5]);
        }

        // Cut out for tube connection
        translate([ramp_length - 1, 0, tube_od/2]) {
            rotate([0, 90, 0])
                cylinder(d=tube_id, h=25, $fn=64);
        }
    }
}

// ========== ASSEMBLY CALL ==========
trap_ramp_entrance();
