// ShopVac Rat Trap - Trap Body Rear Half
//
// Description:
// Rear half of the main trap body (125mm section).
// Connects to trap_body_front via center flange joint at one end,
// and to trap_funnel_adapter via flange at the other.
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
                tube(body_length, tube_outer_diameter, tube_wall_thickness);
            }

            // Flange at center joint (connects to trap_body_front)
            translate([0, 0, 0]) {
                flange(flange_diameter, flange_thickness, flange_screw_hole_diameter, flange_screw_hole_inset);
            }

            // Flange at funnel end (connects to trap_funnel_adapter)
            translate([0, 0, body_length]) {
                flange(flange_diameter, flange_thickness, flange_screw_hole_diameter, flange_screw_hole_inset);
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

        // Alignment pin holes for center joint (female)
        for (a = [0, 180]) {
            rotate([0, 0, a]) {
                translate([alignment_pin_radius, 0, -1]) {
                    cylinder(d=alignment_pin_diameter + alignment_pin_clearance,
                            h=alignment_pin_length + 2, $fn=20);
                }
            }
        }
    }
}

// ========== ASSEMBLY CALL ==========
trap_body_rear();
