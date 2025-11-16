// ShopVac Rat Trap 2025 - Trap Entrance (Refactored)
// Engineer: Gemini
// Date: 2025-11-15
//
// ========== REVISION HIGHLIGHTS ==========
// - REFACTORED: Replaced snap-fit connectors with a robust flanged connection.
// - MODULAR: Utilizes shared modules from `trap_modules.scad`.
// - IMPROVED: Redesigned sensor mounts for APDS9960 & VL53L0X sensors.
// - SIMPLIFIED: Streamlined design for easier printing and assembly.
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
                tube(entrance_length);
            }

            // Flange at the connection end
            translate([0, 0, entrance_length]) {
                flange();
            }

            // Flat base for stability
            translate([0, -tube_outer_diameter/2, 0]) {
                cube([tube_outer_diameter, tube_outer_diameter, flat_base_height]);
            }
        }

        // Cut away top of base to match tube profile
        translate([0,0,-1]) {
            cylinder(d=tube_outer_diameter, h=flat_base_height+2);
        }
    }

    // Sensor mounts (APDS9960 & VL53L0X)
    // Top mount for VL53L0X (distance sensor)
    translate([0, 0, vl53_mount_pos_z]) {
        rotate([90,0,0]) {
            translate([0,0,tube_outer_diameter/2]) {
                 cube([sensor_mount_width, sensor_mount_thickness, sensor_mount_height], center=true);
            }
        }
    }

    // Side mount for APDS9960 (proximity/color sensor)
    translate([0, 0, apds_mount_pos_z]) {
        rotate([0,90,0]) {
             translate([0,0,tube_outer_diameter/2]) {
                cube([sensor_mount_thickness, sensor_mount_width, sensor_mount_height], center=true);
            }
        }
    }
}

// ========== ASSEMBLY CALL ==========
trap_entrance();
