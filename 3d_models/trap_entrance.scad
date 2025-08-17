// ShopVac Rat Trap 2025 - Trap Entrance
// Engineer: Gemini
// Date: 2025-08-15
//
// ========== REVISION HIGHLIGHTS ==========
// - NEW: Horizontal design that lays flat on the floor.
// - NEW: 4-inch (101.6mm) opening for various rodent sizes.
// - NEW: Integrated sensor mounts for primary detection (APDS9960 & VL53L0X).
// - NEW: Snap-fit connector for easy assembly with the main trap body.
// =========================================

// ========== CORE PARAMETERS ==========

// [Dimensions]
opening_diameter = 101.6; // 4 inches
tube_wall_thickness = 4;
entrance_length = 80;
flat_base_height = 20;

// [Snap-Fit Connector Parameters]
clip_width = 15;
clip_thickness = 3;
clip_length = 20;
clip_hook_depth = 2;

// [Sensor Mount Parameters]
sensor_mount_width = 30;
sensor_mount_height = 20;
sensor_mount_thickness = 3;

$fn = 128;

// ========== MODULES ==========

module snap_fit_clip() {
    // Cantilever snap-fit clip
    difference() {
        cube([clip_thickness, clip_width, clip_length]);
        translate([clip_thickness, 0, clip_length - clip_hook_depth]) {
            cube([clip_thickness, clip_width, clip_hook_depth * 2]);
        }
    }
    translate([-clip_hook_depth, 0, clip_length - clip_hook_depth]) {
        cube([clip_hook_depth, clip_width, clip_hook_depth]);
    }
}

module trap_entrance() {
    difference() {
        union() {
            // Main body
            cylinder(h = entrance_length, d = opening_diameter + (2 * tube_wall_thickness), center = false);

            // Flat base
            translate([- (opening_diameter / 2) - tube_wall_thickness, -opening_diameter / 2, 0]) {
                cube([opening_diameter + (2 * tube_wall_thickness), opening_diameter, flat_base_height]);
            }
        }

        // Hollow out the inside
        translate([0, 0, -1]) {
            cylinder(h = entrance_length + 2, d = opening_diameter, center = false);
        }

        // Cut away the top of the flat base to match the tube
        translate([0, 0, flat_base_height]) {
            cylinder(h = entrance_length, d = opening_diameter + (2 * tube_wall_thickness) + 2, center = false);
        }
    }

    // Add snap-fit clips
    for (a = [90, 270]) {
        rotate([0, 0, a]) {
            translate([opening_diameter / 2 + tube_wall_thickness, -clip_width / 2, 20]) {
                snap_fit_clip();
            }
        }
    }

    // Add sensor mounts
    translate([0, -sensor_mount_width/2, entrance_length - sensor_mount_height - 5]) {
        cube([sensor_mount_thickness, sensor_mount_width, sensor_mount_height]);
    }
    translate([-sensor_mount_width/2, 0, entrance_length - sensor_mount_height - 5]) {
        rotate([0,0,-90]){
            cube([sensor_mount_thickness, sensor_mount_width, sensor_mount_height]);
        }
    }
}

// ========== ASSEMBLY CALL ==========
trap_entrance();
