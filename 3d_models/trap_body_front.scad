// ShopVac Rat Trap - Trap Body Front Half
// Front half of the main trap body (125mm tube section).
// Connects to ramp entrance via flange_joint_female at z=0 end,
// and to bait_station / trap_body_rear via flange_joint_male at top (+Z) end.
// Includes full-length flat cradle base (-Y) and top cable conduit (+Y).

include <trap_modules.scad>

// ========== CORE PARAMETERS ==========

body_length = 125;                  // Tube section length (not including joints)
cradle_width = 70;                  // Cradle base width (clears 45-deg flange bolts)

// ========== MODULES ==========

module trap_body_front() {
    union() {
        // Main tube with female flange (z=0), male flange (top), and cable conduit
        trap_module_base(body_length, male_end=true, female_end=true);

        // Continuous flat cradle base from z=0 (build plate) to top flange
        tube_cradle_base(body_length, cradle_width=cradle_width);
    }
}

// ========== RENDER ==========
trap_body_front();
