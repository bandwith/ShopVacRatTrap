// ShopVac Rat Trap - Universal Vacuum Adapter
// Stepped adapter connecting the trap tube (4" PVC) to various shop vac hoses.
// Oriented in printable perspective: female flange flat on build plate (z=0),
// stepped hose cones tapering upward (+Z) with 45-deg self-supporting transitions.
// Uses the same assembly transform (rotate([90, 0, 90])) as all other tube sections:
//   +z_local -> +X_world (along trap axis)
//   +x_local -> +Y_world (side of trap; control box bracket at x_local = -65mm)
//   +y_local -> +Z_world (vertical; bottom cradle/bracket base at y_local = -65mm = Z_world 0)

include <trap_modules.scad>

// ========== CORE PARAMETERS ==========

adapter_wall = 3;                   // Adapter body wall thickness (mm)

// Hose inner diameters (stepped sizes, largest to smallest)
hose_id_1 = 76.2;                   // 3.0" hose
hose_id_2 = 63.5;                   // 2.5" hose
hose_id_3 = 47.6;                   // 1.875" hose
hose_id_4 = 31.75;                  // 1.25" hose

// External grip diameters (fit inside each hose with clearance)
grip_od_1 = hose_id_1 - 2*print_tolerance;  // 75.6mm
grip_od_2 = hose_id_2 - 2*print_tolerance;  // 62.9mm
grip_od_3 = hose_id_3 - 2*print_tolerance;  // 47.0mm
grip_od_4 = hose_id_4 - 2*print_tolerance;  // 31.15mm

// Internal bore diameters (grip OD minus wall on each side)
bore_id_1 = grip_od_1 - 2*adapter_wall;     // 69.6mm
bore_id_2 = grip_od_2 - 2*adapter_wall;     // 56.9mm
bore_id_3 = grip_od_3 - 2*adapter_wall;     // 41.0mm
bore_id_4 = grip_od_4 - 2*adapter_wall;     // 25.15mm

step_length = 25;                   // Axial pitch of each step section (mm)
step_taper = 9;                     // Conical transition length between steps (<=42 deg)
num_steps = 4;
taper_length = 14;                  // Main conical transition from tube_od to grip_od_1
adapter_body_length = step_length * num_steps; // 100mm total

// Control box mounting bracket on -X side (outer face at x_local = -65mm -> Y_world = -65mm).
// Spans y_local = -65..+4mm (Z_world = 0..69mm, matching control_box_exit_mount height)
// and z_local = 0..80mm (X_world = x_adapter..x_adapter+80mm, resting on z_local = 0 bed).
bracket_face_x = -cradle_ground_offset; // -65mm (flush with flange outer radius)
bracket_thickness = 4;              // Bracket plate thickness along X (mm)
bracket_height_y = 69;              // Vertical height in assembly along Y_local (Z_world = 0..69mm)
bracket_length_z = 80;              // Axial width in assembly along Z_local (X_world span = 80mm)
bracket_center_z = bracket_length_z / 2; // 40mm axial center for bolts & sensor window
gusset_thickness = 5;               // Gusset rib thickness in Y_local (mm)

// ========== MODULES ==========

module adapter_sensor_window_cut() {
    // Cutout through the x_local = -65..-61mm bracket plate that aligns with
    // control_box_exit_mount's sensor window (44mm along trap axis, Z_world = 12..42mm)
    // and adds a 45-deg gable at the top (+z_local) edge for supportless vertical printing.
    win_y_min = -cradle_ground_offset + sensor_window_base_z; // -53mm (Z_world = 12mm)
    win_y_max = win_y_min + sensor_window_rect_height;        // -23mm (Z_world = 42mm)
    win_y_mid = (win_y_min + win_y_max) / 2;                  // -38mm (Z_world = 27mm)
    win_z_min = bracket_center_z - sensor_window_width / 2;   // 18mm
    win_z_max = bracket_center_z + sensor_window_width / 2;   // 62mm
    gable_h = sensor_window_rect_height / 2;                  // 15mm (45-deg roof in +Z)

    translate([bracket_face_x - 1, 0, 0])
        rotate([0, 90, 0])
            linear_extrude(height=bracket_thickness + 4)
                polygon(points=[
                    [-win_z_min, win_y_min],
                    [-win_z_max, win_y_min],
                    [-(win_z_max + gable_h), win_y_mid],
                    [-win_z_max, win_y_max],
                    [-win_z_min, win_y_max]
                ]);
}

module vacuum_adapter_universal() {
    joint_height = lip_length + flange_thickness; // 15mm
    collar_height = 5;                            // 5mm transition collar above joint
    steps_start_z = joint_height + collar_height + taper_length; // 34mm

    step_ods = [grip_od_1, grip_od_2, grip_od_3, grip_od_4];
    bore_ids = [bore_id_1, bore_id_2, bore_id_3, bore_id_4];
    hose_ids = [hose_id_1, hose_id_2, hose_id_3, hose_id_4];

    socket_id = tube_od + 2*lip_clearance;
    inner_taper_h = (socket_id - tube_id) / 2;

    bolt_y_center = -cradle_ground_offset + mount_bolt_center_z; // -30mm (Z_world = 35mm)

    difference() {
        union() {
            // --- FEMALE FLANGE JOINT at z=0 (rests flat on build plate) ---
            flange_joint_female(include_cable_conduit=true);

            // --- COLLAR + CONICAL TRANSITION from tube_od to Step 1 ---
            translate([0, 0, joint_height])
                cylinder(d=tube_od, h=collar_height);

            translate([0, 0, joint_height + collar_height])
                cylinder(d1=tube_od, d2=grip_od_1, h=taper_length);

            // --- STEPPED ADAPTER BODY (continuous connected frustums + cylinders) ---
            translate([0, 0, steps_start_z]) {
                // Step 1: full cylindrical length
                cylinder(d=grip_od_1, h=step_length);

                // Steps 2..4: conical shoulder transition followed by straight grip cylinder
                for (i = [1 : num_steps - 1]) {
                    z_step = i * step_length;
                    translate([0, 0, z_step]) {
                        cylinder(d1=step_ods[i - 1], d2=step_ods[i], h=step_taper);
                        translate([0, 0, step_taper])
                            cylinder(d=step_ods[i], h=step_length - step_taper);
                    }
                }

                // Beveled friction ribs near the top of each step (45-deg slopes, zero overhang)
                for (i = [0 : num_steps - 1]) {
                    step_od = step_ods[i];
                    hose_id = hose_ids[i];
                    rib_od = (step_od + hose_id) / 2;
                    z_rib = i * step_length + step_length - 5;
                    translate([0, 0, z_rib]) {
                        cylinder(d1=step_od, d2=rib_od, h=1);
                        translate([0, 0, 1])
                            cylinder(d=rib_od, h=1.5);
                        translate([0, 0, 2.5])
                            cylinder(d1=rib_od, d2=step_od, h=1);
                    }
                }
            }

            // --- CONTROL BOX MOUNTING BRACKET (-X side, outer face at x_local = -65mm) ---
            translate([bracket_face_x, -cradle_ground_offset, 0])
                cube([bracket_thickness, bracket_height_y, bracket_length_z]);

            // Base flange tie-in plate at z = 0..flange_thickness (fuses bracket to flange on bed)
            hull() {
                translate([bracket_face_x, -cradle_ground_offset, 0])
                    cube([bracket_thickness, bracket_height_y, flange_thickness]);
                translate([-tube_id/2 + 5, -cradle_ground_offset, 0])
                    cube([4, bracket_height_y, flange_thickness]);
            }

            // Dual full-height structural gussets (start on build plate at z=0, fuse into
            // adapter wall, and clear the sensor window and M3 mounting bolts).
            // Gusset 1: y_local = -22..-17mm (between window top at -23mm and upper bolts at -7.5mm)
            // Gusset 2: y_local = -1..+4mm (above upper bolts at -7.5mm, at tube equator)
            for (gy = [-22, -1]) {
                hull() {
                    translate([bracket_face_x, gy, 0])
                        cube([bracket_thickness, gusset_thickness, bracket_length_z]);
                    translate([-22, gy, 0])
                        cube([4, gusset_thickness, bracket_length_z]);
                }
            }
        }

        // --- FEMALE SOCKET POCKET & TRANSITION ---
        translate([0, 0, -1])
            cylinder(d=socket_id, h=lip_length + 1.01);
        translate([0, 0, lip_length])
            cylinder(d1=socket_id, d2=tube_id, h=inner_taper_h + 0.01);

        // --- INTERNAL BORE (tube_id through joint and collar) ---
        translate([0, 0, inner_taper_h + lip_length - 0.1])
            cylinder(d=tube_id, h=joint_height + collar_height - (inner_taper_h + lip_length) + 0.2);

        // --- CONICAL BORE TRANSITION (tube_id to bore_id_1) ---
        translate([0, 0, joint_height + collar_height - 0.05])
            cylinder(d1=tube_id, d2=bore_id_1, h=taper_length + 0.1);

        // --- CONTINUOUS STEPPED INTERNAL BORE ---
        translate([0, 0, steps_start_z]) {
            // Step 1 bore
            translate([0, 0, -0.05])
                cylinder(d=bore_id_1, h=step_length + 0.1);

            // Steps 2..4 conical bore transitions + straight bores
            for (i = [1 : num_steps - 1]) {
                z_step = i * step_length;
                translate([0, 0, z_step - 0.05])
                    cylinder(d1=bore_ids[i - 1], d2=bore_ids[i], h=step_taper + 0.1);
                translate([0, 0, z_step + step_taper - 0.05])
                    cylinder(d=bore_ids[i], h=step_length - step_taper + (i == num_steps - 1 ? 2 : 0.1));
            }
        }

        // --- ALIGNED SENSOR WINDOW CUTOUT IN BRACKET ---
        adapter_sensor_window_cut();

        // --- BRACKET MOUNTING HOLES (4x M3 clearance, shared with control_box_exit_mount) ---
        // Under rotate([90, 0, 90]), z_local -> X_world (spacing 60mm) and y_local -> Z_world (spacing 45mm).
        for (dz = [-mount_bolt_spacing_x/2, mount_bolt_spacing_x/2]) {
            for (dy = [-mount_bolt_spacing_z/2, mount_bolt_spacing_z/2]) {
                translate([bracket_face_x - 1, bolt_y_center + dy, bracket_center_z + dz])
                    rotate([0, 90, 0])
                        cylinder(d=mount_bolt_diameter, h=bracket_thickness + 4);
            }
        }
    }
}

// ========== RENDER ==========
vacuum_adapter_universal();
