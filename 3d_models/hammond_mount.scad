// ShopVac Rat Trap - Hammond Box Adapter
// Allows mounting a commercial Hammond PN-1334-C box to the trap body
// Uses snap-fits to attach to the trap, and screws to hold the box

$fn = 60;

// Hammond PN-1334-C Mounting Holes (approximate, verify with datasheet)
hole_spacing_x = 180;
hole_spacing_y = 100;

module hammond_mount() {
    difference() {
        // Base Plate
        rounded_plate(200, 120, 5, 5);

        // Mounting Holes for Hammond Box (M4)
        for(x = [-hole_spacing_x/2, hole_spacing_x/2]) {
            for(y = [-hole_spacing_y/2, hole_spacing_y/2]) {
                translate([x, y, -1])
                    cylinder(d=4.5, h=10);
            }
        }

        // Central Cutout for Weight Reduction
        rounded_plate(150, 80, 10, 10);
    }

    // Snap Clips for Trap Body (Bottom side)
    // Matches the trap body's mounting rails
    translate([0, 0, -5]) {
        // ... Snap fit geometry ...
        difference() {
            cube([40, 120, 5], center=true);
            cube([30, 130, 5], center=true); // Slot
        }
    }
}

module rounded_plate(x, y, z, r) {
    minkowski() {
        cube([x-2*r, y-2*r, z/2], center=true);
        cylinder(r=r, h=z/2);
    }
}

hammond_mount();
