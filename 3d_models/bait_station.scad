// ShopVac Rat Trap 2025 - Bait Station
// Engineer: Gemini
// Date: 2025-08-15
//
// ========== REVISION HIGHLIGHTS ==========
// - NEW: Removable bait station for easy baiting.
// - NEW: Plugs into the main trap body from the top.
// - NEW: Vented design to disperse bait scent.
// - NEW: Simple friction-fit locking mechanism.
// =========================================

// ========== CORE PARAMETERS ==========

// [Dimensions - Must match bait_port in trap_body_main.scad]
bait_port_diameter = 40;
bait_port_length = 20;

// [Bait Compartment]
bait_compartment_diameter = bait_port_diameter - 10;
bait_compartment_depth = 40;

// [Handle]
handle_diameter = bait_port_diameter + 10;
handle_height = 15;

// [Locking Nub]
nub_diameter = 2;
nub_height = 1;

$fn = 64;

// ========== MODULES ==========

module bait_station() {
    difference() {
        union() {
            // Main body
            cylinder(h = bait_port_length + bait_compartment_depth, d = bait_port_diameter - 0.2); // Tolerance

            // Handle
            translate([0, 0, bait_port_length + bait_compartment_depth]) {
                cylinder(h = handle_height, d = handle_diameter);
            }
        }

        // Bait compartment
        translate([0, 0, -1]) {
            cylinder(h = bait_compartment_depth + 2, d = bait_compartment_diameter);
        }

        // Scent holes
        for (a = [0, 72, 144, 216, 288]) {
            rotate([0, 0, a]) {
                translate([bait_compartment_diameter / 2, 0, 10]) {
                    rotate([90, 0, 0]) {
                        cylinder(h = 20, d = 3);
                    }
                }
            }
        }
    }

    // Locking nub
    translate([bait_port_diameter / 2 - nub_diameter, 0, bait_port_length - 5]) {
        cylinder(h = nub_height, d = nub_diameter);
    }
}

// ========== ASSEMBLY CALL ==========
bait_station();
