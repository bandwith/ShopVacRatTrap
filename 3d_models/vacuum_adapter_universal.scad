// ShopVac Rat Trap - Universal Vacuum Adapter
// Stepped adapter connecting the trap tube (4" PVC) to various shop vac hoses.
// Uses flange_joint_female at top (mates with rear body's male end).
// Steps down internally to fit 3", 2.5", 1.875", and 1.25" hoses.
// Includes friction ribs for hose grip and control box mounting bracket.

include <trap_modules.scad>

// ========== CORE PARAMETERS ==========

adapter_wall = 3;                   // Adapter body wall thickness

// Hose inner diameters (stepped sizes, largest to smallest)
hose_id_1 = 76.2;                  // 3.0" hose
hose_id_2 = 63.5;                  // 2.5" hose
hose_id_3 = 47.6;                  // 1.875" hose
hose_id_4 = 31.75;                 // 1.25" hose

step_length = 25;                   // Length of each step section
num_steps = 4;
taper_length = 10;                  // Length of conical bore transition
adapter_body_length = step_length * num_steps; // 100mm total

// Control box mounting bracket
bracket_width = 80;                 // Width of mounting bracket
bracket_thickness = 4;              // Bracket plate thickness
bracket_height = 70;                // Height of bracket plate
gusset_thickness = 4;              // Gusset rib thickness
gusset_depth = 20;                 // How far gussets extend from body

// ========== MODULES ==========

module vacuum_adapter_universal() {
    // The female joint is at the top (z=0), connecting to the trap tube.
    // The adapter body extends downward (printed large-end-down for no supports).
    // For simplicity, we build it upward: flange at top, steps going down.
    // Actually, let's orient with flange at z=0, body extending in +Z (hose end up).
    // The user prints it with the large end (flange) on the bed.

    joint_height = lip_length + flange_thickness; // Female joint total height

    difference() {
        union() {
            // --- FEMALE FLANGE JOINT (trap connection end) ---
            flange_joint_female();

            // --- TRANSITION: tube OD bridging joint to stepped body ---
            // Includes extra length for the internal conical taper zone
            translate([0, 0, joint_height])
                cylinder(d=tube_od, h=5 + taper_length);

            // --- STEPPED ADAPTER BODY ---
            translate([0, 0, joint_height + 5 + taper_length]) {
                // Step 1: largest (3" hose)
                cylinder(d=hose_id_1 + 2*adapter_wall, h=step_length);

                // Step 2: 2.5" hose
                translate([0, 0, step_length])
                    cylinder(d=hose_id_2 + 2*adapter_wall, h=step_length);

                // Step 3: 1.875" hose
                translate([0, 0, step_length * 2])
                    cylinder(d=hose_id_3 + 2*adapter_wall, h=step_length);

                // Step 4: smallest (1.25" hose)
                translate([0, 0, step_length * 3])
                    cylinder(d=hose_id_4 + 2*adapter_wall, h=step_length);
            }

            // --- FRICTION RIBS (external rings for hose grip) ---
            translate([0, 0, joint_height + 5 + taper_length]) {
                for (i = [0 : num_steps - 1]) {
                    step_od = [hose_id_1, hose_id_2, hose_id_3, hose_id_4][i] + 2*adapter_wall;
                    // Rib near the end of each step
                    translate([0, 0, i * step_length + step_length - 5])
                        difference() {
                            cylinder(d=step_od + 2, h=2);
                            translate([0, 0, -1])
                                cylinder(d=step_od - 2, h=4);
                        }
                }
            }

            // --- CONTROL BOX MOUNTING BRACKET ---
            // Vertical plate extending from the adapter body with gussets
            translate([0, 0, 0]) {
                // Main bracket plate (extends to one side)
                translate([-bracket_width/2, -tube_od/2 - bracket_thickness, 0])
                    cube([bracket_width, bracket_thickness, bracket_height]);

                // Left gusset (triangular rib for strength)
                translate([-bracket_width/2, -tube_od/2 - bracket_thickness, 0])
                    hull() {
                        cube([gusset_thickness, bracket_thickness, bracket_height]);
                        cube([gusset_thickness, gusset_depth, 5]);
                    }

                // Right gusset
                translate([bracket_width/2 - gusset_thickness, -tube_od/2 - bracket_thickness, 0])
                    hull() {
                        cube([gusset_thickness, bracket_thickness, bracket_height]);
                        cube([gusset_thickness, gusset_depth, 5]);
                    }
            }
        }

        // --- INTERNAL BORE (tube ID through joint and transition start) ---
        translate([0, 0, -1])
            cylinder(d=tube_id, h=joint_height + 5 + 2);

        // --- CONICAL BORE TRANSITION (tube_id to hose_id_1) ---
        // Smooth taper eliminates the sharp ledge that would accumulate debris
        // and cause turbulence. Transitions from 95.2mm to 76.2mm over 10mm.
        translate([0, 0, joint_height + 5 - 1])
            cylinder(d1=tube_id, d2=hose_id_1, h=taper_length + 1);

        // --- STEPPED INTERNAL HOLLOWS ---
        translate([0, 0, joint_height + 5 + taper_length]) {
            // Step 1 hollow
            translate([0, 0, -1])
                cylinder(d=hose_id_1, h=step_length + 2);

            // Step 2 hollow
            translate([0, 0, step_length - 1])
                cylinder(d=hose_id_2, h=step_length + 2);

            // Step 3 hollow
            translate([0, 0, step_length * 2 - 1])
                cylinder(d=hose_id_3, h=step_length + 2);

            // Step 4 hollow (through to end)
            translate([0, 0, step_length * 3 - 1])
                cylinder(d=hose_id_4, h=step_length + 2);
        }

        // --- BRACKET MOUNTING HOLES (4x M3 clearance) ---
        // Arranged in rectangle pattern for control box attachment
        for (dx = [-bracket_width/2 + 10, bracket_width/2 - 10]) {
            for (dz = [15, bracket_height - 10]) {
                translate([dx, -tube_od/2 - bracket_thickness - 1, dz])
                    rotate([-90, 0, 0])
                        cylinder(d=3.5, h=bracket_thickness + 2);
            }
        }
    }
}

// ========== RENDER ==========
vacuum_adapter_universal();
