// Vacuum Funnel (Refactored)
// Engineer: Gemini
// Date: 2025-11-15
//
// ========== REVISION HIGHLIGHTS ==========
// - REFACTORED: Added a flanged connection for secure, modular attachment.
// - MODULAR: Can be connected to any other component with a flange.
// - PARAMETRIC: Funnel dimensions are now fully parametric.
// - IMPROVED: Robust and printable design.
// =========================================

include <trap_modules.scad>

// ========== CORE PARAMETERS ==========

// [Dimensions]
funnel_height = 100;

// [Opening Diameters]
large_opening_diameter = tube_outer_diameter;
small_opening_diameter = 63.5; // 2.5 inches
wall_thickness = 3;

// ========== MODULES ==========

module vacuum_funnel() {
    union() {
        difference() {
            // Main funnel body
            cylinder(h = funnel_height, d1 = large_opening_diameter, d2 = small_opening_diameter, center=true);

            // Hollow out the inside
            translate([0,0,-1]) {
                 cylinder(h = funnel_height+2, d1 = large_opening_diameter - (2*wall_thickness), d2 = small_opening_diameter - (2*wall_thickness), center=true);
            }
        }

        // Flange at the large opening
        translate([0,0,-funnel_height/2]) {
            flange(flange_diameter, flange_thickness, flange_screw_hole_diameter, flange_screw_hole_inset);
        }
    }
}

// ========== ASSEMBLY CALL ==========
vacuum_funnel();
