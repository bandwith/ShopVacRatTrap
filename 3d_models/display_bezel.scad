// ShopVac Rat Trap - OLED Display Bezel
// Adafruit 326 OLED (27×27.5mm PCB, 21.7×10.9mm display area)

$fn = 40;

// Component dimensions (Adafruit 326)
display_area_width = 21.7;
display_area_height = 10.9;
pcb_width = 27;
pcb_height = 27.5;

// Bezel dimensions
bezel_width = 35;
bezel_height = 35;
bezel_thickness = 2.5;
bezel_lip = 1.5;  // Lip to hold display in place

// Mounting
mount_hole_diameter = 2.7;  // M2.5
mount_hole_spacing_x = 24;  // 2 holes, centered

module display_bezel() {
    difference() {
        union() {
            // Front bezel frame
            difference() {
                cube([bezel_width, bezel_height, bezel_thickness], center=true);

                // Display window cutout
                cube([display_area_width + 0.5,
                      display_area_height + 0.5,
                      bezel_thickness + 2], center=true);
            }

            // Rear retention lip (holds PCB)
            translate([0, 0, -bezel_thickness/2 - bezel_lip/2])
                difference() {
                    cube([pcb_width + 3, pcb_height + 3, bezel_lip], center=true);
                    cube([pcb_width, pcb_height, bezel_lip + 2], center=true);
                }
        }

        // Mounting holes for M2.5 screws (2 holes)
        for (x = [-mount_hole_spacing_x/2, mount_hole_spacing_x/2]) {
            translate([x, bezel_height/2 - 5, 0])
                cylinder(d=mount_hole_diameter,
                        h=bezel_thickness + bezel_lip + 2,
                        center=true);
        }

        // Countersink for screw heads
        for (x = [-mount_hole_spacing_x/2, mount_hole_spacing_x/2]) {
            translate([x, bezel_height/2 - 5, bezel_thickness/2 - 1])
                cylinder(d1=mount_hole_diameter,
                        d2=5,
                        h=2);
        }
    }
}

// Assembly call
display_bezel();
