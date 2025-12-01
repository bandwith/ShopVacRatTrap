// ShopVac Rat Trap - Exit-Mounted Control Box
// Features: Sensor window, vacuum adapter mounting, internal sensor plate

$fn = 60;

// Dimensions
internal_length = 120;
internal_width = 100;
internal_height = 65;
wall_thickness = 4;

// Window Dimensions
window_width = 50;
window_height = 40;
window_pos_x = (internal_length + 2*wall_thickness)/2;
window_pos_z = 25; // Center height

// Mounting
mount_hole_spacing = 80;

module rounded_box(x, y, z, r) {
    translate([r, r, 0])
    minkowski() {
        cube([x - 2*r, y - 2*r, z - 1]);
        cylinder(r=r, h=1);
    }
}

module control_box_exit_mount() {
    difference() {
        // Main Body Shell
        rounded_box(internal_length + 2*wall_thickness,
                   internal_width + 2*wall_thickness,
                   internal_height + wall_thickness,
                   3);

        // Inner Cavity
        translate([wall_thickness, wall_thickness, wall_thickness])
            rounded_box(internal_length, internal_width, internal_height + 10, 1);

        // === SENSOR WINDOW (Rear Face - facing trap) ===
        translate([window_pos_x - window_width/2, -1, window_pos_z]) {
            // Main Cutout
            cube([window_width, wall_thickness + 2, window_height]);

            // Gasket Groove (Recess)
            translate([-3, 1, -3])
                cube([window_width + 6, 2, window_height + 6]);
        }

        // === MOUNTING HOLES (Bottom/Rear) ===
        // To attach to vacuum adapter flange
        translate([window_pos_x - mount_hole_spacing/2, -1, 10])
            rotate([-90, 0, 0])
            cylinder(d=3.5, h=wall_thickness + 5); // M3

        translate([window_pos_x + mount_hole_spacing/2, -1, 10])
            rotate([-90, 0, 0])
            cylinder(d=3.5, h=wall_thickness + 5); // M3

        translate([window_pos_x - mount_hole_spacing/2, -1, internal_height])
            rotate([-90, 0, 0])
            cylinder(d=3.5, h=wall_thickness + 5); // M3

        translate([window_pos_x + mount_hole_spacing/2, -1, internal_height])
            rotate([-90, 0, 0])
            cylinder(d=3.5, h=wall_thickness + 5); // M3

        // === CABLE PORTS ===
        // PG7 / PG9 gland holes
        translate([15, internal_width + 2*wall_thickness + 1, 20])
            rotate([90, 0, 0])
            cylinder(d=12.5, h=wall_thickness + 5); // Power

        translate([internal_length + 2*wall_thickness - 15, internal_width + 2*wall_thickness + 1, 20])
            rotate([90, 0, 0])
            cylinder(d=12.5, h=wall_thickness + 5); // Vacuum Control

        // === DISPLAY CUTOUT (Front Face - Lid) ===
        // Handled in Lid module, but here for reference
    }

    // === INTERNAL MOUNTS ===
    translate([wall_thickness, wall_thickness, wall_thickness]) {
        // Sensor Plate Mounts (Behind Window)
        translate([internal_length/2 - 30, 2, 10]) {
            difference() {
                cube([60, 5, 50]);
                translate([5, -1, 5])
                    cube([50, 7, 40]); // Cutout center
            }
        }

        // ESP32 Feather Mounts
        translate([10, 40, 0]) {
            cylinder(d=6, h=5);
            translate([46, 0, 0]) cylinder(d=6, h=5);
            translate([0, 20, 0]) cylinder(d=6, h=5);
            translate([46, 20, 0]) cylinder(d=6, h=5);
        }

        // SSR Mounts
        translate([80, 40, 0]) {
            cylinder(d=6, h=5);
            translate([48, 0, 0]) cylinder(d=6, h=5);
        }

        // Lid Screw Posts (Corners)
        translate([0, 0, internal_height - 10]) {
             translate([4, 4, 0]) difference() { cylinder(d=8, h=10); cylinder(d=3, h=11); }
             translate([internal_length-4, 4, 0]) difference() { cylinder(d=8, h=10); cylinder(d=3, h=11); }
             translate([4, internal_width-4, 0]) difference() { cylinder(d=8, h=10); cylinder(d=3, h=11); }
             translate([internal_length-4, internal_width-4, 0]) difference() { cylinder(d=8, h=10); cylinder(d=3, h=11); }
        }
    }
}

module sensor_mounting_plate() {
    // Separate printable plate to hold Camera, ToF, IR
    difference() {
        cube([58, 4, 48]);

        // Camera Lens Hole
        translate([29, -1, 35])
            rotate([-90, 0, 0])
            cylinder(d=8, h=6);

        // ToF Sensor Hole
        translate([29, -1, 20])
            rotate([-90, 0, 0])
            cylinder(d=6, h=6);

        // IR Sensor Hole
        translate([29, -1, 10])
            rotate([-90, 0, 0])
            cylinder(d=6, h=6);

        // Mounting Screw Holes
        translate([4, -1, 4]) rotate([-90,0,0]) cylinder(d=3, h=6);
        translate([54, -1, 4]) rotate([-90,0,0]) cylinder(d=3, h=6);
        translate([4, -1, 44]) rotate([-90,0,0]) cylinder(d=3, h=6);
        translate([54, -1, 44]) rotate([-90,0,0]) cylinder(d=3, h=6);
    }
}

// Render
control_box_exit_mount();

translate([0, -20, 0])
    sensor_mounting_plate();
