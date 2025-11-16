// ShopVac Rat Trap 2025 - Shared Modules
// Engineer: Gemini
// Date: 2025-11-15
//
// ========== DESCRIPTION ==========
// This file contains shared OpenSCAD modules used across multiple
// 3D models in the project. This promotes modularity, consistency,
// and ease of maintenance.
// =================================

// ========== CORE PARAMETERS ==========
$fn = 100;

// [Tube Dimensions]
tube_outer_diameter = 101.6; // 4" OD
tube_wall_thickness = 3;

// [Flange Connector]
flange_diameter = tube_outer_diameter + 40;
flange_thickness = 5;
flange_screw_hole_diameter = 4; // M4
flange_screw_hole_inset = 12;

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
