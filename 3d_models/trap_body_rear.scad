// ShopVac Rat Trap - Trap Body Rear Half
//
// Description:
// Rear half of the main trap body (125mm section).
// Connects to trap_body_front via twist lock at one end,
// and to vacuum_adapter via flange at the other.
// =========================================

include <trap_modules.scad>

// ========== CORE PARAMETERS ==========

// [Dimensions]
body_length = 125;  // Half of original 250mm
flat_base_height = 20;

// ========== MODULES ==========

module trap_body_rear() {
    difference() {
        union() {
            // Main tube body
            translate([0,0,body_length/2]) {
                cylinder(d=tube_od, h=body_length);
            }

            // Twist Lock Male at Center Joint (connects to front female)
            translate([0, 0, 0]) {
                rotate([180, 0, 0])
                    twist_lock_male();
            }

            // Flange at Funnel End (connects to universal adapter)
            // Universal adapter has a female socket or flange?
            // The universal adapter has a 101.6mm OD flange.
            // Let's make this a standard flat flange to mate with it.
            translate([0, 0, body_length]) {
                cylinder(d=101.6 + 10, h=5); // Flange
            }

            // Flat base for stability
            translate([-tube_od/2, -tube_od/2, 0]) {
                cube([tube_od, tube_od/2, body_length]);
            }
        }

        // Hollow Tube
        translate([0, 0, -20])
            cylinder(d=tube_id, h=body_length + 40);

        // Flange Mounting Holes
        translate([0, 0, body_length]) {
            for(r=[0:90:270]) {
                rotate([0, 0, r])
                translate([101.6/2 + 2, 0, -1])
                    cylinder(d=3.5, h=10);
            }
        }
    }
}

// ========== ASSEMBLY CALL ==========
trap_body_rear();
