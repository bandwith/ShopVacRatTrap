// Prototype for a push-fit latching mechanism - V2 (Refined)

// --- Parameters ---
$fn = 64; // Set resolution for curves

// Latch arm properties
latch_arm_length = 22;      // Length of the flexible arm
latch_arm_thickness = 3;     // Thickness of the arm for flexibility and strength
latch_width = 18;            // Width of the latch components

// Latch head properties
latch_head_height = 6;       // Height of the catch
latch_head_overhang = 2.5;   // Overhang of the catch to lock it in place
latch_release_angle = 30;    // Angle of the release surface
latch_insertion_angle = 45;  // Angle of the insertion ramp for smooth engagement

// Receptacle properties
receptacle_wall_thickness = 4; // Thickness of the wall where the receptacle is
receptacle_clearance = 0.5;  // Clearance for the latch arm to move freely

// --- Latch Module (to be integrated into the control box) ---
module latch() {
    union() {
        // Base of the latch arm with a fillet for stress relief
        difference() {
            cube([5, latch_width, latch_arm_thickness]);
            translate([5, -1, -1])
            rotate([0, 90, 0])
            cylinder(r=2, h=latch_width+2);
        }

        // The flexible arm
        translate([2, 0, 0])
        cube([latch_arm_length, latch_width, latch_arm_thickness]);

        // The latching head with improved geometry
        translate([latch_arm_length + 2, 0, 0]) {
            difference() {
                // Main body of the head
                cube([latch_head_overhang + 4, latch_width, latch_head_height]);

                // Angled surface for smooth insertion (insertion ramp)
                translate([-1, -1, 0])
                rotate([0, latch_insertion_angle, 0])
                translate([-latch_head_height, 0, 0])
                cube([latch_head_height + 2, latch_width + 2, latch_head_height + 2]);

                // Angled surface for easy release
                translate([latch_head_overhang + 4, -1, latch_head_height])
                rotate([0, -latch_release_angle, 0])
                translate([-latch_head_height, 0, -latch_head_height])
                cube([latch_head_height + 2, latch_width + 2, latch_head_height + 2]);
            }

            // Add a textured grip for release
            translate([latch_head_overhang + 2, 2, latch_head_height])
            rotate([90,0,0])
            linear_extrude(height=1)
            text("|||", size=3, font="Liberation Sans:style=Bold");
        }
    }
}

// --- Receptacle Module (to be integrated into the trap tube) ---
module receptacle() {
    receptacle_opening_width = latch_width + 2 * receptacle_clearance;
    receptacle_opening_height = latch_arm_thickness + 2 * receptacle_clearance;
    catch_lip_height = latch_head_height - latch_arm_thickness;

    difference() {
        // A block representing part of the main tube wall
        cube([receptacle_wall_thickness + 15, receptacle_opening_width + 10, latch_head_height + 15]);

        // The cutout for the latch arm to pass through
        translate([-1, 5, 5])
        cube([receptacle_wall_thickness + 2, receptacle_opening_width, receptacle_opening_height]);

        // The cavity for the latch head
        translate([receptacle_wall_thickness, 5, 5])
        cube([latch_head_overhang + 5, receptacle_opening_width, latch_head_height]);

        // Create the catch lip
        translate([receptacle_wall_thickness, 5, 5 + receptacle_opening_height])
        difference() {
            cube([latch_head_overhang + 2, receptacle_opening_width, catch_lip_height]);
            // Chamfer on the catch for better engagement
            translate([latch_head_overhang+2, 0, 0])
            rotate([0,-45,0])
            translate([-catch_lip_height,0,0])
            cube([catch_lip_height, receptacle_opening_width, catch_lip_height]);
        }
    }
}


// --- Assembly for Visualization ---
// This shows how the two parts will interact.

// Receptacle (on the main tube)
color("royalblue")
receptacle();

// Latch (on the control box), positioned to show engagement
color("tomato")
translate([-latch_arm_length-1, 5 + receptacle_clearance, 5 + receptacle_clearance])
latch();

// A second view showing the unlatched state
color("lightsalmon")
translate([-latch_arm_length - 25, 5 + receptacle_clearance, 5 + receptacle_clearance])
latch();
