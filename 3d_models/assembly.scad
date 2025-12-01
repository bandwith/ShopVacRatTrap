// ShopVac Rat Trap - Full Assembly Visualization
// Shows complete assembly with all components
// Created: 2025-11-29
// Purpose: Validate component fitment and provide assembly reference

include <trap_modules.scad>

// Import structural models
use <trap_ramp_entrance.scad>
use <trap_body_front.scad>
use <trap_body_rear.scad>
use <vacuum_adapter_universal.scad>
use <control_box_exit_mount.scad>
use <control_box_lid.scad>
use <bait_station.scad>

// ========== ASSEMBLY MODES ==========
show_exploded = true;        // true = exploded view, false = assembled
show_components = true;      // Show component placeholders
explode_distance = 50;       // Distance between parts in exploded view

// ========== COMPONENT PLACEHOLDER MODULES ==========

module esp32_feather_placeholder() {
    // Adafruit 5323: 50.8×22.9mm
    color("blue", 0.4) cube([50.8, 22.9, 7]);
}

module vl53l4cx_placeholder() {
    // Adafruit 5425: 17.78×25.4mm STEMMA QT
    color("green", 0.4) cube([17.78, 25.4, 2]);
}

module sths34pf80_placeholder() {
    // Adafruit 6426: 17.78×25.4mm STEMMA QT
    color("purple", 0.4) cube([17.78, 25.4, 2]);
}

module lsm6dsox_placeholder() {
    // Adafruit 4438: 17.78×25.4mm STEMMA QT
    color("red", 0.4) cube([17.78, 25.4, 2]);
}

module bme280_placeholder() {
    // Adafruit 4816: 17.78×25.4mm STEMMA QT
    color("orange", 0.4) cube([17.78, 25.4, 2]);
}

module oled_placeholder() {
    // Adafruit 326: 27×27.5mm PCB
    color("yellow", 0.4) cube([27, 27.5, 4]);
}

module ov5640_placeholder() {
    // Adafruit 5945: 32×32mm PCB with M12 lens
    color("cyan", 0.4)
        union() {
            cube([32, 32, 1.6]);
            translate([16, 16, 1.6]) cylinder(d=14, h=10, $fn=32);
        }
}

module ir_led_placeholder() {
    // Adafruit 5639: 25.4×17.7mm
    color("darkred", 0.6) cube([25.4, 17.7, 7]);
}

module ssr_placeholder() {
    // Panasonic AQA411VL
    color("black", 0.4) cube([40, 58, 25.5]);
}

module psu_placeholder() {
    // Mean Well LRS-35-5
    color("silver", 0.4) cube([99, 82, 30]);
}

// ========== FULL ASSEMBLY ==========

module full_assembly() {
    e = show_exploded ? explode_distance : 0;

    // 1. Ramp Entrance
    translate([-150 - e, 0, 0])
        trap_ramp_entrance();

    // 2. Trap Body Front
    translate([0, 0, 0])
        trap_body_front();

    // 3. Trap Body Rear
    translate([0, 0, 125 + e])
        trap_body_rear();

    // 4. Universal Vacuum Adapter
    translate([0, 0, 250 + e*2])
        rotate([0, 0, 180]) // Align flange
            vacuum_adapter_universal();

    // 5. Control Box (Exit Mounted)
    // Mounts to adapter flange. Adapter flange is at Z=250+e*2.
    // Box mounts vertically on top of the flange?
    // The adapter has a vertical plate "control box mounting flange".
    // Let's position the box relative to that.
    translate([-40 - e, 0, 260 + e*2])
        rotate([0, -90, 0]) // Orient box vertically
            control_box_exit_mount();

    // 6. Control Box Lid
    translate([-40 - e - 70 - e, 0, 260 + e*2]) // Pull lid away
        rotate([0, -90, 0])
            control_box_lid();

    // 7. Bait Station
    translate([0, 0, 80])
        rotate([0, 0, 0])
            bait_station_module();

    // ===== COMPONENTS =====
    if (show_components) {
        // Inside Control Box
        translate([-40 - e, 0, 260 + e*2])
        rotate([0, -90, 0]) {
            // Sensor Plate (Camera, ToF, IR)
            translate([60, -2, 10]) {
                rotate([-90, 0, 0]) {
                    translate([29-16, 35-16, 0]) ov5640_placeholder();
                    translate([29-9, 20-12, 0]) vl53l4cx_placeholder();
                    translate([29-9, 5-12, 0]) sths34pf80_placeholder();
                    translate([5, 5, 0]) ir_led_placeholder();
                }
            }

            // ESP32
            translate([10, 40, 5]) esp32_feather_placeholder();

            // SSR
            translate([80, 40, 5]) ssr_placeholder();

            // IMU (on wall)
            translate([10, 10, 30]) rotate([90, 0, 0]) lsm6dsox_placeholder();

            // BME280 (free floating/mounted)
            translate([40, 80, 30]) bme280_placeholder();

            // PSU (if it fits, or external?)
            // LRS-35-5 is 99x82x30. Box is 120x100. It fits tight.
            translate([10, 10, 35]) psu_placeholder();
        }

        // OLED on Lid
        translate([-40 - e - 70 - e, 0, 260 + e*2])
        rotate([0, -90, 0])
            translate([60, 50, -4]) oled_placeholder();
    }
}

full_assembly();
