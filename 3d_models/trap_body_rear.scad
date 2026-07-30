// ShopVac Rat Trap - Trap Body Rear Half
// Rear half of the main trap body (125mm tube section).
// Connects to trap_body_front via flange_joint_female at z=0 end,
// and to vacuum_adapter via flange_joint_male at z=body_length end.
// Includes cable channel and flat cradle base.

include <trap_modules.scad>

// ========== CORE PARAMETERS ==========

body_length = 125;                  // Tube section length (not including joints)
cradle_height = 15;                 // Height of flat cradle below tube center
cradle_width = tube_od + 10;        // Width of cradle base

// ========== MODULES ==========

module trap_body_rear() {
    // The body sits above the female joint.
    body_z_offset = lip_length + flange_thickness; // 15mm

    difference() {
        union() {
            // --- FEMALE JOINT at z=0 (front end, mates with front body male) ---
            flange_joint_female();

            // --- MAIN TUBE BODY ---
            translate([0, 0, body_z_offset])
                tube(length=body_length, od=tube_od, wall=wall_thickness);

            // --- CABLE CHANNEL (external, along top) ---
            translate([0, 0, body_z_offset]) {
                translate([0, tube_od/2 + cable_channel_od/2 - 2, 0])
                    cylinder(d=cable_channel_od, h=body_length);
                translate([-cable_channel_od/4, tube_od/2 - 1, 0])
                    cube([cable_channel_od/2, cable_channel_od/2 + 1, body_length]);
            }

            // --- MALE JOINT at z=body_length (rear end, connects to vacuum adapter) ---
            translate([0, 0, body_z_offset + body_length])
                flange_joint_male();

            // --- FLAT CRADLE BASE ---
            translate([0, 0, body_z_offset])
            difference() {
                translate([-cradle_width/2, -tube_od/2 - cradle_height, 0])
                    cube([cradle_width, cradle_height + tube_od/2, body_length]);

                // Carve out tube exterior so cradle wraps around bottom
                translate([0, 0, -1])
                    cylinder(d=tube_od, h=body_length + 2);
            }
        }

        // --- HOLLOW BORE (full length through entire part) ---
        translate([0, 0, -1])
            cylinder(d=tube_id, h=body_z_offset + body_length +
                     flange_thickness + lip_length + 2);

        // --- CABLE CHANNEL HOLLOW ---
        translate([0, tube_od/2 + cable_channel_od/2 - 2, body_z_offset - 1])
            cylinder(d=cable_channel_id, h=body_length + 2);
    }
}

// ========== RENDER ==========
trap_body_rear();
