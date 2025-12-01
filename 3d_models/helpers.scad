// Helper module for tube generation to fix missing module error
module tube(length, od, wall) {
    difference() {
        cylinder(d=od, h=length);
        translate([0, 0, -1])
            cylinder(d=od - 2*wall, h=length + 2);
    }
}

// Helper module for flange generation to fix missing module error
module flange(d, thick, hole_d, inset) {
    difference() {
        cylinder(d=d, h=thick);
        // Center hole
        translate([0, 0, -1])
            cylinder(d=tube_od, h=thick + 2); // Assuming tube_od is available globally or passed

        // Screw holes
        for (r = [0:90:270]) {
            rotate([0, 0, r])
                translate([d/2 - inset, 0, -1])
                    cylinder(d=hole_d, h=thick + 2);
        }
    }
}
