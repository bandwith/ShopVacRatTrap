// ShopVac Rat Trap - Flat Ramp Entrance
// Replaces cone funnel with printable flat ramp/archway design
// Date: 2025-11-27
//
// ========== DESIGN NOTES ==========
// - FLAT RAMP: Prints flat on bed, no supports needed
// - ARCHWAY DESIGN: Gradual slope for rodent entry
// - FLANGED CONNECTION: Connects to trap_entrance via standard flange
// =========================================

include <trap_modules.scad>

// ========== CORE PARAMETERS ==========

// [Dimensions]
ramp_length = 150;          // Total length of ramp approach
ramp_width = 120;           // Width (wider than tube for easy entry)
ramp_height = 40;           // Height at entrance (matches tube bottom)
wall_thickness = 3;

// [Ramp Profile]
ramp_angle = 15;            // Gentle slope for rodent entry
archway_height = 60;        // Height of archway opening
archway_width = 90;         // Width of archway opening

// ========== MODULES ==========

module trap_ramp_entrance() {
    difference() {
        union() {
            // Base ramp body (flat wedge)
            translate([0, -ramp_width/2, 0]) {
                hull() {
                    // Front edge (low, at origin)
                    cube([0.1, ramp_width, wall_thickness]);

                    // Back edge (connects to flange)
                    translate([ramp_length, 0, ramp_height])
                        cube([0.1, ramp_width, wall_thickness]);
                }
            }

            // Side walls (archway sides)
            translate([0, -ramp_width/2, 0]) {
                // Left wall
                hull() {
                    cube([0.1, wall_thickness, wall_thickness]);
                    translate([ramp_length, 0, archway_height])
                        cube([0.1, wall_thickness, wall_thickness]);
                }
            }

            translate([0, ramp_width/2 - wall_thickness, 0]) {
                // Right wall
                hull() {
                    cube([0.1, wall_thickness, wall_thickness]);
                    translate([ramp_length, 0, archway_height])
                        cube([0.1, wall_thickness, wall_thickness]);
                }
            }

            // Archway top
            translate([ramp_length - 10, -ramp_width/2, archway_height]) {
                cube([10, ramp_width, wall_thickness]);
            }

            // Flange at back (connection to trap_entrance)
            translate([ramp_length, 0, tube_outer_diameter/2]) {
                rotate([0, 90, 0])
                    flange(flange_diameter, flange_thickness, flange_screw_hole_diameter, flange_screw_hole_inset);
            }

            // Transition collar (ramp to tube)
            translate([ramp_length, 0, tube_outer_diameter/2]) {
                rotate([0, 90, 0])
                    cylinder(d=tube_outer_diameter, h=20, $fn=64);
            }
        }

        // Cut out for tube connection
        translate([ramp_length - 1, 0, tube_outer_diameter/2]) {
            rotate([0, 90, 0])
                cylinder(d=tube_outer_diameter - 2*wall_thickness, h=25, $fn=64);
        }

        // Alignment pin holes (for flange connection)
        translate([ramp_length, 0, tube_outer_diameter/2]) {
            rotate([0, 90, 0]) {
                for (a = [0, 180]) {
                    rotate([0, 0, a]) {
                        translate([alignment_pin_radius, 0, -flange_thickness/2 - 0.5]) {
                            cylinder(d=alignment_pin_diameter + alignment_pin_clearance,
                                   h=flange_thickness + 1, $fn=20);
                        }
                    }
                }
            }
        }
    }
}

// ========== ASSEMBLY CALL ==========
trap_ramp_entrance();
