// ShopVac Rat Trap - Full Assembly Visualization
// Transforms all printable parts from their build-plate print orientations
// into the horizontal assembled rat trap coordinate frame (Z >= 0 above ground).
// Uses 'use' to import module definitions without executing top-level renders.

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

// Shared dimensions matching trap_modules.scad
_tube_od = 101.6;
_tube_id = 95.2;
_flange_od = 130;
_flange_thickness = 5;
_lip_length = 10;
_joint_height = _lip_length + _flange_thickness; // 15mm female joint offset
_ground_offset = _flange_od / 2;                 // 65mm from tube axis to ground (Z=0)

// Section lengths (axial advance between flange mating faces)
_ramp_length = 150;
_ramp_advance = _ramp_length + _flange_thickness; // 155mm to male flange mating face
_body_length = 125;
_body_advance = _joint_height + _body_length + _flange_thickness; // 145mm flange-to-flange
_bait_length = 80;

// Control box dimensions matching control_box_exit_mount.scad
_box_outer_length = 128;
_box_outer_width = 108;
_box_outer_height = 69;
_lid_thickness = 4;

// Bait port parameters matching trap_modules.scad
_bait_port_z = _joint_height + 75;               // 90mm along trap_body_front
_bait_port_tip_r = _tube_od / 2 + 15;            // 65.8mm from tube axis
_bait_slot_base_r = _bait_port_tip_r - 8;        // 57.8mm lock slot base
_bait_cap_height = 18;
_bayonet_rotation = 30;

show_exploded = false;              // false = mated assembly, true = exploded view
show_components = true;             // Show electronic component placeholders
show_optional_bait_station = false; // Show standalone modular bait_station beside trap
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
// Each part is transformed from its printable orientation (z>=0 on build plate)
// into the horizontal trap assembly along the +X axis with the flat base on Z=0.

module placed_ramp_entrance(e=0) {
    translate([-e, 0, _ground_offset])
        rotate([90, 0, 90])
            trap_ramp_entrance();
}

module placed_body_front(e=0) {
    translate([_ramp_advance, 0, _ground_offset])
        rotate([90, 0, 90])
            trap_body_front();
}

module placed_bait_cap(e=0) {
    // Positioned on trap_body_front's side-mounted (+Y_world) bayonet port,
    // rotated into the locked bayonet position.
    cap_outer_y = _bait_slot_base_r + _bait_cap_height - 0.2 + e;
    translate([_ramp_advance + _bait_port_z, cap_outer_y, _ground_offset])
        rotate([90, 0, 0])
            rotate([0, 0, -_bayonet_rotation])
                bait_cap();
}

module placed_body_rear(e=0) {
    x_pos = _ramp_advance + _body_advance + e;
    translate([x_pos, 0, _ground_offset])
        rotate([90, 0, 90])
            trap_body_rear();
}

module placed_vacuum_adapter(e=0) {
    // Rotated so the control box mounting bracket faces the -Y side of the trap
    // while keeping the 4-bolt flange and top cable pass-through aligned.
    x_pos = _ramp_advance + 2 * _body_advance + 2 * e;
    translate([x_pos, 0, _ground_offset])
        rotate([0, 90, 0])
            vacuum_adapter_universal();
}

module placed_control_box(e=0) {
    // Bolted flush against the vacuum adapter bracket at Y = -65mm.
    x_pos = _ramp_advance + 2 * _body_advance + 2 * e;
    y_pos = -_ground_offset - e;
    translate([x_pos, y_pos, _ground_offset])
        rotate([180, -90, 0])
            translate([-_box_outer_length / 2, 0, 0])
                control_box_exit_mount();
}

module placed_control_box_lid(e=0) {
    // Flipped from its print orientation so its registration lip seats inside
    // the open end of control_box_exit_mount.
    x_pos = _ramp_advance + 2 * _body_advance + 2 * e;
    y_pos = -_ground_offset - e;
    lid_gap = e > 0 ? e : 0;
    translate([x_pos, y_pos, _ground_offset])
        rotate([180, -90, 0])
            translate([-_box_outer_length / 2,
                       _box_outer_width,
                       _box_outer_height + _lid_thickness + lid_gap])
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

    // 3. Bayonet Bait Cap (locked on front body bait port)
    color("goldenrod", 0.9)
        placed_bait_cap(e);

    // 4. Trap Body Rear Half
    color("seagreen", 0.75)
        placed_body_rear(e);

    // 5. Universal Vacuum Adapter
    color("slategray", 0.85)
        placed_vacuum_adapter(e);

    // 6. Exit-Mounted Control Box
    color("darkslategray", 0.8)
        placed_control_box(e);

    // 7. Control Box Lid
    color("lightgray", 0.85)
        placed_control_box_lid(e);

    // 8. Optional standalone Bait Station module (shown offset in Y when enabled)
    if (show_optional_bait_station) {
        color("darkorange", 0.7)
            translate([_ramp_advance, 200, _ground_offset])
                rotate([90, 0, 90])
                    bait_station_module();
    }

    // Electronic component placeholders inside control box
    if (show_components) {
        x_pos = _ramp_advance + 2 * _body_advance + 2 * e;
        y_pos = -_ground_offset - e;
        translate([x_pos, y_pos, _ground_offset])
            rotate([180, -90, 0])
                translate([-_box_outer_length / 2, 0, 0]) {
                    translate([12, 52, 9])
                        esp32_feather_placeholder();
                    translate([68, 54, 9])
                        ssr_placeholder();
                }
    }
}

full_assembly();
