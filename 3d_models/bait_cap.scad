// ShopVac Rat Trap - Bait Cap (standalone render)
// Bayonet-twist cap for the bait station port.
// This file exists so the build script can generate bait_cap.stl
// independently from bait_station.stl.

include <trap_modules.scad>

// Bait station port parameters (must match bait_station.scad)
cap_od = 46;
port_id = 36;
port_od = 40;
port_neck_height = 15;
cap_height = 18;
bayonet_tab_count = 3;
bayonet_tab_width = 8;
bayonet_tab_height = 3;
bayonet_slot_depth = 5;
bayonet_rotation = 30;
gasket_groove_width = 2.5;
gasket_groove_depth = 1.5;

use <bait_station.scad>

// ========== RENDER ==========
bait_cap();
