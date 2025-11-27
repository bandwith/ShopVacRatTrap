// Vacuum Funnel
//
// Description:
// Funnel adapter to connect the trap to a shop vacuum.
// =========================================

include <trap_modules.scad>

// ========== CORE PARAMETERS ==========

// [Dimensions]
funnel_height = 100;

// [Opening Diameters]
large_opening_diameter = tube_outer_diameter;

// Vacuum Hose Diameter (Inner Diameter of the funnel's small end)
// Common sizes:
// - 63.5 mm (2.5") - Standard US Shop Vac
// - 35 mm - Common European/Domestic Vacuums
// - 32 mm - Common Domestic Vacuums
vacuum_hose_diameter = 63.5;
small_opening_diameter = vacuum_hose_diameter;
wall_thickness = 3;

// ========== MODULES ==========

module vacuum_funnel() {
    union() {
        difference() {
            // Main funnel body
            // Shifted up by funnel_height/2 so the bottom is at Z=0 (relative to the flange if we flip it,
            // but here we want the flange at Z=0 for printing stability usually, or the large opening)

            // Let's orient it so the large opening (flange side) is at Z=0
            translate([0,0,funnel_height/2]) {
                cylinder(h = funnel_height, d1 = large_opening_diameter, d2 = small_opening_diameter, center=true);
            }

            // Hollow out the inside
            translate([0,0,funnel_height/2]) {
                 cylinder(h = funnel_height+2, d1 = large_opening_diameter - (2*wall_thickness), d2 = small_opening_diameter - (2*wall_thickness), center=true);
            }
        }

        // Flange at the large opening (Base)
        // Positioned at Z=0
        translate([0,0,0]) {
            flange(flange_diameter, flange_thickness, flange_screw_hole_diameter, flange_screw_hole_inset);
        }
    }
}

// ========== ASSEMBLY CALL ==========
vacuum_funnel();
