// ShopVac Rat Trap - Full Assembly Visualization
// Transforms all 8 printable parts from their build-plate print orientations (z >= 0)
// into the horizontal assembled rat trap coordinate frame (Z >= 0 resting on ground).
// Uses 'use' to import module definitions without executing top-level renders.

$fn = 100;

use <trap_modules.scad>
use <helpers.scad>
use <trap_ramp_entrance.scad>
use <trap_body_front.scad>
use <bait_station.scad>
use <trap_body_rear.scad>
use <vacuum_adapter_universal.scad>
use <control_box_exit_mount.scad>
use <control_box_lid.scad>

// ========== ASSEMBLY PARAMETERS ==========

// Shared dimensions matching trap_modules.scad
_tube_od = 101.6;
_tube_id = 95.2;
_flange_od = 130;
_flange_thickness = 5;
_lip_length = 10;
_joint_height = _lip_length + _flange_thickness; // 15mm female joint offset
_ground_offset = _flange_od / 2;                 // 65mm from tube axis to ground (Z=0)

// Section lengths (axial advance between flange mating faces along +X)
_ramp_length = 150;
_ramp_advance = _ramp_length + _flange_thickness;                 // 155mm (Joint 1)
_body_length = 125;
_body_advance = _joint_height + _body_length + _flange_thickness; // 145mm (Joints 2 & 4)
_bait_length = 80;
_bait_advance = _joint_height + _bait_length + _flange_thickness; // 100mm (Joint 3)

// Axial positions of the 5 inline tube sections along +X
_x_ramp = 0;
_x_front = _ramp_advance;                               // 155mm
_x_bait = _x_front + _body_advance;                     // 300mm
_x_rear = _x_bait + _bait_advance;                      // 400mm
_x_adapter = _x_rear + _body_advance;                   // 545mm

// Control box dimensions matching control_box_exit_mount.scad & vacuum_adapter_universal.scad
_bracket_center_z = 40;                                 // Axial center of 80mm adapter bracket
_box_outer_length = 128;
_box_outer_width = 108;
_box_outer_height = 69;
_lid_thickness = 4;

// Bait port parameters matching bait_station.scad & trap_modules.scad
_bait_port_z = _joint_height + _bait_length / 2;        // 55mm along bait_station
_bait_port_tip_r = _tube_od / 2 + 15;                   // 65.8mm from tube axis
_bait_slot_base_r = _bait_port_tip_r - 4.8;             // 61.0mm lock slot base (above gusset)
_bait_cap_height = 10;
_bayonet_rotation = 30;

show_exploded = false;              // false = mated assembly, true = exploded view
show_components = true;             // Show electronic component placeholders
explode_distance = 40;              // Gap between parts in exploded view (mm)

// ========== COMPONENT PLACEHOLDER MODULES ==========

module esp32_feather_placeholder() {
    color("blue", 0.5) cube([50.8, 22.9, 7]);
}

module oled_placeholder() {
    color("yellow", 0.5) cube([27, 27.5, 4]);
}

module ssr_placeholder() {
    color("dimgray", 0.5) cube([58, 25.5, 35]);
}

// ========== PART PLACEMENT MODULES (in assembly frame) ==========
// All 5 tube sections use the exact same rigid rotation rotate([90, 0, 90]) from their
// upright build-plate orientation (z >= 0) into the horizontal +X trap axis (Z >= 0).
// The control box sits upright on Z = 0 in its exact build-plate Z orientation.

module placed_ramp_entrance(e=0) {
    translate([_x_ramp - e, 0, _ground_offset])
        rotate([90, 0, 90])
            trap_ramp_entrance();
}

module placed_body_front(e=0) {
    translate([_x_front, 0, _ground_offset])
        rotate([90, 0, 90])
            trap_body_front();
}

module placed_bait_station(e=0) {
    translate([_x_bait + e, 0, _ground_offset])
        rotate([90, 0, 90])
            bait_station_module();
}

module placed_bait_cap(e=0) {
    // Twist-locked onto bait_station's side-mounted (+Y_world) bayonet port.
    // Under rotate([90, 0, 0]), polar angle maps as theta_port = 180 - theta_cap;
    // rotating cap by 70 deg aligns the 55/175/295 deg tabs with the entry slots,
    // and subtracting _bayonet_rotation (30 deg -> 40 deg) seats them in the lock channels.
    cap_outer_y = _bait_slot_base_r + 0.2 + _bait_cap_height + e;
    translate([_x_bait + _bait_port_z + e, cap_outer_y, _ground_offset])
        rotate([90, 0, 0])
            rotate([0, 0, 96 - _bayonet_rotation])
                bait_cap();
}

module placed_body_rear(e=0) {
    translate([_x_rear + 2 * e, 0, _ground_offset])
        rotate([90, 0, 90])
            trap_body_rear();
}

module placed_vacuum_adapter(e=0) {
    translate([_x_adapter + 3 * e, 0, _ground_offset])
        rotate([90, 0, 90])
            vacuum_adapter_universal();
}

module placed_control_box(e=0) {
    // Upright in its build-plate Z orientation (Z = 0..69mm resting flat on ground),
    // rotated 180 deg in XY so its Y=0 sensor-window wall bolts flush against the
    // vacuum adapter's -Y bracket face at Y = -65mm.
    x_center = _x_adapter + _bracket_center_z + 3 * e;
    y_face = -_ground_offset - e;
    translate([x_center, y_face, 0])
        rotate([0, 0, 180])
            translate([-_box_outer_length / 2, 0, 0])
                control_box_exit_mount();
}

module placed_control_box_lid(e=0) {
    // Flipped 180 deg from its print orientation so its registration lip seats downward
    // into the open top (Z = 69mm) of the upright control_box_exit_mount.
    x_center = _x_adapter + _bracket_center_z + 3 * e;
    y_face = -_ground_offset - e;
    lid_gap = e > 0 ? e : 0;
    translate([x_center, y_face, _box_outer_height + _lid_thickness + lid_gap])
        rotate([0, 0, 180])
            translate([-_box_outer_length / 2, _box_outer_width, 0])
                rotate([180, 0, 0])
                    control_box_lid();
}

// ========== FULL ASSEMBLY ==========

module full_assembly() {
    e = show_exploded ? explode_distance : 0;

    // 1. Entrance Ramp
    color("tan", 0.85)
        placed_ramp_entrance(e);

    // 2. Trap Body Front Half
    color("mediumseagreen", 0.75)
        placed_body_front(e);

    // 3. Modular Bait Station (in-line between front and rear body halves)
    color("darkorange", 0.8)
        placed_bait_station(e);

    // 4. Bayonet Bait Cap (twist-locked onto bait_station port)
    color("goldenrod", 0.9)
        placed_bait_cap(e);

    // 5. Trap Body Rear Half
    color("seagreen", 0.75)
        placed_body_rear(e);

    // 6. Universal Vacuum Adapter
    color("slategray", 0.85)
        placed_vacuum_adapter(e);

    // 7. Exit-Mounted Control Box (upright on Z=0 ground plane)
    color("darkslategray", 0.8)
        placed_control_box(e);

    // 8. Control Box Lid (seated on top of control box at Z=69mm)
    color("lightgray", 0.85)
        placed_control_box_lid(e);

    // Electronic component placeholders inside upright control box
    if (show_components) {
        x_center = _x_adapter + _bracket_center_z + 3 * e;
        y_face = -_ground_offset - e;
        translate([x_center, y_face, 0])
            rotate([0, 0, 180])
                translate([-_box_outer_length / 2, 0, 0]) {
                    translate([12, 52, 9])
                        esp32_feather_placeholder();
                    translate([68, 54, 9])
                        ssr_placeholder();
                }
    }
}

full_assembly();
