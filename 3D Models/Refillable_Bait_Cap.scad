// ShopVac Rat Trap 2025 - Refillable Bait Cap
// ====================================================================
// BAIT SYSTEM: External refillable bait compartment cap
// ====================================================================
// PURPOSE: Threaded cap for secure, weatherproof bait compartment access
// FEATURES: Easy field refilling, weatherproof seal, gnaw-resistant construction
// THREAD: Compatible with main trap tube bait compartment
// LABELS: Clear identification and instructions

// ========== BAIT CAP PARAMETERS ==========

// Cap dimensions (matching main tube bait compartment)
bait_cap_diameter = 35;         // mm - external diameter
bait_cap_height = 15;           // mm - total cap height
bait_cap_thread_pitch = 2;      // mm - thread pitch (matches main tube)
bait_cap_wall_thickness = 3;    // mm - wall thickness for strength

// Sealing parameters
o_ring_groove_diameter = 30;    // mm - O-ring groove diameter
o_ring_groove_width = 2;        // mm - O-ring groove width
o_ring_groove_depth = 1;        // mm - O-ring groove depth

// Grip features for easy field removal
grip_ridge_count = 8;           // Number of grip ridges
grip_ridge_height = 2;          // mm - height of grip ridges
grip_ridge_width = 3;           // mm - width of grip ridges

// Label parameters
label_depth = 0.8;              // mm - embossed text depth
label_font_size = 4;            // mm - font size
label_font = "Liberation Sans:style=Bold";
small_label_size = 3;           // mm - smaller font

$fn = 64;                      // High resolution for smooth threads

// ========== MAIN BAIT CAP MODULE ==========

module refillable_bait_cap() {
    union() {
        // Main cap body with threads
        main_cap_body();

        // Grip ridges for easy removal
        grip_ridges();

        // Identification labels
        bait_cap_labels();
    }
}

module main_cap_body() {
    difference() {
        union() {
            // Main cylindrical cap
            cylinder(h = bait_cap_height, d = bait_cap_diameter, $fn = $fn);

            // Threaded section
            threaded_section();
        }

        // O-ring sealing groove
        translate([0, 0, 3]) {
            rotate_extrude() {
                translate([o_ring_groove_diameter/2, 0, 0]) {
                    circle(d = o_ring_groove_width);
                }
            }
        }

        // Internal cavity for bait access
        translate([0, 0, -1]) {
            cylinder(h = bait_cap_height - 2, d = bait_cap_diameter - 2*bait_cap_wall_thickness, $fn = $fn);
        }
    }
}

module threaded_section() {
    // External threads for secure attachment
    for (thread_turn = [0:0.5:bait_cap_thread_pitch*3]) {
        translate([0, 0, thread_turn]) {
            rotate([0, 0, thread_turn * 180 / bait_cap_thread_pitch]) {
                translate([bait_cap_diameter/2 - 1, 0, 0]) {
                    cube([2, 1.5, 0.8], center = true);
                }
            }
        }
    }
}

module grip_ridges() {
    // Radial grip ridges for easy field removal
    for (i = [0:grip_ridge_count-1]) {
        rotate([0, 0, i * 360/grip_ridge_count]) {
            translate([bait_cap_diameter/2, 0, bait_cap_height/2]) {
                cube([grip_ridge_height, grip_ridge_width, bait_cap_height], center = true);
            }
        }
    }
}

module bait_cap_labels() {
    // Main "BAIT" label on top
    translate([0, 0, bait_cap_height + label_depth]) {
        linear_extrude(height = label_depth) {
            text("BAIT", size = label_font_size, font = label_font, halign = "center", valign = "center");
        }
    }

    // Directional arrow indicating removal direction
    translate([0, -8, bait_cap_height + label_depth]) {
        linear_extrude(height = label_depth) {
            text("← TURN", size = small_label_size, font = label_font, halign = "center", valign = "center");
        }
    }

    // Side label for identification
    translate([bait_cap_diameter/2 + label_depth, 0, bait_cap_height/2]) {
        rotate([0, 0, 90]) {
            rotate([90, 0, 0]) {
                linear_extrude(height = label_depth) {
                    text("REFILL", size = small_label_size, font = label_font, halign = "center", valign = "center");
                }
            }
        }
    }
}

// ========== ASSEMBLY CALL ==========

// Generate the bait cap
refillable_bait_cap();
