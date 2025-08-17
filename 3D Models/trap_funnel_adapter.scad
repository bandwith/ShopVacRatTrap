// ShopVac Rat Trap 2025 - Funnel Adapter
// Engineer: Gemini
// Date: 2025-08-15
//
// ========== REVISION HIGHLIGHTS ==========
// - NEW: Funnel adapter to connect the trap to a shop vacuum.
// - NEW: Modular design with a snap-fit connection to the main trap body.
// - NEW: Parametric nozzle to support various vacuum hose sizes.
// =========================================

// ========== CORE PARAMETERS ==========

// [Dimensions]
tube_diameter = 101.6; // 4 inches
tube_wall_thickness = 4;
funnel_length = 150;
flat_base_height = 20;

// [Nozzle Dimensions]
nozzle_diameter = 63.5; // 2.5 inches
nozzle_length = 50;

// [Snap-Fit Connector Parameters - Must match trap_body_main.scad]
clip_width = 15;
clip_thickness = 3;
clip_length = 20;
clip_hook_depth = 2;

$fn = 128;

// ========== MODULES ==========

module snap_fit_clip() {
    // Cantilever snap-fit clip
    difference() {
        cube([clip_thickness, clip_width, clip_length]);
        translate([clip_thickness, 0, clip_length - clip_hook_depth]) {
            cube([clip_thickness, clip_width, clip_hook_depth * 2]);
        }
    }
    translate([-clip_hook_depth, 0, clip_length - clip_hook_depth]) {
        cube([clip_hook_depth, clip_width, clip_hook_depth]);
    }
}

module trap_funnel_adapter() {
    difference() {
        union() {
            // Main funnel body
            cylinder(h = funnel_length, d1 = tube_diameter + (2 * tube_wall_thickness), d2 = nozzle_diameter + (2 * tube_wall_thickness), center = false);

            // Flat base
            translate([- (tube_diameter / 2) - tube_wall_thickness, -tube_diameter / 2, 0]) {
                cube([tube_diameter + (2 * tube_wall_thickness), tube_diameter, flat_base_height]);
            }
        }

        // Hollow out the inside
        translate([0, 0, -1]) {
            cylinder(h = funnel_length + 2, d1 = tube_diameter, d2 = nozzle_diameter, center = false);
        }

        // Cut away the top of the flat base to match the funnel
        translate([0, 0, flat_base_height]) {
            cylinder(h = funnel_length, d1 = tube_diameter + (2 * tube_wall_thickness) + 2, d2 = nozzle_diameter + (2 * tube_wall_thickness) + 2, center = false);
        }
    }

    // Add snap-fit clips
    for (a = [90, 270]) {
        rotate([0, 0, a]) {
            translate([tube_diameter / 2 + tube_wall_thickness, -clip_width / 2, 20]) {
                snap_fit_clip();
            }
        }
    }
}

// ========== ASSEMBLY CALL ==========
trap_funnel_adapter();
