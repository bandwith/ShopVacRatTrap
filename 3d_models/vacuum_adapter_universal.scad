// ShopVac Rat Trap - Universal Vacuum Adapter
// Stepped adapter connecting the trap tube (4" PVC) to various shop vac hoses.
// Oriented in printable perspective: female flange flat on build plate (z=0),
// stepped hose cones tapering upward (+Z) with 45-deg self-supporting transitions.
// Includes friction ribs for hose grip and control box mounting bracket with
// aligned sensor window cutout.

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

// Control box mounting bracket (outer mounting face flush with -cradle_ground_offset = -65mm)
bracket_width = 80;                 // Width of mounting bracket (X)
bracket_thickness = 4;              // Bracket plate thickness (Y)
bracket_height = 70;                // Height of bracket plate (Z)
bracket_face_y = -cradle_ground_offset; // -65mm (matches flange outer radius)
gusset_thickness = 4;               // Gusset rib thickness

// ========== MODULES ==========

module vacuum_adapter_universal() {
    joint_height = lip_length + flange_thickness; // 15mm
    collar_height = 5;                            // 5mm transition collar above joint
    steps_start_z = joint_height + collar_height + taper_length; // 34mm

    step_ods = [grip_od_1, grip_od_2, grip_od_3, grip_od_4];
    bore_ids = [bore_id_1, bore_id_2, bore_id_3, bore_id_4];
    hose_ids = [hose_id_1, hose_id_2, hose_id_3, hose_id_4];

    socket_id = tube_od + 2*lip_clearance;
    inner_taper_h = (socket_id - tube_id) / 2;

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

            // --- CONTROL BOX MOUNTING BRACKET ---
            // Outer mounting face at Y = bracket_face_y (-65mm, flush with flange edge).
            translate([-bracket_width/2, bracket_face_y, 0])
                cube([bracket_width, bracket_thickness, bracket_height]);

            // Base flange tie-in plate at z = 0..flange_thickness
            hull() {
                translate([-bracket_width/2, bracket_face_y, 0])
                    cube([bracket_width, bracket_thickness, flange_thickness]);
                translate([-bracket_width/2, -tube_id/2 + 5, 0])
                    cube([bracket_width, 4, flange_thickness]);
            }

            // Dual structural gussets at X = +/-24.5mm (between window edge |X|=22
            // and mounting bolts |X|=30, fused directly into the adapter wall).
            for (gx = [-22.5 - gusset_thickness, 22.5]) {
                hull() {
                    translate([gx, bracket_face_y, 0])
                        cube([gusset_thickness, bracket_thickness, bracket_height]);
                    translate([gx, -22, 0])
                        cube([gusset_thickness, 4, 32]);
                }
            }
        }

        // --- FEMALE SOCKET POCKET & TRANSITION (keep clear of bracket/gussets) ---
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

        // --- SIDE CABLE PASS-THROUGH HOLES IN FLANGE ---
        // Allows top cable conduit from trap_body_rear to pass through flange
        // even when adapter is rotated 90 degrees to side-mount the control box.
        for (cx = [-cable_channel_y, cable_channel_y]) {
            translate([cx, 0, -1])
                cylinder(d=cable_channel_id, h=flange_thickness + 2);
        }

        // --- ALIGNED SENSOR WINDOW CUTOUT IN BRACKET ---
        translate([0, bracket_face_y + bracket_thickness/2, sensor_window_base_z])
            printable_sensor_window(depth=bracket_thickness + 4);

        // --- BRACKET MOUNTING HOLES (4x M3 clearance, shared with control box) ---
        translate([0, bracket_face_y - 1, mount_bolt_center_z])
            control_box_bolt_pattern()
                rotate([-90, 0, 0])
                    cylinder(d=mount_bolt_diameter, h=bracket_thickness + 4);
    }
}

// ========== RENDER ==========
vacuum_adapter_universal();
