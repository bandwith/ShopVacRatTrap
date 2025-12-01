// ShopVac Rat Trap - Control Box Lid (Front Panel)
// Features: OLED cutout, screw mounting

$fn = 60;

// Dimensions (Match control_box_exit_mount.scad)
internal_length = 120;
internal_width = 100;
wall_thickness = 4;
lid_thickness = 4;

// OLED Display Cutout (0.96" I2C OLED)
oled_width = 27;
oled_height = 27; // Including header space
oled_screen_w = 23;
oled_screen_h = 12;

module control_box_lid() {
    difference() {
        // Main Plate
        rounded_box(internal_length + 2*wall_thickness,
                   internal_width + 2*wall_thickness,
                   lid_thickness,
                   3);

        // Mounting Holes (Countersunk M3)
        translate([wall_thickness + 4, wall_thickness + 4, -1]) {
            cylinder(d=3.5, h=lid_thickness + 2);
            translate([0,0,2]) cylinder(d=6.5, h=lid_thickness, $fn=6); // Hex head sink
        }
        translate([internal_length + wall_thickness - 4, wall_thickness + 4, -1]) {
            cylinder(d=3.5, h=lid_thickness + 2);
            translate([0,0,2]) cylinder(d=6.5, h=lid_thickness, $fn=6);
        }
        translate([wall_thickness + 4, internal_width + wall_thickness - 4, -1]) {
            cylinder(d=3.5, h=lid_thickness + 2);
            translate([0,0,2]) cylinder(d=6.5, h=lid_thickness, $fn=6);
        }
        translate([internal_length + wall_thickness - 4, internal_width + wall_thickness - 4, -1]) {
            cylinder(d=3.5, h=lid_thickness + 2);
            translate([0,0,2]) cylinder(d=6.5, h=lid_thickness, $fn=6);
        }

        // OLED Display Cutout (Centered)
        translate([(internal_length + 2*wall_thickness)/2, (internal_width + 2*wall_thickness)/2, -1]) {
            // Screen Window
            cube([oled_screen_w, oled_screen_h, lid_thickness + 2], center=true);

            // Recess for PCB (Rear side)
            translate([0, 0, 2])
                cube([oled_width, oled_height, lid_thickness], center=true);
        }
    }
}

module rounded_box(x, y, z, r) {
    translate([r, r, 0])
    minkowski() {
        cube([x - 2*r, y - 2*r, z - 1]);
        cylinder(r=r, h=1);
    }
}

control_box_lid();
