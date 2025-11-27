// ShopVac Rat Trap - Modular Entrance
// Features: Ramp, One-way door, Twist-Lock joint

include <trap_modules.scad>

$fn = 100;

module entrance_module() {
    length = 100;
    ramp_angle = 15;

    difference() {
        // Base Module (Male end only, connects to body)
        trap_module_base(length, male_end=true, female_end=false);

        // Cut ramp angle at front
        rotate([0, -ramp_angle, 0])
            translate([-50, -50, -50])
            cube([100, 100, 100]);
    }

    // Ramp Platform
    difference() {
        translate([0, 0, 0])
            rotate([0, -ramp_angle, 0])
            translate([0, 0, -5])
            cylinder(d=tube_od, h=50);

        // Hollow path
        translate([0, 0, -10])
            cylinder(d=tube_id, h=200);

        // Cut off excess
        translate([0, 0, length])
            cube([200, 200, 200], center=true);
    }

    // Door Hinge Mounts
    translate([0, tube_od/2, 20]) {
        difference() {
            cube([40, 10, 10], center=true);
            rotate([0, 90, 0])
                cylinder(d=3, h=50, center=true); // Hinge pin hole
        }
    }
}

module one_way_door() {
    // Simple flap door
    difference() {
        union() {
            cylinder(d=tube_id - 2, h=2);
            translate([0, tube_id/2 - 5, 0])
                cube([10, 10, 2], center=true);

            // Hinge tube
            translate([0, tube_id/2, 0])
                rotate([0, 90, 0])
                cylinder(d=5, h=30, center=true);
        }

        // Hinge pin hole
        translate([0, tube_id/2, 0])
            rotate([0, 90, 0])
            cylinder(d=3.5, h=40, center=true);
    }
}

// Render
entrance_module();
translate([0, 0, 30]) one_way_door();
