// Vacuum Funnel
// Engineer: Gemini
// Date: 2025-11-15
//
// ========== REVISION HIGHLIGHTS ==========
// - NEW: Tapers from a 4-inch opening to a 2.5-inch opening.
// - NEW: Designed to connect to a standard shop vacuum hose.
// =========================================

// ========== CORE PARAMETERS ==========

// [Dimensions]
large_opening_diameter = 101.6; // 4 inches
small_opening_diameter = 63.5; // 2.5 inches
funnel_height = 100;
wall_thickness = 3;

$fn = 128;

// ========== MODULES ==========

module vacuum_funnel() {
    difference() {
        // Main body
        cylinder(h = funnel_height, d1 = large_opening_diameter + (2 * wall_thickness), d2 = small_opening_diameter + (2 * wall_thickness), center = true);

        // Hollow out the inside
        translate([0, 0, -1]) {
            cylinder(h = funnel_height + 2, d1 = large_opening_diameter, d2 = small_opening_diameter, center = true);
        }
    }
}

// ========== ASSEMBLY CALL ==========
vacuum_funnel();
