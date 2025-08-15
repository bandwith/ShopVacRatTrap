// Modular Bait Holder for CONTRAC Blox with Lumitrack
// Designed to be a separate, serviceable part that attaches to the main trap tube.

// ========== PARAMETERS ==========

// Bait Block Dimensions (CONTRAC All-Weather Blox)
bait_block_width = 45;  // mm (1.75 in)
bait_block_depth = 26;  // mm (1 in)
bait_block_height = 26; // mm (1 in)
bait_block_hole_d = 8; // mm (approximate diameter of the center hole)

// Holder Dimensions
base_plate_width = 60;
base_plate_depth = 40;
base_plate_thickness = 4;
rod_height = bait_block_height + 10;
rod_diameter = bait_block_hole_d - 1; // Slightly smaller for clearance

// Attachment Mechanism (Slide-in Rail)
rail_width = 30;
rail_thickness = 3;
rail_tongue_thickness = 1.5;
rail_groove_tolerance = 0.4;

$fn = 64;

// ========== MODULES ==========

module bait_holder() {
    union() {
        // Base plate
        cube([base_plate_width, base_plate_depth, base_plate_thickness]);

        // Bait securing rod
        translate([base_plate_width / 2, base_plate_depth / 2, base_plate_thickness]) {
            cylinder(h = rod_height, d = rod_diameter);
        }

        // Attachment rail (tongue part)
        translate([(base_plate_width - rail_width) / 2, base_plate_depth, 0]) {
            cube([rail_width, rail_thickness, base_plate_thickness]);
            translate([0, 0, base_plate_thickness]) {
                cube([rail_width, rail_thickness, rail_tongue_thickness]);
            }
        }
    }
}

// --- Visualization ---
// Show the bait holder with a representation of the bait block

module assembly_visualization() {
    // Bait holder
    color("darkgrey")
    bait_holder();

    // Bait block representation
    color("blue", 0.5)
    translate([
        (base_plate_width - bait_block_width) / 2,
        (base_plate_depth - bait_block_depth) / 2,
        base_plate_thickness
    ]) {
        difference() {
            cube([bait_block_width, bait_block_depth, bait_block_height]);
            translate([bait_block_width/2, bait_block_depth/2, -1])
            cylinder(h = bait_block_height + 2, d = bait_block_hole_d);
        }
    }
}


// ========== ASSEMBLY CALL ==========
assembly_visualization();
