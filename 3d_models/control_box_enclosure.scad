// ShopVac Rat Trap - Standalone Control Box
// Fully printable, rodent-resistant, tool-free assembly
// Features: Sliding lid, internal cable routing, snap-fit mounting

$fn = 60;

// ========== DIMENSIONS ==========
// Internal dimensions to fit components
internal_length = 140;
internal_width = 100;
internal_height = 60;
wall_thickness = 4; // Thick walls for rodent resistance

// Component Dimensions (from BOM)
psu_length = 99; psu_width = 82; psu_height = 30;
ssr_length = 58; ssr_width = 40; ssr_height = 25.5;
feather_length = 51; feather_width = 23;

// ========== MODULES ==========

module rounded_box(x, y, z, r) {
    translate([r, r, 0])
    minkowski() {
        cube([x - 2*r, y - 2*r, z - 1]); // z-1 because cylinder is h=1 (effectively)
        cylinder(r=r, h=1);
    }
}

module control_box_base() {
    difference() {
        // Outer Shell
        rounded_box(internal_length + 2*wall_thickness,
                   internal_width + 2*wall_thickness,
                   internal_height + wall_thickness,
                   3);

        // Inner Cavity
        translate([wall_thickness, wall_thickness, wall_thickness])
            rounded_box(internal_length, internal_width, internal_height + 10, 1);

        // Sliding Lid Grooves (Dovetail)
        translate([wall_thickness, wall_thickness, internal_height + wall_thickness - 4]) {
            // Left Groove
            translate([-2, 0, 0])
                rotate([0, 90, 0])
                linear_extrude(internal_length + 2*wall_thickness)
                polygon([[0,0], [4,2], [0,4]]);

            // Right Groove
            translate([internal_width + 2, 0, 0])
                rotate([0, 90, 0])
                linear_extrude(internal_length + 2*wall_thickness)
                polygon([[0,0], [-4,2], [0,4]]);
        }

        // Cable Ports (Rear)
        // Designed to mate with trap body cable channels
        translate([internal_length/2 + wall_thickness, internal_width + 2*wall_thickness + 1, 15])
            rotate([90, 0, 0])
            cylinder(d=12, h=wall_thickness + 5); // Main cable trunk

        // Vent Holes (Rodent proof < 5mm)
        for(i=[0:5]) {
            translate([20 + i*15, -1, 40])
                rotate([-90, 0, 0])
                cylinder(d=3, h=wall_thickness + 2);
        }
    }

    // === INTERNAL MOUNTS ===
    translate([wall_thickness, wall_thickness, wall_thickness]) {
        // PSU Mounts (Snap-fit clips or standoffs)
        translate([10, 10, 0]) {
            // Simple standoffs for now, user can glue or use printed pegs
            cylinder(d=8, h=5);
            translate([psu_length-5, 0, 0]) cylinder(d=8, h=5);
            translate([0, psu_width-5, 0]) cylinder(d=8, h=5);
            translate([psu_length-5, psu_width-5, 0]) cylinder(d=8, h=5);
        }

        // Feather Mount (Raised platform)
        translate([internal_length - feather_length - 10, 10, 0]) {
            difference() {
                cube([feather_length + 4, feather_width + 4, 10]);
                translate([2, 2, 2])
                    cube([feather_length, feather_width, 10]);
            }
        }
    }

    // === EXTERNAL MOUNTING CLIPS ===
    // Snap clips to attach to trap body
    translate([internal_length/2, -5, 0]) {
        difference() {
            cube([40, 5, 60]);
            translate([5, -1, 10])
                cube([30, 7, 40]); // Hollow out
        }
    }
}

module control_box_lid() {
    lid_width = internal_width + 2*wall_thickness - 2; // Tolerance
    lid_length = internal_length + 2*wall_thickness;

    difference() {
        union() {
            // Main plate
            cube([lid_length, lid_width, 4]);

            // Dovetail rails
            translate([0, 0, 0]) {
                // Left Rail
                rotate([0, 90, 0])
                linear_extrude(lid_length)
                polygon([[0,0], [4,2], [0,4]]);

                // Right Rail
                translate([0, lid_width, 0])
                rotate([0, 90, 0])
                linear_extrude(lid_length)
                polygon([[0,0], [-4,2], [0,4]]);
            }

            // Handle / Grip
            translate([lid_length - 20, lid_width/2, 4])
                cylinder(d=15, h=5);
        }
    }
}

// Render
control_box_base();

translate([0, -internal_width - 20, 0])
    control_box_lid();
