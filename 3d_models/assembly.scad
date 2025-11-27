// ShopVac Rat Trap - Full Assembly Visualization
// Shows complete assembly with all components
// Created: 2025-11-27
// Purpose: Validate component fitment and provide assembly reference

include <trap_modules.scad>

// Import structural models
use <trap_ramp_entrance.scad>  // NEW: Flat ramp entrance
use <trap_entrance.scad>
use <trap_body_front.scad>
use <trap_body_rear.scad>
use <control_box_enclosure.scad>
use <camera_mount.scad>
use <bait_station.scad>

// ========== ASSEMBLY MODES ==========
show_exploded = true;        // true = exploded view, false = assembled
show_components = true;      // Show component placeholders
show_cables = false;         // Show cable routing (experimental)
explode_distance = 50;       // Distance between parts in exploded view

// ========== COMPONENT PLACEHOLDER MODULES ==========
// Based on BOM_CONSOLIDATED.csv and validation report

module esp32_feather_placeholder() {
    // Adafruit 5323: 50.8×22.9mm
    color("blue", 0.4)
        cube([50.8, 22.9, 2]);
    // Pin headers
    color("black", 0.4) {
        translate([0, 0, -3])
            cube([50.8, 2, 3]);
        translate([0, 20.9, -3])
            cube([50.8, 2, 3]);
    }
}

module vl53l0x_placeholder() {
    // Adafruit 3317: 17.78×25.4mm STEMMA QT
    color("green", 0.4)
        cube([17.78, 25.4, 2]);
    // STEMMA QT connector
    color("white", 0.4)
        translate([17.78/2 - 2.5, 0, 0.5])
            cube([5, 3, 2]);
}

module apds9960_placeholder() {
    // Adafruit 3595: 17.78×25.4mm STEMMA QT
    color("purple", 0.4)
        cube([17.78, 25.4, 2]);
    // STEMMA QT connector
    color("white", 0.4)
        translate([17.78/2 - 2.5, 0, 0.5])
            cube([5, 3, 2]);
}

module pir_placeholder() {
    // Adafruit 4871: 32×24mm with 12mm dome
    color("red", 0.4)
        union() {
            cube([32, 24, 2]);
            translate([16, 12, 2])
                cylinder(d=12, h=8, $fn=32);  // PIR dome
        }
}

module bme280_placeholder() {
    // Adafruit 4816: 17.78×25.4mm STEMMA QT
    color("orange", 0.4)
        cube([17.78, 25.4, 2]);
    // STEMMA QT connector
    color("white", 0.4)
        translate([17.78/2 - 2.5, 0, 0.5])
            cube([5, 3, 2]);
}

module oled_placeholder() {
    // Adafruit 326: 27×27.5mm PCB, 21.7×10.9mm display
    color("yellow", 0.4)
        union() {
            cube([27, 27.5, 2]);  // PCB
            // Display area (black)
            color("black", 0.8)
                translate([(27-21.7)/2, (27.5-10.9)/2, 2])
                    cube([21.7, 10.9, 1]);
        }
}

module ov5640_placeholder() {
    // Adafruit 5945: 32×32mm PCB with M12 lens
    color("cyan", 0.4)
        union() {
            cube([32, 32, 1.6]);  // PCB
            // Lens
            color("darkgray", 0.5)
                translate([16, 16, 1.6])
                    cylinder(d=14, h=10, $fn=32);
        }
}

module ssr_placeholder() {
    // Panasonic AQA411VL: 40×58×25.5mm
    color("black", 0.4)
        union() {
            cube([40, 58, 25.5]);
            // LED indicator
            color("red", 0.6)
                translate([20, 5, 25.5])
                    cylinder(d=3, h=1, $fn=16);
        }
}

module psu_placeholder() {
    // Mean Well LRS-35-5: 99×82×30mm
    color("silver", 0.4)
        cube([99, 82, 30]);
    // Terminal blocks
    color("green", 0.5) {
        translate([5, 5, 30])
            cube([15, 10, 8]);
        translate([79, 5, 30])
            cube([15, 10, 8]);
    }
}

module stemma_qt_hub_placeholder() {
    // Adafruit 5625: ~25mm square
    color("green", 0.4)
        cube([25, 25, 2]);
    // 5 STEMMA ports
    color("white", 0.4)
        for (i = [0:4]) {
            translate([2 + i*4.5, 0, 0.5])
                cube([3, 3, 2]);
        }
}

module cable_bundle(length) {
    // Simplified cable bundle representation
    if (show_cables) {
        color("blue", 0.3)
            cylinder(d=6, h=length, $fn=16);
    }
}

// ========== FULL ASSEMBLY ==========

module full_assembly() {
    // Calculate offsets for exploded view
    e = show_exploded ? explode_distance : 0;

    // ===== TRAP STRUCTURE =====

    // Flat ramp entrance (NEW)
    translate([-150, 0, -tube_outer_diameter/2])
        rotate([0, 0, 0])
            trap_ramp_entrance();

    // Trap entrance at origin
    trap_entrance();

    // Trap body front
    translate([0, 0, 80 + e])
        trap_body_front();

    // Trap body rear
    translate([0, 0, 205 + e*2])
        trap_body_rear();

    // Bait station (on side of trap body front)
    translate([0, -tube_outer_diameter/2 - 20, 100 + e])
        rotate([0, 0, 0])
            bait_station();

    // ===== COMPONENT PLACEHOLDERS =====

    if (show_components) {
        // --- Sensors in trap entrance ---

        // VL53L0X (top mount, Z=60mm)
        translate([0, tube_outer_diameter/2 + 2, 60])
            rotate([90, 0, 0])
                vl53l0x_placeholder();

        // APDS9960 (side mount, Z=30mm)
        translate([tube_outer_diameter/2 + 2, 0, 30])
            rotate([0, 90, 0])
                apds9960_placeholder();

        // STEMMA QT Hub (at trap entrance top junction)
        translate([-12.5, -12.5, 80])
            stemma_qt_hub_placeholder();

        // --- PIR in trap body front ---
        translate([50 + e, 0, 150])
            rotate([90, 0, 90])
                pir_placeholder();

        // --- Camera (optional) ---
        translate([-16, -16, 240 + e*2.5]) {
            camera_mount();
            translate([0, 0, 4])
                ov5640_placeholder();
        }

        // --- Control box components (as separate placeholders) ---
        translate([150 + e*3, 0, 50]) {
            // ESP32
            translate([20, 45, 70])
                rotate([0, 90, 0])
                    esp32_feather_placeholder();

            // OLED
            translate([0, 56, 80])
                rotate([0, 90, 0])
                    oled_placeholder();

            // PSU
            translate([30, 15, 50])
                rotate([0, 90, 0])
                    psu_placeholder();

            // SSR
            translate([140, 45, 100])
                rotate([0, 90, 90])
                    ssr_placeholder();
        }
    }

    // ===== CABLE ROUTING ======

    if (show_cables) {
        // Sensor cables to hub
        translate([0, 0, 60])
            cable_bundle(20);

        // Hub to control box
        translate([0, 0, 80])
            cable_bundle(200);
    }
}

// ========== RENDER ==========

full_assembly();

// ========== ALTERNATIVE VIEWS ==========

// Uncomment to render specific views:

// Top view
//translate([0, 0, 0])
//    rotate([0, 0, 0])
//        full_assembly();

// Side view
//rotate([0, 90, 0])
//    full_assembly();

// Component detail view
//if (show_components) {
//    translate([300, 0, 0]) {
//        esp32_feather_placeholder();
//        translate([60, 0, 0])
//            ssr_placeholder();
//        translate([110, 0, 0])
//            psu_placeholder();
//    }
//}
