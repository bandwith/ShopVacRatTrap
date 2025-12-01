// ShopVac Rat Trap - Modular Trap System
// Features: Twist-Lock (Bayonet) joints, Embedded Cable Channels, Tool-free assembly

$fn = 100;
include <helpers.scad>

// ========== DIMENSIONS ==========
tube_id = 60; // Inner diameter for rat passage
tube_wall = 4; // Thick walls for rodent resistance
tube_od = tube_id + 2*tube_wall;

cable_channel_od = 12;
cable_channel_id = 8; // Fits JST connectors (approx 6mm wide)

// Twist Lock Parameters
lock_len = 15;
lock_pin_r = 3;

// ========== MODULES ==========

module trap_module_base(length, male_end=true, female_end=true) {
    difference() {
        union() {
            // Main Tube Body
            cylinder(d=tube_od, h=length);

            // Integrated Cable Channel (Top)
            translate([0, tube_od/2 + cable_channel_od/2 - 2, length/2])
                cylinder(d=cable_channel_od, h=length, center=true);

            // Connection to Cable Channel
            translate([0, tube_od/2, length/2])
                cube([cable_channel_od/2, cable_channel_od, length], center=true);
        }

        // Hollow Tube
        translate([0, 0, -1])
            cylinder(d=tube_id, h=length + 2);

        // Hollow Cable Channel
        translate([0, tube_od/2 + cable_channel_od/2 - 2, -1])
            cylinder(d=cable_channel_id, h=length + 2);
    }

    // Add Twist Lock Ends
    if(male_end) {
        translate([0, 0, length])
            twist_lock_male();
    }

    if(female_end) {
        twist_lock_female();
    }
}

module twist_lock_male() {
    difference() {
        union() {
            // Insert Ring
            cylinder(d=tube_od - 1, h=lock_len); // Slightly smaller to fit inside female

            // Locking Pins (2x)
            for(r = [0, 180]) {
                rotate([0, 0, r])
                translate([tube_od/2 - 1, 0, lock_len/2])
                    rotate([0, 90, 0])
                    cylinder(r=lock_pin_r, h=3);
            }
        }
        // Hollow
        translate([0, 0, -1])
            cylinder(d=tube_id, h=lock_len + 2);

        // Cable Pass-through
        translate([0, tube_od/2 + cable_channel_od/2 - 2, -1])
            cylinder(d=cable_channel_id, h=lock_len + 2);
    }
}

module twist_lock_female() {
    difference() {
        union() {
            // Outer Ring
            cylinder(d=tube_od + 4, h=lock_len);
        }

        // Inner Socket
        translate([0, 0, -1])
            cylinder(d=tube_od, h=lock_len + 2); // Fits male end (tube_od - 1) with clearance

        // Locking Slots (L-shape)
        for(r = [0, 180]) {
            rotate([0, 0, r]) {
                // Vertical entry
                translate([tube_od/2 - 2, -lock_pin_r - 0.5, -1])
                    cube([5, lock_pin_r*2 + 1, lock_len/2 + 1]);

                // Horizontal lock
                translate([tube_od/2 - 2, 0, lock_len/2])
                    rotate([0, 90, 0])
                    cylinder(r=lock_pin_r + 0.5, h=5); // Clearance for pin

                // Horizontal slot path
                difference() {
                    cylinder(r=tube_od/2 + 2, h=lock_len/2 + lock_pin_r + 1);
                    cylinder(r=tube_od/2 - 2, h=lock_len/2 + lock_pin_r + 1);
                    // Limit angle... simplified for now
                }
            }
        }

        // Cable Pass-through
        translate([0, tube_od/2 + cable_channel_od/2 - 2, -1])
            cylinder(d=cable_channel_id, h=lock_len + 2);
    }
}

module sensor_module() {
    length = 80;
    difference() {
        trap_module_base(length);

        // Sensor Cutouts (Top/Side)
        // ToF Sensor
        translate([0, 0, length/2])
            rotate([90, 0, 0])
            cylinder(d=10, h=tube_od/2 + 10);

        // PIR Sensor
        translate([15, 0, length/2])
            rotate([90, 45, 0])
            cylinder(d=20, h=tube_od/2 + 10);
    }

    // Sensor Mount Bosses (Snap-fit)
    translate([0, -tube_od/2 - 2, length/2]) {
        difference() {
            cube([30, 10, 30], center=true);
            // Internal cavity for sensor PCB
            cube([25, 12, 25], center=true);
        }
    }
}

// Example Assembly
translate([0, 0, 0]) sensor_module();
translate([0, 0, 80 + lock_len]) trap_module_base(100);
