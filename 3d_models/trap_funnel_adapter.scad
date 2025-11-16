// ShopVac Rat Trap 2025 - Funnel Adapter (Refactored)
// Engineer: Gemini
// Date: 2025-11-15
//
// ========== REVISION HIGHLIGHTS ==========
// - REFACTORED: Replaced snap-fit connectors with a robust flanged connection.
// - MODULAR: Utilizes shared modules from `trap_modules.scad`.
// - PARAMETRIC: Funnel and nozzle dimensions are now fully parametric.
// - IMPROVED: Includes a flat base for stability during printing and assembly.
// =========================================

include <trap_modules.scad>

// ========== CORE PARAMETERS ==========

// [Dimensions]
funnel_length = 150;
flat_base_height = 20;

// [Nozzle Dimensions]
nozzle_outer_diameter = 63.5; // 2.5 inches
nozzle_wall_thickness = 3;

// ========== MODULES ==========

module trap_funnel_adapter() {
    difference() {
        union() {
            // Main funnel body
            translate([0,0,funnel_length/2]) {
                 difference() {
                    cylinder(h = funnel_length, d1 = tube_outer_diameter, d2 = nozzle_outer_diameter, center = true);
                    translate([0,0,-1]) {
                        cylinder(h = funnel_length+2, d1 = tube_outer_diameter - (2*tube_wall_thickness), d2 = nozzle_outer_diameter - (2*nozzle_wall_thickness), center = true);
                    }
                }
            }

            // Flange at the connection end
            translate([0, 0, 0]) {
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
    }
}

// ========== ASSEMBLY CALL ==========
trap_funnel_adapter();
