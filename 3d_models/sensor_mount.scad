// ShopVac Rat Trap - Modular Sensor Section
// Features: Embedded wiring, Snap-fit sensor covers, Twist-Lock joints

include <trap_modules.scad>

$fn = 100;

module sensor_section() {
    length = 100;

    difference() {
        trap_module_base(length);

        // --- ToF Sensor Mount (Top) ---
        translate([0, 0, length/2]) {
            // Sensor PCB Cavity
            translate([0, tube_od/2 + 2, 0])
                cube([20, 10, 25], center=true);

            // Wire Path to Main Channel
            translate([0, tube_od/2 + 5, 0])
                cylinder(d=6, h=20); // Vertical hole to channel
        }

        // --- PIR Sensor Mount (Side) ---
        translate([25, 0, length/2]) {
            rotate([0, 0, -45]) {
                // Sensor Body Hole
                translate([0, tube_od/2, 0])
                    rotate([90, 0, 0])
                    cylinder(d=23, h=20);

                // Wire Path
                translate([0, tube_od/2, 0])
                    rotate([90, 0, 0])
                    cylinder(d=8, h=30);
            }
        }
    }

    // --- ToF Sensor Boss ---
    translate([0, tube_od/2, length/2]) {
        difference() {
            cube([26, 15, 30], center=true);
            // Cavity
            translate([0, 2, 0])
                cube([21, 12, 26], center=true);
            // Snap fit slots
            translate([0, 5, 10])
                cube([22, 2, 2], center=true);
        }
    }

    // --- PIR Sensor Boss ---
    rotate([0, 0, -45])
    translate([0, tube_od/2, length/2]) {
        difference() {
            rotate([90, 0, 0])
            cylinder(d=30, h=10);

            rotate([90, 0, 0])
            cylinder(d=23, h=12); // Sensor hole
        }
    }
}

module tof_cover() {
    // Snap-fit cover for ToF sensor
    difference() {
        cube([24, 5, 28], center=true);
        // Sensor window
        cube([10, 10, 5], center=true);
        // Snap tabs
        translate([0, 0, 10])
            cube([22, 2, 2], center=true);
    }
}

// Render
sensor_section();
translate([0, 50, 0]) tof_cover();
