// ShopVac Rat Trap - Trap Entrance
//
// Description:
// Entrance module with integrated sensor mounts and flanged connection.
// =========================================

include <trap_modules.scad>

// ========== CORE PARAMETERS ==========

// [Dimensions]
entrance_length = 80;
flat_base_height = 20;

// [Sensor Mounts]
apds_mount_pos_z = 30;
vl53_mount_pos_z = 60;
sensor_mount_width = 25;
sensor_mount_height = 20;
sensor_mount_thickness = 3;

// ========== MODULES ==========

module trap_entrance() {
    difference() {
        union() {
            // Main tube body
            translate([0,0,entrance_length/2]) {
                tube(entrance_length, tube_outer_diameter, tube_wall_thickness);
            }

            // Flange at the connection end
            translate([0, 0, entrance_length]) {
                flange(flange_diameter, flange_thickness, flange_screw_hole_diameter, flange_screw_hole_inset);
            }

            // Flat base for stability - Centered and aligned
            translate([0, -tube_outer_diameter/2 - flat_base_height/2 + 2, entrance_length/2]) {
                 cube([tube_outer_diameter, flat_base_height, entrance_length], center=true);
            }

            // Sensor mounts (APDS9960 & VL53L0X) - Connected with hull() for printability

            // Top mount for VL53L0X (distance sensor)
            hull() {
                translate([0, 0, vl53_mount_pos_z]) {
                    rotate([90,0,0]) {
                        translate([0,0,tube_outer_diameter/2]) {
                             cube([sensor_mount_width, sensor_mount_thickness, sensor_mount_height], center=true);
                        }
                    }
                }
                // Anchor to tube
                translate([0, 0, vl53_mount_pos_z]) {
                     rotate([90,0,0]) {
                        translate([0,0,tube_outer_diameter/2 - 2]) {
                             cube([sensor_mount_width, 1, sensor_mount_height], center=true);
                        }
                    }
                }
            }

            // Side mount for APDS9960 (proximity/color sensor)
            hull() {
                translate([0, 0, apds_mount_pos_z]) {
                    rotate([0,90,0]) {
                         translate([0,0,tube_outer_diameter/2]) {
                            cube([sensor_mount_thickness, sensor_mount_width, sensor_mount_height], center=true);
                        }
                    }
                }
                // Anchor to tube
                translate([0, 0, apds_mount_pos_z]) {
                    rotate([0,90,0]) {
                         translate([0,0,tube_outer_diameter/2 - 2]) {
                            cube([1, sensor_mount_width, sensor_mount_height], center=true);
                        }
                    }
                }
            }
        }

        // Cut away top of base to match tube profile (and clear the inside)
        translate([0,0,-1]) {
            cylinder(d=tube_outer_diameter - (2*tube_wall_thickness), h=entrance_length+2);
        }

        // Cut away the base material that intersects with the tube interior
        difference() {
             translate([0, -tube_outer_diameter/2 - flat_base_height/2 + 2, entrance_length/2]) {
                 cube([tube_outer_diameter, flat_base_height, entrance_length], center=true);
            }
            // Keep the base only outside the tube
             translate([0,0,-1]) {
                cylinder(d=tube_outer_diameter, h=entrance_length+2);
            }
        }
    }
}

// ========== ASSEMBLY CALL ==========
trap_entrance();
