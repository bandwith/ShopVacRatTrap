// ShopVac Rat Trap - Trap Body Front Half
// Front half of the main trap body (125mm tube section).
// Connects to ramp entrance via flange_joint_female at z=0 end,
// and to trap_body_rear via flange_joint_male at z=body_length end.
// Includes bait port boss and flat cradle base.

include <trap_modules.scad>

// ========== CORE PARAMETERS ==========

body_length = 125;                  // Tube section length (not including joints)
cradle_height = 15;                 // Height of flat cradle below tube center
cradle_width = tube_od + 10;        // Width of cradle base
bait_port_diameter = 40;            // Interior bore of bait port
bait_port_boss_height = 15;         // How far the boss extends from tube surface
bait_port_wall = 3;                 // Wall thickness of bait port neck

// ========== MODULES ==========

module trap_body_front() {
    // The body sits above the female joint.
    // body_z_offset accounts for the female joint below z=0
    body_z_offset = lip_length + flange_thickness; // 15mm

    difference() {
        union() {
            // --- FEMALE JOINT at z=0 (entrance end) ---
            flange_joint_female();

            // --- MAIN TUBE BODY ---
            translate([0, 0, body_z_offset])
                tube(length=body_length, od=tube_od, wall=wall_thickness);

            // --- CABLE CHANNEL (external, along top) ---
            translate([0, 0, body_z_offset]) {
                // Channel conduit
                translate([0, tube_od/2 + cable_channel_od/2 - 2, 0])
                    cylinder(d=cable_channel_od, h=body_length);
                // Bridge to tube
                translate([-cable_channel_od/4, tube_od/2 - 1, 0])
                    cube([cable_channel_od/2, cable_channel_od/2 + 1, body_length]);
            }

            // --- MALE JOINT at z=body_length (rear end, connects to rear half) ---
            translate([0, 0, body_z_offset + body_length])
                flange_joint_male();

            // --- FLAT CRADLE BASE ---
            // A cradle that supports the tube without intruding into the bore.
            translate([0, 0, body_z_offset])
            difference() {
                // Solid rectangular base
                translate([-cradle_width/2, -tube_od/2 - cradle_height, 0])
                    cube([cradle_width, cradle_height + tube_od/2, body_length]);

                // Carve out the tube exterior shape so cradle wraps around bottom
                translate([0, 0, -1])
                    cylinder(d=tube_od, h=body_length + 2);
            }

            // --- BAIT PORT BOSS ---
            // External cylinder on the bottom of the tube for bait station connection.
            // Positioned at 75mm along body (centered in front half).
            translate([0, 0, body_z_offset + body_length - 50])
                rotate([90, 0, 0])
                    translate([0, 0, 0])
                        cylinder(d=bait_port_diameter + 2*bait_port_wall,
                                 h=tube_od/2 + bait_port_boss_height);
        }

        // --- HOLLOW BORE (full length through entire part) ---
        translate([0, 0, -1])
            cylinder(d=tube_id, h=body_z_offset + body_length +
                     flange_thickness + lip_length + 2);

        // --- CABLE CHANNEL HOLLOW ---
        translate([0, tube_od/2 + cable_channel_od/2 - 2, body_z_offset - 1])
            cylinder(d=cable_channel_id, h=body_length + 2);

        // --- BAIT PORT THROUGH-HOLE ---
        // Clear hole through tube wall and boss
        translate([0, 0, body_z_offset + body_length - 50])
            rotate([90, 0, 0])
                translate([0, 0, -tube_od/2 - 1])
                    cylinder(d=bait_port_diameter,
                             h=tube_od + bait_port_boss_height + 2);

        // --- TRIM CRADLE: remove anything above tube center ---
        // The cradle should only exist below the tube
        translate([0, 0, body_z_offset])
            translate([-cradle_width, 0, -1])
                cube([cradle_width * 2, tube_od, body_length + 2]);
    }
}

// ========== RENDER ==========
trap_body_front();
