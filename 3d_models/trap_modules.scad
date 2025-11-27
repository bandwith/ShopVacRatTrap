// ShopVac Rat Trap - Shared Modules
// Updated with actual component dimensions from BOM

// Global resolution
$fn = 32;

// === Tube Parameters ===
tube_outer_diameter = 101.6;  // 4 inches in mm (standard PVC size)
tube_wall_thickness = 3.2;    // Standard wall thickness
tube_inner_diameter = tube_outer_diameter - (2 * tube_wall_thickness);

// === Flange Parameters ===
flange_diameter = 120;         // Outer flange diameter
flange_thickness = 6;          // Flange thickness
flange_screw_hole_diameter = 4.5;  // M4 clearance holes
flange_screw_hole_inset = 10;  // Distance from flange edge

// === Center Joint - Alignment Pins ===
alignment_pin_diameter = 6;    // 6mm diameter pins
alignment_pin_length = 8;      // 8mm insertion depth
alignment_pin_radius = tube_outer_diameter/2 - 25;  // Position on flange
alignment_pin_clearance = 0.3; // Extra clearance for holes

// === Center Joint - O-Ring Seal ===
oring_groove_width = 3;        // Width of groove (for 2.5mm O-ring)
oring_groove_depth = 1.5;      // Depth of groove

// === STEMMA QT Sensor Mounts (Adafruit Standard) ===
// Standard STEMMA QT board: 17.78mm × 25.4mm (0.7" × 1.0")
stemma_qt_board_width = 17.78;   // Standard width
stemma_qt_board_length = 25.4;   // Standard length
stemma_qt_hole_diameter = 2.7;   // M2.5 clearance holes
stemma_qt_hole_spacing_w = 12.7; // Hole spacing width (0.5")
stemma_qt_hole_spacing_l = 20.3; // Hole spacing length (~0.8")
stemma_qt_mount_thickness = 3;   // Mount base thickness
stemma_qt_standoff_height = 5;   // PCB standoff height

// === PIR Sensor Mount (Adafruit 4871) ===
// Larger board: 32mm × 24mm
pir_board_width = 24;
pir_board_length = 32;
pir_hole_diameter = 3.2;      // M3 clearance
pir_hole_spacing = 28;        // Between mounting holes
pir_dome_diameter = 12;       // PIR dome clearance
pir_dome_height = 8;          // Dome projection

// ========== MODULES ==========

module flange(outer_diameter, thickness, screw_hole_diameter, screw_hole_inset) {
    difference() {
        cylinder(d = outer_diameter, h = thickness, center = true);
        cylinder(d = tube_outer_diameter, h = thickness + 1, center = true);

        // Screw holes
        for (a = [45, 135, 225, 315]) {
            rotate([0, 0, a]) {
                translate([outer_diameter/2 - screw_hole_inset, 0, 0]) {
                    cylinder(d = screw_hole_diameter, h = thickness + 1, center = true);
                }
            }
        }
    }
}

module tube(length, outer_diameter, wall_thickness) {
     difference() {
        cylinder(d=outer_diameter, h=length, center=true);
        cylinder(d=outer_diameter - (2*wall_thickness), h=length+1, center=true);
    }
}
