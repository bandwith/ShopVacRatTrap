// ShopVac Rat Trap - Control Box Enclosure
// Hammond PN-1334-C Footprint with Actual BOM Components
// Updated: 2024-11-27

// ========== ENCLOSURE DIMENSIONS (Hammond PN-1334-C) ==========
// External: 200×120×75mm, Internal usable: 192×112×69mm

$fn = 60;

// Base enclosure (custom to fit inside Hammond)
box_length = 192;        // Fits Hammond internal length
box_width = 112;         // Fits Hammond internal width
box_height = 65;         // Internal height
wall_thickness = 3;

// ========== COMPONENT DIMENSIONS (From BOM) ==========

// Mean Well LRS-35-5 PSU
psu_length = 99;
psu_width = 82;
psu_height = 30;
psu_mount_holes = 82;    // M4 hole spacing

// Panasonic AQA411VL SSR
ssr_width = 40;
ssr_length = 58;
ssr_height = 25.5;

// ESP32-S3 Feather
feather_length = 50.8;
feather_width = 22.9;
feather_hole_spacing_l = 48.26;
feather_hole_spacing_w = 20.32;
feather_standoff = 5;

// OLED Display (Adafruit 326)
display_pcb_width = 27;
display_pcb_height = 27.5;
display_area_width = 21.7;
display_area_height = 10.9;

// Panel cutouts
estop_diameter = 16;     // Schneider XB6ETN521P
button_diameter = 24;    // Arcade button
iec_inlet_w = 27.5;      // Schurter IEC inlet
iec_inlet_h = 47.5;
cable_gland_diameter = 20; // PG13.5

// ========== COMPONENT POSITIONS ==========

// PSU position (bottom-left, rear)
psu_x = 15;
psu_y = 15;
psu_z = 5;  // Standoff for airflow

// SSR position (rear wall, upper left)
ssr_x = 45;
ssr_z = 45;  // From bottom

// Feather position (center-right)
feather_x = 130;
feather_y = 45;
feather_z = feather_standoff;

// Front panel cutouts (from bottom-left when viewing front)
display_x = box_length / 2;        // Centered
display_y = box_width / 2 + 10;    // Slightly upper center

estop_x = box_length - 60;         // Upper right
estop_y = box_width - 25;

button_x = 60;                      // Lower left
button_y = 25;

// Rear panel cutouts
iec_inlet_x = 40;
iec_inlet_y = box_width / 2;

cable_gland_x = box_length / 2;
cable_gland_y = box_width / 3;

iec_outlet_x = box_length - 50;
iec_outlet_y = box_width / 2;

// ========== MODULES ==========

module enclosure_body() {
    difference() {
        // Outer shell
        cube([box_length + 2*wall_thickness,
              box_width + 2*wall_thickness,
              box_height + wall_thickness]);

        // Hollow interior
        translate([wall_thickness, wall_thickness, wall_thickness])
            cube([box_length, box_width, box_height + 1]);

        // === FRONT PANEL CUTOUTS ===

        // OLED Display cutout (rectangular for display area)
        translate([display_x, -1, box_height - display_y]) {
            cube([display_area_width, wall_thickness + 2, display_area_height], center=true);
        }

        // E-Stop cutout (16mm hole)
        translate([estop_x, -1, box_height - estop_y]) {
            rotate([-90, 0, 0])
                cylinder(d=estop_diameter, h=wall_thickness + 2);
        }

        // Manual button cutout (24mm hole)
        translate([button_x, -1, box_height - button_y]) {
            rotate([-90, 0, 0])
                cylinder(d=button_diameter, h=wall_thickness + 2);
        }

        // === REAR PANEL CUTOUTS ===

        // IEC Inlet (rectangular)
        translate([iec_inlet_x, box_width + 2*wall_thickness + 1, box_height - iec_inlet_y]) {
            rotate([90, 0, 0])
                cube([iec_inlet_w, iec_inlet_h, wall_thickness + 2], center=true);
        }

        // Cable gland (round, PG13.5)
        translate([cable_gland_x, box_width + 2*wall_thickness + 1, cable_gland_y]) {
            rotate([90, 0, 0])
                cylinder(d=cable_gland_diameter, h=wall_thickness + 2);
        }

        // IEC Outlet (rectangular)
        translate([iec_outlet_x, box_width + 2*wall_thickness + 1, box_height - iec_outlet_y]) {
            rotate([90, 0, 0])
                cube([30, 52, wall_thickness + 2], center=true);
        }

        // === VENTILATION ===

        // Bottom vents (near PSU, 5× 10mm holes)
        for (i = [0:4]) {
            translate([psu_x + 20 + i*15, psu_y + 40, -1])
                cylinder(d=10, h=wall_thickness + 2, $fn=30);
        }

        // Top vents (opposite side, 5× 10mm holes)
        for (i = [0:4]) {
            translate([box_length - psu_x - 20 - i*15,
                      box_width - psu_y - 40,
                      box_height - 1])
                cylinder(d=10, h=wall_thickness + 2, $fn=30);
        }
    }

    // === INTERNAL MOUNTING FEATURES ===

    // PSU mounting standoffs (4× M4)
    translate([wall_thickness, wall_thickness, 0]) {
        for (x = [0, psu_length - 5]) {
            for (y = [0, psu_width - 5]) {
                translate([psu_x + x, psu_y + y, wall_thickness]) {
                    difference() {
                        cylinder(d=8, h=psu_z, $fn=30);
                        translate([0, 0, psu_z - 8])
                            cylinder(d=4.2, h=9, $fn=20);  // M4 hole
                    }
                }
            }
        }
    }

    // SSR mounting plate (on rear wall)
    translate([wall_thickness, wall_thickness, 0]) {
        translate([ssr_x - 5, box_width - 3, ssr_z - 5]) {
            difference() {
                cube([ssr_width + 10, 3, ssr_length + 10]);
                // SSR mounting holes (2× M3.5)
                for (z = [10, ssr_length]) {
                    translate([ssr_width/2 + 5, 4, z])
                        rotate([90, 0, 0])
                            cylinder(d=3.7, h=5, $fn=20);
                }
            }
        }
    }

    // Feather mounting plate base
    translate([wall_thickness + feather_x - 5,
              wall_thickness + feather_y - 5,
              wall_thickness]) {
        cube([feather_length + 10, feather_width + 10, 2]);

        // Standoff posts (4× M2.5)
        for (x = [(feather_length - feather_hole_spacing_l)/2,
                  (feather_length - feather_hole_spacing_l)/2 + feather_hole_spacing_l]) {
            for (y = [(feather_width - feather_hole_spacing_w)/2,
                      (feather_width - feather_hole_spacing_w)/2 + feather_hole_spacing_w]) {
                translate([x + 5, y + 5, 2]) {
                    difference() {
                        cylinder(d=5, h=feather_standoff, $fn=20);
                        translate([0, 0, feather_standoff - 6])
                            cylinder(d=2.7, h=7, $fn=16);  // M2.5 hole
                    }
                }
            }
        }
    }

    // Wire management channels
    translate([wall_thickness, wall_thickness, wall_thickness]) {
        // AC wire channel (left side)
        translate([10, 0, 0])
            cube([5, box_width, 2]);

        // DC wire channel (right side)
        translate([box_length - 15, 0, 0])
            cube([5, box_width, 2]);
    }

    // Zip tie anchor points
    for (x = [30, box_length/2, box_length - 30]) {
        translate([wall_thickness + x, wall_thickness + 10, wall_thickness]) {
            difference() {
                cube([8, 5, 5]);
                translate([4, 2.5, 2.5])
                    rotate([0, 90, 0])
                        cylinder(d=3, h=10, center=true, $fn=20);
            }
        }
    }
}

module display_bezel() {
    // Front-mounting bezel for OLED display
    bezel_width = 35;
    bezel_height = 35;
    bezel_thickness = 2;

    difference() {
        // Bezel frame
        cube([bezel_width, bezel_height, bezel_thickness], center=true);

        // Display window
        cube([display_area_width + 1, display_area_height + 1, bezel_thickness + 2], center=true);

        // Mounting holes for M2.5 (2 holes)
        for (x = [-12, 12]) {
            translate([x, 12, 0])
                cylinder(d=2.7, h=bezel_thickness + 2, center=true, $fn=16);
        }
    }
}

// ========== ASSEMBLY ==========

// Main enclosure
enclosure_body();

// Display bezel (separate print, shown in position)
if (false) {  // Set to true to show bezel in assembly view
    color("yellow", 0.5)
    translate([display_x, -wall_thickness - 1, box_height - display_y])
        rotate([90, 0, 0])
            display_bezel();
}

// Visual component placeholders (for verification)
if (false) {  // Set to true to show components
    translate([wall_thickness, wall_thickness, 0]) {
        // PSU
        color("silver", 0.3)
        translate([psu_x, psu_y, psu_z])
            cube([psu_length, psu_width, psu_height]);

        // SSR
        color("black", 0.3)
        translate([ssr_x, box_width - 3, ssr_z])
            cube([ssr_width, 3, ssr_length]);

        // Feather
        color("blue", 0.3)
        translate([feather_x, feather_y, feather_z + 2])
            cube([feather_length, feather_width, 2]);
    }
}
