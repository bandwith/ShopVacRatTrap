// ShopVac Rat Trap - Shared Module Library
// Defines all shared parameters, BOM component dimensions, and reusable modules.
// This file is included by all part files via: include <trap_modules.scad>
// It must NOT contain any top-level geometry render calls.

$fn = 100;
include <helpers.scad>

// ============================================================
// CORE TUBE DIMENSIONS (4" PVC standard per design spec)
// ============================================================
tube_od = 101.6;                    // 4" PVC outer diameter (mm)
wall_thickness = 3.2;               // Tube wall thickness (mm)
tube_id = tube_od - 2*wall_thickness; // 95.2mm inner diameter

// ============================================================
// PRINT PARAMETERS
// ============================================================
print_tolerance = 0.3;              // FDM clearance for mating parts (mm)

// ============================================================
// CABLE CHANNEL PARAMETERS
// ============================================================
cable_channel_od = 12;              // Outer diameter of cable conduit
cable_channel_id = 8;               // Inner diameter - fits JST SH connectors (~6mm)
cable_channel_y = tube_od/2 + cable_channel_od/2 - 0.3; // 56.5mm center height

// ============================================================
// FLANGE JOINT PARAMETERS
// Bolted flange joint replaces twist-lock for reliable assembly.
// Male lip slides into female socket; 4x M4 bolts at 45/135/225/315 deg
// straddle the top cable conduit and bottom cradle base.
// ============================================================
flange_od = 130;                    // Outer diameter of flange ring (mm)
flange_thickness = 5;               // Thickness of each flange plate (mm)
lip_length = 10;                    // Length of male lip / female socket depth (mm)
lip_clearance = print_tolerance;    // Radial clearance on lip (0.3mm)
bolt_hole_diameter = 4.5;           // M4 clearance hole (4mm + tolerance)
bolt_hole_inset = 6.5;              // Distance from flange edge to bolt center (r=58.5mm)
bolt_count = 4;                     // Number of bolts (spaced at 90 deg)
bolt_angle_offset = 45;             // 45 deg offset clears top cable channel & bottom cradle

// Ground reference distance from tube centerline (matches flange outer radius)
cradle_ground_offset = flange_od / 2; // 65mm from tube center to flat floor

// ============================================================
// BAYONET BAIT PORT PARAMETERS (shared by trap_body_front, bait_station, bait_cap)
// ============================================================
bait_port_id = 36;                  // Inner bore of bait port (mm)
bait_port_od = 40;                  // Outer diameter of port neck (mm)
bait_port_neck_height = 15;         // How far neck extends beyond tube_od/2 (mm)
bait_cap_od = 46;                   // Cap outer diameter (mm)
bait_cap_height = 10;               // Total cap height (mm)
bayonet_tab_count = 3;              // Number of locking tabs
bayonet_tab_width = 8;              // Nominal tab width (mm)
bayonet_entry_angle = 26;           // Angular width of vertical entry slot (deg)
bayonet_tab_angle = 20;             // Angular width of locking tab on cap (deg)
bayonet_tab_height = 2;             // Axial thickness of locking tab (mm)
bayonet_slot_depth = 6;             // Axial drop of L-slot ring (mm)
bayonet_rotation = 30;              // Degrees to twist for lock
gasket_groove_width = 2.5;          // Width of sealing groove (mm)
gasket_groove_depth = 1.5;          // Depth of sealing groove (mm)

// ============================================================
// SPLIT BODY JOINT PARAMETERS (front/rear halves)
// ============================================================
alignment_pin_diameter = 6;         // Alignment pin OD (mm)
alignment_pin_length = 12;          // Pin insertion depth (mm)
oring_groove_width = 3;             // For 2.5mm cross-section O-ring
oring_groove_depth = 1.5;           // Depth of O-ring channel

// ============================================================
// BOM COMPONENT DIMENSIONS - STEMMA QT Sensors (Adafruit Standard)
// ============================================================
stemma_qt_board_width = 17.78;      // 0.7" PCB width
stemma_qt_board_length = 25.4;      // 1.0" PCB length
stemma_qt_board_thickness = 1.6;    // Standard PCB thickness
stemma_qt_hole_diameter = 2.7;      // M2.5 clearance hole
stemma_qt_hole_spacing_x = 12.7;   // Mounting hole X spacing
stemma_qt_hole_spacing_y = 20.3;   // Mounting hole Y spacing

// ============================================================
// BOM COMPONENT DIMENSIONS - PIR Motion Sensor (Adafruit 4871)
// ============================================================
pir_board_width = 24;               // PCB width (mm)
pir_board_length = 32;              // PCB length (mm)
pir_hole_diameter = 3.2;            // M3 clearance hole
pir_hole_spacing = 28;             // Distance between mounting holes
pir_dome_diameter = 12;            // PIR dome/lens diameter
pir_dome_clearance = 14;           // Clearance hole for dome

// ============================================================
// BOM COMPONENT DIMENSIONS - Camera (Adafruit 5945 OV5640)
// ============================================================
camera_board_size = 32;             // Square PCB (32x32mm)
camera_hole_diameter = 2.7;         // M2.5 clearance hole
camera_hole_spacing = 28;           // Corner hole spacing
camera_lens_clearance = 14;         // M12 lens mount clearance hole

// ============================================================
// BOM COMPONENT DIMENSIONS - OLED Display (Adafruit 326, 128x64)
// ============================================================
oled_board_width = 27;              // Display PCB width
oled_board_height = 27.5;           // Display PCB height
oled_hole_diameter = 2.7;           // M2.5 clearance
oled_active_width = 23;             // Visible display area width
oled_active_height = 12;            // Visible display area height

// ============================================================
// BOM COMPONENT DIMENSIONS - ESP32 Feather
// ============================================================
esp32_board_width = 22.9;           // PCB width
esp32_board_length = 50.8;          // PCB length
esp32_hole_diameter = 2.7;          // M2.5 clearance
esp32_hole_spacing_x = 20.32;      // Mounting hole X spacing
esp32_hole_spacing_y = 48.26;      // Mounting hole Y spacing

// ============================================================
// BOM COMPONENT DIMENSIONS - SSR (Panasonic AQA411VL)
// ============================================================
ssr_width = 25.5;                   // SSR module width
ssr_length = 58;                    // SSR module length
ssr_height = 40;                    // SSR module height

// ============================================================
// BOM COMPONENT DIMENSIONS - Hammond Enclosure (PN-1334-C)
// ============================================================
hammond_ext_length = 200;           // External length
hammond_ext_width = 120;            // External width
hammond_ext_height = 75;            // External height
hammond_int_length = 192;           // Internal length
hammond_int_width = 112;            // Internal width
hammond_int_height = 69;            // Internal height

// ============================================================
// CONTROL BOX <-> VACUUM ADAPTER MOUNTING INTERFACE
// ============================================================
// Single source of truth for the bolted joint between the vacuum adapter's
// mounting bracket and the exit-mounted control box.
mount_bolt_spacing_x = 60;          // Horizontal bolt spacing (mm)
mount_bolt_spacing_z = 45;          // Vertical bolt spacing (mm)
mount_bolt_diameter = 3.5;          // M3 clearance hole (mm)
mount_bolt_center_z = 37.5;         // Vertical center of the pattern (= (15+60)/2)

// Shared sensor window dimensions (aligned between control box and adapter bracket)
sensor_window_width = 44;           // Clear width inside 60mm bolt spacing
sensor_window_rect_height = 22;     // Vertical side wall height of window
sensor_window_arch_height = 14;     // 45-deg self-supporting gabled roof height
sensor_window_base_z = 20;          // Bottom Z of window opening

// ============================================================
// MODULES
// ============================================================

// ---------- CONTROL BOX BOLT PATTERN ----------
module control_box_bolt_pattern(spacing_x=mount_bolt_spacing_x,
                                spacing_z=mount_bolt_spacing_z) {
    for (dx = [-spacing_x/2, spacing_x/2]) {
        for (dz = [-spacing_z/2, spacing_z/2]) {
            translate([dx, 0, dz])
                children();
        }
    }
}

// ---------- PRINTABLE SENSOR WINDOW PROFILE ----------
// 3D cutout prism along Y with a 45-degree gabled roof so it prints vertically
// without supports or >20mm horizontal lintel overhangs.
module printable_sensor_window(width=sensor_window_width,
                               rect_h=sensor_window_rect_height,
                               arch_h=sensor_window_arch_height,
                               depth=10,
                               margin=0) {
    w = width + 2*margin;
    rh = rect_h + margin;
    ah = arch_h + margin;
    top_flat = max(4, w - 2*ah);

    rotate([90, 0, 0])
        linear_extrude(height=depth, center=true)
            polygon(points=[
                [-w/2, -margin],
                [ w/2, -margin],
                [ w/2,  rh],
                [ top_flat/2, rh + ah],
                [-top_flat/2, rh + ah],
                [-w/2,  rh]
            ]);
}

// ---------- CABLE CONDUIT PROFILE ----------
// External top cable conduit + bridge web for a given Z span.
module cable_conduit_outer(h) {
    translate([0, cable_channel_y, 0])
        cylinder(d=cable_channel_od, h=h);
    translate([-cable_channel_od/2, tube_od/2 - 2, 0])
        cube([cable_channel_od, cable_channel_y - tube_od/2 + 2, h]);
}

// ---------- FLANGE JOINT MALE ----------
// Attached at the top (+Z end) of a tube section (at z = body_z_offset + length).
// Includes:
//   - A 45-deg downward support chamfer tapering from tube_od to flange_od
//     so the top flange prints with zero overhang.
//   - Flange plate from z=0..flange_thickness (mating face at z=flange_thickness).
//   - Male insertion lip from z=flange_thickness..flange_thickness + lip_length - 0.5.
module flange_joint_male(include_cable_conduit=true) {
    lip_od = tube_od - 2*lip_clearance;      // 101.0mm (fits inside 102.2mm female socket)
    effective_lip_h = lip_length - 0.5;      // 9.5mm (0.5mm axial clearance so flanges clamp)
    chamfer_h = (flange_od - tube_od) / 2;   // 14.2mm 45-deg support taper below flange

    difference() {
        union() {
            // 45-degree support cone tapering out from tube wall to flange_od
            translate([0, 0, -chamfer_h])
                cylinder(d1=tube_od, d2=flange_od, h=chamfer_h + 0.01);

            // Flange plate (mating face is top surface at z = flange_thickness)
            cylinder(d=flange_od, h=flange_thickness);

            // Male lip extending above flange mating face with 45-deg lead-in bevel
            translate([0, 0, flange_thickness]) {
                cylinder(d=lip_od, h=effective_lip_h - 0.8);
                translate([0, 0, effective_lip_h - 0.8])
                    cylinder(d1=lip_od, d2=lip_od - 1.6, h=0.8);
            }
        }

        // Main tube inner bore
        translate([0, 0, -chamfer_h - 1])
            cylinder(d=tube_id, h=chamfer_h + flange_thickness + effective_lip_h + 2);

        // 4x M4 bolt holes at 45, 135, 225, 315 deg
        for (i = [0 : bolt_count - 1]) {
            rotate([0, 0, bolt_angle_offset + i * (360 / bolt_count)])
                translate([flange_od/2 - bolt_hole_inset, 0, -chamfer_h - 1])
                    cylinder(d=bolt_hole_diameter, h=chamfer_h + flange_thickness + 2);
        }

        // Cable channel through-hole (exits at flat mating face z = flange_thickness)
        if (include_cable_conduit) {
            translate([0, cable_channel_y, -chamfer_h - 1])
                cylinder(d=cable_channel_id, h=chamfer_h + flange_thickness + 2);
        }
    }
}

// ---------- FLANGE JOINT FEMALE ----------
// Attached at the bottom (z=0) of a tube section, sitting flat on the print bed.
// Includes:
//   - Flange plate at z=0..flange_thickness (mating face at z=0).
//   - Socket wall from z=0..lip_length+flange_thickness (15mm total height),
//     tapering smoothly to tube_od at z=15mm.
//   - Internal receiving pocket (d=socket_id) from z=0..lip_length (10mm),
//     with a 45-deg internal transition to tube_id from z=10..13.5mm.
module flange_joint_female(include_cable_conduit=true) {
    socket_id = tube_od + 2*lip_clearance;   // 102.2mm (0.6mm radial clearance around 101.0mm lip)
    socket_od = socket_id + 2*wall_thickness; // 108.6mm outer socket wall
    joint_height = lip_length + flange_thickness; // 15mm total height
    inner_taper_h = (socket_id - tube_id) / 2;    // 3.5mm 45-deg inner transition
    outer_taper_h = (socket_od - tube_od) / 2;    // 3.5mm 45-deg outer transition

    difference() {
        union() {
            // Flange plate resting flat on build plate (z = 0..flange_thickness)
            cylinder(d=flange_od, h=flange_thickness);

            // Socket outer wall (z = 0 .. joint_height - outer_taper_h)
            cylinder(d=socket_od, h=joint_height - outer_taper_h);

            // 45-deg outer taper from socket_od down to tube_od
            translate([0, 0, joint_height - outer_taper_h])
                cylinder(d1=socket_od, d2=tube_od, h=outer_taper_h);

            // Integrated top cable conduit outer boss through joint height
            if (include_cable_conduit) {
                cable_conduit_outer(joint_height);
            }
        }

        // Receiving pocket for male lip (z = 0..lip_length)
        translate([0, 0, -1])
            cylinder(d=socket_id, h=lip_length + 1.01);

        // 45-degree self-supporting internal taper from socket_id to tube_id
        translate([0, 0, lip_length])
            cylinder(d1=socket_id, d2=tube_id, h=inner_taper_h + 0.01);

        // Main airflow bore through entire joint
        translate([0, 0, -1])
            cylinder(d=tube_id, h=joint_height + 2);

        // 4x M4 bolt holes at 45, 135, 225, 315 deg
        for (i = [0 : bolt_count - 1]) {
            rotate([0, 0, bolt_angle_offset + i * (360 / bolt_count)])
                translate([flange_od/2 - bolt_hole_inset, 0, -1])
                    cylinder(d=bolt_hole_diameter, h=flange_thickness + 2);
        }

        // Cable channel through-bore
        if (include_cable_conduit) {
            translate([0, cable_channel_y, -1])
                cylinder(d=cable_channel_id, h=joint_height + 2);
        }
    }
}

// ---------- FLAT CRADLE BASE ----------
// Continuous flat cradle base running from z=0 (build plate) to total_z,
// sitting at Y = -cradle_ground_offset (-65mm, flush with flange bottom).
// Width 70mm stays inside the 45-deg bolt hole X positions (+/-41.37mm).
module tube_cradle_base(body_length, cradle_width=70) {
    body_z_offset = lip_length + flange_thickness;
    total_z = body_z_offset + body_length + flange_thickness;
    socket_id = tube_od + 2*lip_clearance;
    inner_taper_h = (socket_id - tube_id) / 2;

    difference() {
        translate([-cradle_width/2, -cradle_ground_offset, 0])
            cube([cradle_width, cradle_ground_offset - tube_id/2 + 2, total_z]);

        // Carve out female socket pocket at bottom
        translate([0, 0, -1])
            cylinder(d=socket_id, h=lip_length + 1.01);
        translate([0, 0, lip_length])
            cylinder(d1=socket_id, d2=tube_id, h=inner_taper_h + 0.01);

        // Carve out main tube exterior above female socket so cradle wraps outer wall
        translate([0, 0, -1])
            cylinder(d=tube_id, h=total_z + 2);
    }
}

// ---------- BAYONET BAIT PORT ----------
// Side-mounted (+X direction, Y=0) bayonet port boss and cuts.
// Positioned on +X so it clears the bottom cradle (-Y) and top cable conduit (+Y).
// Uses a 45-deg teardrop inner bore ceiling, a 45-deg lower support gusset up to
// the cap skirt stop, and a 45-deg lower tip bevel so the entire port prints
// vertically with zero >20mm unsupported overhangs and zero degenerate triangles.
bayonet_angle_offset = 42;          // Places 3 slots symmetrically clear of 0-deg bottom bevel

module bayonet_bait_port_boss(z_center) {
    port_tip_x = tube_od/2 + bait_port_neck_height; // 65.8mm
    ring_len = bayonet_slot_depth + bayonet_tab_height; // 8mm
    ring_start_x = port_tip_x - ring_len; // 57.8mm
    gusset_top_x = port_tip_x - 4.8;      // 61.0mm (meets 45-deg tip bevel)
    gusset_drop = gusset_top_x - (tube_id/2 + 1); // 12.4mm axial span

    difference() {
        translate([0, 0, z_center])
            rotate([0, 90, 0]) {
                difference() {
                    union() {
                        // Single-body outer neck + 45-deg ring shoulder + bayonet ring
                        // (starts inside the tube wall at tube_id/2)
                        translate([0, 0, tube_id/2])
                            cylinder(d=bait_port_od, h=ring_start_x - tube_id/2);
                        translate([0, 0, ring_start_x - 2])
                            cylinder(d1=bait_port_od - 2, d2=bait_port_od + 2, h=2);
                        translate([0, 0, ring_start_x - 0.5])
                            cylinder(d=bait_port_od + 2, h=ring_len + 0.5);

                        // 45-deg lower support gusset (+X_port is -Z_world down)
                        // Slopes at <45 deg from every point on the lower cylinder at gusset_top_x
                        // down to the tube wall at tube_id/2 + 1.
                        hull() {
                            intersection() {
                                translate([0, 0, tube_id/2 + 1])
                                    cylinder(d=bait_port_od + 2, h=gusset_drop);
                                translate([0, -25, tube_id/2 + 1])
                                    cube([25, 50, gusset_drop]);
                            }
                            intersection() {
                                translate([gusset_drop + 1, 0, tube_id/2 + 1])
                                    cylinder(d=bait_port_od + 2, h=1);
                                translate([0, -25, tube_id/2 + 1])
                                    cube([40, 50, 2]);
                            }
                        }
                    }

                    // 45-deg upward bevel on bottom dead center of tip (z_port = 60.2 .. 65.8)
                    // Eliminates the <45-deg bottom cylinder overhang while staying inside cap_id.
                    translate([20.6, -25, port_tip_x - 5.6])
                        rotate([0, -45, 0])
                            cube([20, 50, 20]);
                }
            }

        // Trim inner end flush with main tube inner bore (tube_id)
        translate([0, 0, z_center - 45])
            cylinder(d=tube_id, h=90);
    }
}

module bayonet_bait_port_cuts(z_center) {
    port_tip_x = tube_od/2 + bait_port_neck_height; // 65.8mm
    slot_base_x = port_tip_x - 4.8;      // 61.0mm (aligned with top of lower support gusset)
    slot_len = port_tip_x - slot_base_x; // 4.8mm
    slot_inner_r = bait_port_od/2 - 1;   // 19mm
    bore_r = 12.5;                       // 25mm inner bore with 45-deg teardrop top

    translate([0, 0, z_center])
        rotate([0, 90, 0]) {
            // 45-deg teardrop through-bore into trap interior (-X_port is +Z_world up,
            // so the teardrop peak at -X_port eliminates the top bore overhang).
            translate([0, 0, tube_id/2 - 6])
                hull() {
                    cylinder(r=bore_r, h=port_tip_x - (tube_id/2 - 6) + 2);
                    translate([-(bore_r - 1.5) * 1.45, 0, 0])
                        cylinder(r=1.5, h=port_tip_x - (tube_id/2 - 6) + 2);
                }

            // 3x cylindrical L-slots at 55, 175, 295 deg (0.2mm radial step between
            // axial and rotational cuts avoids grazing cylindrical surface slivers)
            translate([0, 0, slot_base_x]) {
                for (i = [0 : bayonet_tab_count - 1]) {
                    rotate([0, 0, bayonet_angle_offset + i * (360 / bayonet_tab_count)]) {
                        // Axial entry slot (opens through tip of port)
                        rotate([0, 0, -bayonet_entry_angle/2])
                            rotate_extrude(angle=bayonet_entry_angle)
                                translate([slot_inner_r - 0.15, 0])
                                    square([4.5, slot_len + 1]);

                        // Rotational lock channel at base of slot (with 45-deg upper bevel
                        // matching the 45-deg print-support chamfer on bait_cap's tabs)
                        rotate([0, 0, 2])
                            rotate_extrude(angle=bayonet_rotation + bayonet_entry_angle/2 - 2)
                                polygon(points=[
                                    [slot_inner_r, 0],
                                    [slot_inner_r + 4.2, 0],
                                    [slot_inner_r + 4.2, bayonet_tab_height + 4.6],
                                    [slot_inner_r, bayonet_tab_height + 0.4]
                                ]);
                    }
                }
            }
        }
}

// ---------- TRAP MODULE BASE ----------
// Base tube section with integrated cable channel and optional flange joints.
module trap_module_base(length, male_end=true, female_end=true) {
    body_z_offset = female_end ? lip_length + flange_thickness : 0;

    difference() {
        union() {
            translate([0, 0, body_z_offset]) {
                // Main tube body
                tube(length=length, od=tube_od, wall=wall_thickness);

                // Integrated top cable channel
                cable_conduit_outer(length);
            }

            // Add flange joints
            if (male_end) {
                translate([0, 0, body_z_offset + length])
                    flange_joint_male();
            }

            if (female_end) {
                flange_joint_female();
            }
        }

        // Continuous hollow cable channel through body and flanges
        translate([0, cable_channel_y, -1])
            cylinder(d=cable_channel_id,
                     h=body_z_offset + length + (male_end ? flange_thickness + 2 : 2));

        // Ensure main bore is clear through any internal features
        translate([0, 0, body_z_offset - 0.5])
            cylinder(d=tube_id, h=length + (male_end ? flange_thickness + lip_length + 2 : 2));
    }
}

// ---------- SENSOR MODULE ----------
// Tube section with sensor cutouts for VL53L0X (ToF) and PIR.
module sensor_module(length=80) {
    body_z_offset = lip_length + flange_thickness;

    difference() {
        trap_module_base(length);

        // ToF Sensor cutout (side-facing, centered along length)
        translate([0, 0, body_z_offset + length/2])
            rotate([90, 0, 0])
                cylinder(d=stemma_qt_board_width + 2*print_tolerance, h=tube_od);

        // PIR Sensor cutout (offset along length, larger dome clearance)
        translate([0, 0, body_z_offset + length/2 + 20])
            rotate([90, 0, 90])
                cylinder(d=pir_dome_clearance, h=tube_od);
    }

    // Sensor mount boss (external, for ToF sensor bracket)
    translate([0, -tube_od/2 - 5, body_z_offset + length/2]) {
        difference() {
            cube([stemma_qt_board_length + 4, 8, stemma_qt_board_width + 4], center=true);
            cube([stemma_qt_board_length + 2*print_tolerance,
                  10,
                  stemma_qt_board_width + 2*print_tolerance], center=true);
            for (dx = [-stemma_qt_hole_spacing_y/2, stemma_qt_hole_spacing_y/2]) {
                translate([dx, 0, 0])
                    rotate([90, 0, 0])
                        cylinder(d=stemma_qt_hole_diameter, h=12, center=true);
            }
        }
    }
}
