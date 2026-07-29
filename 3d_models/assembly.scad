// ShopVac Rat Trap - Full Assembly Visualization
// Shows complete assembly with all components for fitment validation.
// Uses 'use' to import module definitions without executing them.

$fn = 100;

use <trap_modules.scad>
use <helpers.scad>
use <trap_ramp_entrance.scad>
use <trap_body_front.scad>
use <trap_body_rear.scad>
use <vacuum_adapter_universal.scad>
use <control_box_exit_mount.scad>
use <control_box_lid.scad>
use <bait_station.scad>

// ========== ASSEMBLY PARAMETERS ==========

// Shared dimensions (duplicated here since 'use' does not import variables)
_tube_od = 101.6;
_tube_id = 95.2;
_flange_thickness = 5;
_lip_length = 10;
_joint_height = _lip_length + _flange_thickness; // 15mm per joint end

// Body section lengths
_body_length = 125;
_bait_length = 80;

show_exploded = true;               // true = exploded view, false = assembled
show_components = true;             // Show electronic component placeholders
explode_distance = 40;              // Gap between parts in exploded view

// ========== COMPONENT PLACEHOLDER MODULES ==========

module esp32_feather_placeholder() {
    color("blue", 0.4) cube([50.8, 22.9, 7]);
}

module vl53l4cx_placeholder() {
    color("green", 0.4) cube([17.78, 25.4, 2]);
}

module sths34pf80_placeholder() {
    color("purple", 0.4) cube([17.78, 25.4, 2]);
}

module oled_placeholder() {
    color("yellow", 0.4) cube([27, 27.5, 4]);
}

module ov5640_placeholder() {
    color("cyan", 0.4)
        union() {
            cube([32, 32, 1.6]);
            translate([16, 16, 1.6]) cylinder(d=14, h=10, $fn=32);
        }
}

module ssr_placeholder() {
    color("black", 0.4) cube([25.5, 58, 40]);
}

module pir_placeholder() {
    color("darkgreen", 0.4) cube([24, 32, 10]);
}

// ========== FULL ASSEMBLY ==========

module full_assembly() {
    e = show_exploded ? explode_distance : 0;

    // Calculate z-positions for sequential assembly
    // Each part with female end adds joint_height below z=0
    // Each part with male end adds flange_thickness + lip_length above body

    // Part 1: Ramp Entrance (at the start)
    // The ramp connects via male joint at its rear end
    color("tan", 0.8)
    translate([-200 - e, 0, _tube_od/2])
        trap_ramp_entrance();

    // Part 2: Trap Body Front
    // Female at z=0 (receives ramp), Male at top
    color("green", 0.6)
    translate([0, 0, 0])
        trap_body_front();

    // Part 3: Trap Body Rear
    // Female at z=0 (receives front body male), Male at top
    front_total = _joint_height + _body_length + _flange_thickness + _lip_length;
    color("darkgreen", 0.6)
    translate([0, 0, front_total + e])
        trap_body_rear();

    // Part 4: Vacuum Adapter
    // Female at z=0 (receives rear body male)
    rear_total = front_total + e + _joint_height + _body_length + _flange_thickness + _lip_length;
    color("gray", 0.7)
    translate([0, 0, rear_total + e])
        vacuum_adapter_universal();

    // Part 5: Bait Station (alternative to front body, shown offset)
    color("orange", 0.6)
    translate([150, 0, 0])
        bait_station_module();

    // Part 6: Control Box (mounted to adapter bracket)
    color("slategray", 0.7)
    translate([0, -_tube_od/2 - 30 - e, rear_total + e])
        control_box_exit_mount();

    // Part 7: Control Box Lid
    color("lightgray", 0.8)
    translate([0, -_tube_od/2 - 30 - e, rear_total + e + 65 + box_lid_gap])
        control_box_lid();

    // Electronic components (if enabled)
    if (show_components) {
        // ESP32 inside control box
        color("blue", 0.4)
        translate([14, -_tube_od/2 - 25 - e, rear_total + e + 4 + 5])
            esp32_feather_placeholder();

        // SSR inside control box
        translate([79, -_tube_od/2 - 25 - e, rear_total + e + 4 + 5])
            ssr_placeholder();

        // OLED on lid
        translate([50, -_tube_od/2 - 30 - e - 10, rear_total + e + 65 + 2])
            oled_placeholder();
    }
}

box_lid_gap = show_exploded ? explode_distance : 0;

full_assembly();
