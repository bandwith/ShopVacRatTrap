// ShopVac Rat Trap - Modular Bait Station
// Tube section with external bait port and bayonet-twist cap.
// Uses trap_module_base for the main tube body with flange joints.
// The cap uses L-shaped bayonet slots (much more printable than threads).

include <trap_modules.scad>

// ========== CORE PARAMETERS ==========

bait_length = 80;                   // Tube body length
cap_od = 46;                        // Cap outer diameter
port_id = 36;                       // Inner bore of bait port
port_od = 40;                       // Outer diameter of port neck
port_neck_height = 15;              // How far the neck extends from tube
cap_height = 18;                    // Total cap height
bayonet_tab_count = 3;             // Number of locking tabs
bayonet_tab_width = 8;            // Width of each tab
bayonet_tab_height = 3;           // Thickness of tab
bayonet_slot_depth = 5;           // Vertical drop of L-slot
bayonet_rotation = 30;            // Degrees to twist for lock
gasket_groove_width = 2.5;        // Width of sealing groove
gasket_groove_depth = 1.5;        // Depth of sealing groove

// ========== MODULES ==========

module bait_station_module() {
    body_z_offset = lip_length + flange_thickness; // 15mm

    difference() {
        union() {
            // --- MAIN TUBE BODY with joints ---
            trap_module_base(bait_length);

            // --- BAIT PORT NECK ---
            // External cylinder on the bottom, centered along tube length.
            // Points downward (negative Y direction).
            translate([0, 0, body_z_offset + bait_length/2])
                rotate([90, 0, 0])
                    translate([0, 0, 0]) {
                        // Neck cylinder extending outward from tube surface
                        cylinder(d=port_od, h=tube_od/2 + port_neck_height);

                        // Bayonet slot ring (slightly larger OD for the slot features)
                        translate([0, 0, tube_od/2 + port_neck_height - bayonet_slot_depth - bayonet_tab_height])
                            cylinder(d=port_od + 2, h=bayonet_slot_depth + bayonet_tab_height);
                    }
        }

        // --- BAIT PORT THROUGH-HOLE ---
        translate([0, 0, body_z_offset + bait_length/2])
            rotate([90, 0, 0])
                translate([0, 0, -tube_od/2 - 1])
                    cylinder(d=port_id, h=tube_od + port_neck_height + 2);

        // --- BAYONET L-SLOTS ---
        // Cut L-shaped slots into the neck for cap tabs to engage
        translate([0, 0, body_z_offset + bait_length/2])
            rotate([90, 0, 0])
                translate([0, 0, tube_od/2 + port_neck_height - bayonet_slot_depth - bayonet_tab_height]) {
                    for (i = [0 : bayonet_tab_count - 1]) {
                        rotate([0, 0, i * (360 / bayonet_tab_count)]) {
                            // Vertical entry slot
                            translate([port_od/2 - 1, -bayonet_tab_width/2, 0])
                                cube([3, bayonet_tab_width, bayonet_slot_depth + bayonet_tab_height + 1]);

                            // Horizontal lock channel (rotational)
                            translate([0, 0, 0])
                                rotate_extrude(angle=bayonet_rotation)
                                    translate([port_od/2 - 1, 0, 0])
                                        square([3, bayonet_tab_height]);
                        }
                    }
                }
    }
}

module bait_cap() {
    // Bayonet-twist cap with grip ribs and gasket groove.
    // Tabs on cap engage L-slots on neck.

    // Cavity must clear the bayonet ring (port_od + 2) with print tolerance
    cap_id = port_od + 2 + 2*print_tolerance; // Fits over bayonet ring with clearance

    difference() {
        union() {
            // --- CAP BODY ---
            cylinder(d=cap_od, h=cap_height);

            // --- GRIP RIBS (external) ---
            for (r = [0 : 30 : 330]) {
                rotate([0, 0, r])
                    translate([cap_od/2 - 0.5, -1, 2])
                        cube([2, 2, cap_height - 4]);
            }
        }

        // --- INTERNAL CAVITY (receives port neck) ---
        translate([0, 0, 3])
            cylinder(d=cap_id, h=cap_height);

        // --- GASKET GROOVE (rectangular channel in cap ceiling) ---
        translate([0, 0, 2])
            difference() {
                cylinder(d=port_id + gasket_groove_width * 2, h=gasket_groove_depth);
                translate([0, 0, -1])
                    cylinder(d=port_id, h=gasket_groove_depth + 2);
            }
    }

    // --- BAYONET LOCKING TABS (added after cavity subtraction) ---
    // Tabs must match slot radii: inner at port_od/2 - 1 (19mm),
    // radial width 2.7mm (3mm slot minus clearance). This aligns
    // with the slot geometry cut at port_od/2 - 1 with 3mm depth.
    translate([0, 0, cap_height - bayonet_tab_height]) {
        for (i = [0 : bayonet_tab_count - 1]) {
            rotate([0, 0, i * (360 / bayonet_tab_count)])
                translate([port_od/2 - 1, -bayonet_tab_width/2, 0])
                    cube([2.7, bayonet_tab_width, bayonet_tab_height]);
        }
    }
}

// ========== RENDER ==========
bait_station_module();
