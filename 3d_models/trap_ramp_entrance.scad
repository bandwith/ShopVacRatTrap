// ShopVac Rat Trap - Flat Ramp Entrance
// Wide, low-threshold entrance ramp that funnels smoothly into the 4" circular trap tube.
// Connects to trap_body_front via flange_joint_male at the top (+Z end).
// Oriented in printable perspective: wide entrance face flat on the build plate (z=0),
// rising vertically along +Z to the male flange joint at z=ramp_length (150mm)
// so the entire ramp prints with zero supports and zero overhangs.

include <trap_modules.scad>

// ========== CORE PARAMETERS ==========

ramp_length = 150;                  // Total axial length of ramp approach (mm)
ramp_taper_length = 128;            // Length over which wide entrance transitions to tube
ramp_width = 130;                   // Wide base at entrance (matches flange_od, fits 220mm bed)
rear_cradle_width = 70;             // Rear base width (matches trap_body_front cradle, clears bolts)
ramp_floor_thickness = 4;           // Floor panel thickness at entrance (mm)
side_wall_thickness = 4;            // Side wall thickness at entrance (mm)
side_wall_height_front = 40;        // Side wall vertical height at entrance before arch (mm)
archway_radius = tube_od / 2;       // Radius of circular archway at rear (50.8mm)

// ========== MODULES ==========

module trap_ramp_entrance() {
    chamfer_h = (flange_od - tube_od) / 2; // 14.2mm male flange support cone height
    neck_length = ramp_length - ramp_taper_length; // 22mm straight collar below male flange

    difference() {
        union() {
            // --- LOFT FROM WIDE FLAT-FLOOR ENTRANCE (z=0) TO CIRCULAR TUBE (z=ramp_taper_length) ---
            hull() {
                // Front entrance outer profile (z = 0..1mm, flat on build plate)
                union() {
                    translate([-ramp_width/2, -cradle_ground_offset, 0])
                        cube([ramp_width, side_wall_height_front, 1]);
                    cylinder(d=tube_od + 2*wall_thickness, h=1);
                }

                // Rear outer profile at end of ramp flare (z = ramp_taper_length - 1 .. ramp_taper_length)
                translate([0, 0, ramp_taper_length - 1])
                    union() {
                        cylinder(d=tube_od, h=1);
                        translate([-rear_cradle_width/2, -cradle_ground_offset, 0])
                            cube([rear_cradle_width, cradle_ground_offset - tube_id/2 + 2, 1]);
                    }
            }

            // --- STRAIGHT NECK & CRADLE EXTENSION UP TO MALE FLANGE (z=ramp_taper_length..ramp_length) ---
            translate([0, 0, ramp_taper_length]) {
                cylinder(d=tube_od, h=neck_length);
                translate([-rear_cradle_width/2, -cradle_ground_offset, 0])
                    cube([rear_cradle_width, cradle_ground_offset - tube_id/2 + 2,
                          neck_length + flange_thickness]);
            }

            // --- TOP CABLE CONDUIT ---
            cable_conduit_outer(ramp_length);

            // --- MALE FLANGE JOINT AT REAR (+Z end, mates with trap_body_front) ---
            translate([0, 0, ramp_length])
                flange_joint_male(include_cable_conduit=true);
        }

        // --- TAPERED RAMP INTERIOR PASSAGEWAY ---
        // Funnels smoothly from a 122mm-wide flat floor (4mm above ground at z=0)
        // up a gentle slope to the 95.2mm circular tube bore at z=ramp_taper_length.
        hull() {
            // Front entrance inner opening at z = -0.1..1mm
            translate([0, 0, -0.1])
                union() {
                    translate([-(ramp_width/2 - side_wall_thickness),
                               -cradle_ground_offset + ramp_floor_thickness, 0])
                        cube([ramp_width - 2*side_wall_thickness,
                              side_wall_height_front - ramp_floor_thickness, 0.2]);
                    cylinder(d=tube_id, h=0.2);
                }

            // Rear circular bore at z = ramp_taper_length
            translate([0, 0, ramp_taper_length])
                cylinder(d=tube_id, h=0.2);
        }

        // --- REAR CYLINDRICAL BORE THROUGH NECK, MALE FLANGE, & LIP ---
        translate([0, 0, ramp_taper_length - 0.1])
            cylinder(d=tube_id, h=neck_length + flange_thickness + lip_length + 2);

        // --- HOLLOW TOP CABLE CONDUIT ---
        translate([0, cable_channel_y, -1])
            cylinder(d=cable_channel_id, h=ramp_length + flange_thickness + 2);
    }
}

// ========== RENDER ==========
trap_ramp_entrance();
