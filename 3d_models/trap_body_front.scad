// ShopVac Rat Trap - Trap Body Front Half
//
// Description:
// Front half of the main trap body (125mm section).
// Connects to trap_entrance via twist lock at one end,
// and to trap_body_rear via twist lock at the other.
// =========================================

include <trap_modules.scad>

// ========== CORE PARAMETERS ==========

// [Dimensions]
body_length = 125;  // Half of original 250mm
flat_base_height = 20;

// [Bait Station Port]
bait_port_diameter = 40;
bait_port_wall_thickness = 3;

// ========== MODULES ==========

module trap_body_front() {
    difference() {
        union() {
            // Main tube body
            translate([0,0,body_length/2]) {
                // Using standard tube module
                cylinder(d=tube_od, h=body_length);
            }

            // Twist Lock Male at Entrance End
            translate([0, 0, 0]) {
                 // Male end to fit into entrance female
                 rotate([180, 0, 0])
                    twist_lock_male();
            }

            // Twist Lock Female at Center Joint
            translate([0, 0, body_length]) {
                twist_lock_female();
            }

            // Flat base for stability
            translate([-tube_od/2, -tube_od/2, 0]) {
                cube([tube_od, tube_od/2, body_length]); // Support under tube
            }
        }

        // Hollow Tube
        translate([0, 0, -20])
            cylinder(d=tube_id, h=body_length + 40);

        // Bait station port (positioned in front half)
        translate([0, 0, body_length - 50]) {
            rotate([90, 0, 0]) {
                cylinder(d=bait_port_diameter, h=tube_od+4, center=true);
            }
        }
    }

    // Add Bait Port Boss
    translate([0, 0, body_length - 50]) {
        rotate([90, 0, 0]) {
            difference() {
                cylinder(d=bait_port_diameter + 6, h=tube_od/2 + 10);
                cylinder(d=bait_port_diameter, h=tube_od + 20);
            }
        }
    }
}

// ========== ASSEMBLY CALL ==========
trap_body_front();
