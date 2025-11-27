// ShopVac Rat Trap - Bait Station
//
// Description:
// Bait station with secure screw-in locking mechanism.
// =========================================

// ========== CORE PARAMETERS ==========
$fn = 64;

// [Dimensions - Must match bait_port in trap_body_main.scad]
bait_port_diameter = 40;
bait_port_length = 20;

// [Bait Compartment]
bait_compartment_diameter = bait_port_diameter - 4;
bait_compartment_depth = 50;

// [Handle]
handle_diameter = bait_port_diameter + 20;
handle_height = 15;

// [Locking Lugs]
lug_width = 10;
lug_height = 4;
lug_depth = 3;

// ========== MODULES ==========

module bait_station() {
    union() {
        difference() {
            // Main body
            cylinder(d=bait_port_diameter - 0.5, h=bait_port_length + bait_compartment_depth, center=true);

            // Bait compartment
            translate([0,0, -bait_port_length/2 - 1]) {
                cylinder(d=bait_compartment_diameter, h=bait_compartment_depth+2, center=true);
            }

            // Scent holes
            for (a = [0, 72, 144, 216, 288]) {
                rotate([0, 0, a]) {
                    translate([bait_compartment_diameter / 2 - 3, 0, -15]) {
                        rotate([90, 0, 0]) {
                            cylinder(h = 15, d = 4, center=true);
                        }
                    }
                }
            }
        }

        // Handle
        translate([0, 0, (bait_port_length + bait_compartment_depth)/2]) {
            cylinder(d=handle_diameter, h=handle_height, center=true);
            // Add an arrow indicator for locking direction
            translate([0, handle_diameter/2 - 5, handle_height/2]) {
                rotate([90,0,0]) {
                    linear_extrude(height=2) {
                        polygon(points=[[-3,0],[3,0],[0,5]]);
                    }
                }
            }
        }

        // Locking lugs
        for (r = [0, 180]) {
            rotate([0,0,r]) {
                translate([0, bait_port_diameter/2 - lug_depth/2, bait_port_length/2 - lug_height/2]) {
                    cube([lug_width, lug_depth, lug_height], center=true);
                }
            }
        }
    }
}

// ========== ASSEMBLY CALL ==========
bait_station();
