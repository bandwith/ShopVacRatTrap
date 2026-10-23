// ShopVac Rat Trap - Trap Body Front Half
// Front half of the main trap body (125mm tube section).
// Connects to ramp entrance via flange_joint_female at z=0 end,
// and to trap_body_rear via flange_joint_male at z=body_z_offset+body_length end.
// Includes side-mounted bayonet bait port (+X) and full-length flat cradle base (-Y).

include <trap_modules.scad>

// ========== CORE PARAMETERS ==========

body_length = 125;                  // Tube section length (not including joints)
cradle_width = 70;                  // Cradle base width (clears 45-deg flange bolts)
bait_port_z_offset = 75;            // Axial position of bait port along body_length

// ========== MODULES ==========

module trap_body_front() {
    body_z_offset = lip_length + flange_thickness; // 15mm
    port_z = body_z_offset + bait_port_z_offset;   // 90mm

    difference() {
        union() {
            // Main tube with female flange (z=0), male flange (top), and cable conduit
            trap_module_base(body_length, male_end=true, female_end=true);

            // Continuous flat cradle base from z=0 (build plate) to top flange
            tube_cradle_base(body_length, cradle_width=cradle_width);

            // Side-mounted bayonet bait port boss (+X direction)
            bayonet_bait_port_boss(port_z);
        }

        // Bayonet bait port bore and L-slots
        bayonet_bait_port_cuts(port_z);
    }
}

// ========== RENDER ==========
trap_body_front();
