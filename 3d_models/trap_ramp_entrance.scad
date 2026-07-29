// ShopVac Rat Trap - Flat Ramp Entrance
// A solid-walled ramp with archway that transitions to the trap tube.
// Connects to trap_body_front via flange_joint_male at the rear.
// Prints flat on the build plate with no supports needed.

include <trap_modules.scad>

// ========== CORE PARAMETERS ==========

ramp_length = 150;              // Total length of ramp approach
ramp_width = 140;               // Wide base for stability (fits 220mm plate)
ramp_floor_thickness = 4;       // Solid floor panel thickness
side_wall_thickness = 3;        // Side wall panel thickness
side_wall_height_front = 20;    // Wall height at front (entry) end
archway_radius = tube_od / 2;   // Radius of circular archway opening at rear
rear_height = tube_od / 2 + flange_thickness + lip_length; // Total height at rear

// ========== MODULES ==========

module trap_ramp_entrance() {
    difference() {
        union() {
            // --- RAMP FLOOR (solid wedge) ---
            // A linear_extrude with scale creates a solid tapered floor slab.
            // Front: ramp_width x ramp_floor_thickness
            // Rear: ramp_width x ramp_floor_thickness (flat, angled by hull)
            hull() {
                // Front edge: low, flat
                translate([0, -ramp_width/2, 0])
                    cube([ramp_floor_thickness, ramp_width, ramp_floor_thickness]);

                // Rear edge: raised to tube center height minus tube radius
                // The tube center sits at archway_radius above the floor at rear
                translate([ramp_length - ramp_floor_thickness, -ramp_width/2, 0])
                    cube([ramp_floor_thickness, ramp_width, ramp_floor_thickness]);
            }

            // --- LEFT SIDE WALL (solid panel) ---
            hull() {
                // Front left: short wall
                translate([0, -ramp_width/2, 0])
                    cube([ramp_floor_thickness, side_wall_thickness, side_wall_height_front]);

                // Rear left: tall wall matching archway height
                translate([ramp_length - ramp_floor_thickness, -ramp_width/2, 0])
                    cube([ramp_floor_thickness, side_wall_thickness, rear_height]);
            }

            // --- RIGHT SIDE WALL (solid panel) ---
            hull() {
                // Front right: short wall
                translate([0, ramp_width/2 - side_wall_thickness, 0])
                    cube([ramp_floor_thickness, side_wall_thickness, side_wall_height_front]);

                // Rear right: tall wall matching archway height
                translate([ramp_length - ramp_floor_thickness, ramp_width/2 - side_wall_thickness, 0])
                    cube([ramp_floor_thickness, side_wall_thickness, rear_height]);
            }

            // --- ARCHWAY BACK WALL with circular opening ---
            // Solid rear plate with tube-diameter hole
            translate([ramp_length - side_wall_thickness, 0, 0]) {
                difference() {
                    // Solid back plate
                    translate([0, -ramp_width/2, 0])
                        cube([side_wall_thickness, ramp_width, rear_height]);

                    // Circular archway opening centered at tube axis height
                    translate([-1, 0, archway_radius])
                        rotate([0, 90, 0])
                            cylinder(d=tube_od, h=side_wall_thickness + 2);
                }
            }

            // --- ROOF PANEL (covers top from midpoint to rear) ---
            // Prevents escape over the top near the tube connection
            hull() {
                translate([ramp_length * 0.5, -ramp_width/2, side_wall_height_front])
                    cube([ramp_floor_thickness, ramp_width, ramp_floor_thickness]);

                translate([ramp_length - ramp_floor_thickness, -ramp_width/2, rear_height - ramp_floor_thickness])
                    cube([ramp_floor_thickness, ramp_width, ramp_floor_thickness]);
            }

            // --- FLANGE JOINT (male) to connect to trap body front ---
            // Positioned at rear, centered on tube axis
            translate([ramp_length, 0, archway_radius])
                rotate([0, 90, 0])
                    rotate([0, 0, 180])
                        flange_joint_male();
        }

        // --- HOLLOW INTERIOR ---
        // Carve out the inside of the ramp to create a passageway.
        // The rear shape uses a cylinder matching the archway opening to
        // avoid thin triangular slivers at square-to-circle corners.
        hull() {
            // Front opening (wide, low rectangle)
            translate([ramp_floor_thickness, -(ramp_width/2 - side_wall_thickness), ramp_floor_thickness])
                cube([1, ramp_width - 2*side_wall_thickness, side_wall_height_front - ramp_floor_thickness]);

            // Rear opening (cylinder matching archway, avoids corner slivers)
            translate([ramp_length - side_wall_thickness - 1, 0, archway_radius])
                rotate([0, 90, 0])
                    cylinder(d=tube_id, h=1);
        }

        // Ensure tube bore clears through the back wall and into the flange
        translate([ramp_length - side_wall_thickness - 1, 0, archway_radius])
            rotate([0, 90, 0])
                cylinder(d=tube_id, h=side_wall_thickness + flange_thickness + lip_length + 10);
    }
}

// ========== RENDER ==========
trap_ramp_entrance();
