// ShopVac Rat Trap - Modular Bait Station
// Features: External threaded cap for refill, Twist-Lock joints

include <trap_modules.scad>

$fn = 100;

module bait_station_module() {
    length = 80;
    cap_d = 40;

    difference() {
        trap_module_base(length);

        // Bait Port Cutout
        translate([0, 0, length/2])
            rotate([90, 0, 0])
            cylinder(d=cap_d - 4, h=tube_od/2 + 20);
    }

    // Bait Port Neck (Threaded)
    translate([0, -tube_od/2 + 2, length/2])
        rotate([90, 0, 0])
        difference() {
            union() {
                cylinder(d=cap_d, h=15);
                // Thread simulation (spiral)
                for(i=[0:3]) {
                    translate([0, 0, 2 + i*3])
                        difference() {
                            cylinder(d=cap_d + 2, h=1);
                            cylinder(d=cap_d, h=1);
                        }
                }
            }
            cylinder(d=cap_d - 4, h=20, center=true);
        }
}

module bait_cap() {
    cap_d = 40;
    difference() {
        union() {
            cylinder(d=cap_d + 6, h=10);
            // Grip ribs
            for(r=[0:30:360]) rotate([0,0,r]) translate([cap_d/2 + 2, 0, 5]) cylinder(r=2, h=10, center=true);
        }

        // Inner thread cavity
        translate([0, 0, 2])
            cylinder(d=cap_d + 0.5, h=9);

        // Gasket Groove
        translate([0, 0, 1])
            difference() {
                cylinder(d=cap_d + 4, h=1);
                cylinder(d=cap_d - 2, h=1);
            }
    }
}

// Render
bait_station_module();
translate([0, -50, 0]) bait_cap();
