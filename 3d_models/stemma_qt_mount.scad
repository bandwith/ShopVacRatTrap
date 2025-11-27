// ShopVac Rat Trap - Universal STEMMA QT Sensor Mount
// Fits Adafruit standard STEMMA QT boards: 17.78mm × 25.4mm
// Compatible with: VL53L0X (3317), APDS9960 (3595), BME280 (4816)

use <trap_modules.scad>

// Mount types
mount_type = "wall"; // "wall" or "standalone"

// Wall mount configuration
wall_mount_thickness = 3;
wall_mount_width = stemma_qt_board_width + 8;  // Extra for structural support
wall_mount_height = stemma_qt_board_length + 8;

module stemma_qt_mount() {
    difference() {
        union() {
            // Base plate with rounded corners
            hull() {
                for (x = [-wall_mount_width/2 + 2, wall_mount_width/2 - 2]) {
                    for (y = [-wall_mount_height/2 + 2, wall_mount_height/2 - 2]) {
                        translate([x, y, 0])
                            cylinder(r=2, h=wall_mount_thickness, $fn=16);
                    }
                }
            }

            // Standoffs for PCB (4 corners)
            for (x = [-stemma_qt_hole_spacing_w/2, stemma_qt_hole_spacing_w/2]) {
                for (y = [-stemma_qt_hole_spacing_l/2, stemma_qt_hole_spacing_l/2]) {
                    translate([x, y, wall_mount_thickness])
                        cylinder(d=5, h=stemma_qt_standoff_height, $fn=16);
                }
            }
        }

        // Mounting screw holes in standoffs (M2.5)
        for (x = [-stemma_qt_hole_spacing_w/2, stemma_qt_hole_spacing_w/2]) {
            for (y = [-stemma_qt_hole_spacing_l/2, stemma_qt_hole_spacing_l/2]) {
                translate([x, y, -1])
                    cylinder(d=stemma_qt_hole_diameter, h=wall_mount_thickness + stemma_qt_standoff_height + 2, $fn=16);
            }
        }

        // Wall mounting holes (for M3 screws)
        for (y = [-wall_mount_height/2 + 4, wall_mount_height/2 - 4]) {
            translate([0, y, -1])
                cylinder(d=3.2, h=wall_mount_thickness + 2, $fn=16);
        }

        // Cable channel for STEMMA QT connector
        translate([stemma_qt_board_width/2 - 2, -stemma_qt_board_length/2, wall_mount_thickness])
            cube([6, 10, stemma_qt_standoff_height + 1]);
    }
}

// Assembly call
stemma_qt_mount();
