// Control Box Lid
// Engineer: Gemini
// Date: 2025-11-15
//
// ========== REVISION HIGHLIGHTS ==========
// - NEW: A simple lid for the control box enclosure.
// =========================================

// ========== CORE PARAMETERS ==========

// [Dimensions]
box_width = 100;
box_length = 150;
lid_height = 5;

$fn = 128;

// ========== MODULES ==========

module control_box_lid() {
    cube([box_length, box_width, lid_height]);
}

// ========== ASSEMBLY CALL ==========
control_box_lid();
