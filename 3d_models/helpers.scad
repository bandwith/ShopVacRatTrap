// ShopVac Rat Trap - Helper Modules
// Reusable geometry primitives for trap components.
// This file must NOT render any geometry on its own.

// ========== TUBE ==========
// Generates a hollow cylinder (pipe section).
// Parameters:
//   length - axial length of tube
//   od     - outer diameter
//   wall   - wall thickness
module tube(length, od, wall) {
    difference() {
        cylinder(d=od, h=length);
        translate([0, 0, -1])
            cylinder(d=od - 2*wall, h=length + 2);
    }
}

// ========== FLANGE ==========
// Generates a flange ring with a center hole and evenly-spaced bolt holes.
// All dimensions are explicit parameters - no globals referenced.
// Parameters:
//   d            - outer diameter of flange
//   thick        - thickness (height) of flange
//   center_hole_d - diameter of center bore
//   hole_d       - bolt hole diameter
//   inset        - distance from flange edge to bolt hole center
//   hole_count   - number of bolt holes (default 4, evenly spaced)
module flange(d, thick, center_hole_d, hole_d, inset, hole_count=4) {
    angle_step = 360 / hole_count;
    difference() {
        cylinder(d=d, h=thick);

        // Center hole
        translate([0, 0, -1])
            cylinder(d=center_hole_d, h=thick + 2);

        // Bolt holes evenly spaced
        for (i = [0 : hole_count - 1]) {
            rotate([0, 0, i * angle_step])
                translate([d/2 - inset, 0, -1])
                    cylinder(d=hole_d, h=thick + 2);
        }
    }
}

// ========== ROUNDED BOX ==========
// Generates a box with rounded vertical edges (XY plane rounding).
// Uses minkowski sum of a reduced cube and a cylinder.
// Parameters:
//   x - total X dimension
//   y - total Y dimension
//   z - total Z dimension (height)
//   r - corner radius
module rounded_box(x, y, z, r) {
    translate([r, r, 0])
    minkowski() {
        cube([x - 2*r, y - 2*r, z - 1]);
        cylinder(r=r, h=1);
    }
}
