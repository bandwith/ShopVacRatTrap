// ShopVac Rat Trap - Modular Bait Station
// Tube section with side-mounted (+X) bayonet bait port, flat cradle base (-Y),
// and bayonet-twist cap.
// Uses trap_module_base for the main tube body with flange joints.

include <trap_modules.scad>

// ========== CORE PARAMETERS ==========

bait_length = 80;                   // Tube body length
cradle_width = 70;                  // Cradle base width (clears 45-deg flange bolts)
cap_od = bait_cap_od;               // 46mm
port_id = bait_port_id;             // 36mm
port_od = bait_port_od;             // 40mm
port_neck_height = bait_port_neck_height; // 15mm
cap_height = bait_cap_height;       // 18mm

// ========== MODULES ==========

module bait_station_module() {
    body_z_offset = lip_length + flange_thickness; // 15mm
    port_z = body_z_offset + bait_length / 2;      // 55mm

    difference() {
        union() {
            // Main tube body with female flange (z=0), male flange (top), and cable conduit
            trap_module_base(bait_length, male_end=true, female_end=true);

            // Flat cradle base flush with ground plane (-Y = -65mm)
            tube_cradle_base(bait_length, cradle_width=cradle_width);

            // Side-mounted (+X) bayonet bait port boss
            bayonet_bait_port_boss(port_z);
        }

        // Bayonet bait port bore and L-slots
        bayonet_bait_port_cuts(port_z);
    }
}

module bait_cap() {
    // Bayonet-twist cap with grip ribs and gasket groove.
    // Printed closed-face down on the build plate (z=0) with 45-deg chamfers
    // under the bayonet locking tabs and grip ribs for 100% supportless printing.
    cap_id = port_od + 2 + 2*print_tolerance; // 42.6mm (clears 42mm bayonet ring)
    tab_inner_r = port_od/2 - 1 + print_tolerance; // 19.3mm (clears 19mm slot floor)
    tab_outer_r = cap_id/2 + 0.5;             // Fused into inner cap wall
    tab_radial_depth = (cap_id/2) - tab_inner_r; // ~2.0mm inward projection

    difference() {
        union() {
            // Main cylindrical cap body (flat top resting on build plate at z=0)
            cylinder(d=cap_od, h=cap_height);

            // External vertical grip ribs (start at z=0 on build plate, beveled at top)
            for (r = [0 : 30 : 330]) {
                rotate([0, 0, r])
                    hull() {
                        translate([cap_od/2 - 1, -1.2, 0])
                            cube([2.2, 2.4, cap_height - 2]);
                        translate([cap_od/2 - 1, -0.8, 0])
                            cube([0.5, 1.6, cap_height]);
                    }
            }
        }

        // Internal cavity receiving port neck (ceiling at z=3mm)
        translate([0, 0, 3])
            cylinder(d=cap_id, h=cap_height);

        // Gasket groove cut into the interior ceiling at z=3mm (opens into cavity)
        translate([0, 0, 3 - gasket_groove_depth])
            difference() {
                cylinder(d=port_id + 2*gasket_groove_width, h=gasket_groove_depth + 0.1);
                translate([0, 0, -1])
                    cylinder(d=port_id, h=gasket_groove_depth + 2);
            }
    }

    // 3x cylindrical bayonet locking tabs at open rim (z = cap_height - bayonet_tab_height)
    // with 45-deg lower support taper so they print with zero overhang.
    for (i = [0 : bayonet_tab_count - 1]) {
        rotate([0, 0, bayonet_angle_offset + i * (360 / bayonet_tab_count) - bayonet_tab_angle/2])
            rotate_extrude(angle=bayonet_tab_angle)
                polygon(points=[
                    [tab_outer_r, cap_height - bayonet_tab_height - tab_radial_depth],
                    [tab_outer_r, cap_height],
                    [tab_inner_r, cap_height],
                    [tab_inner_r, cap_height - bayonet_tab_height]
                ]);
    }
}

// ========== RENDER ==========
bait_station_module();
