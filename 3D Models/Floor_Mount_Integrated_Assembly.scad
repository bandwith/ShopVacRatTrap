// ShopVac Rat Trap 2025 - Floor-Mount Integrated Assembly
// INTEGRATED DESIGN: Combined inlet detection and control electronics in single floor-mount unit
// HORIZONTAL PIPE ORIENTATION: Designed for pipe laying on floor/ground surface
// SENSOR POSITIONING: Sensors mounted above pipe opening (non-interfering placement)
// NO FASTENERS REQUIRED: Complete snap-fit assembly with integrated electronics housing
// NEC/IEC COMPLIANT: Proper thermal management, isolation, and safety features
// Author: Hardware Designer
// Date: August 2025
// Combines: Inlet_Rodent_Detection_Assembly.scad + Side_Mount_Control_Box.scad

// ========== DESIGN PHILOSOPHY ==========
// This integrated design allows the 4" PVC pipe to lay horizontally on the floor
// while maintaining optimal sensor functionality:
// 1. VL53L0X ToF sensor positioned above pipe opening (downward-looking)
// 2. OV5640 camera positioned at 45° angle for optimal coverage
// 3. Electronics housing integrated into base structure
// 4. Single cable entry point from sensors to control electronics
// 5. Stable base design for floor mounting with optional anchoring points

// ========== CORE PARAMETERS ==========

// 4" PVC pipe parameters (standard domestic wastewater)
pvc_outer_diameter = 114.3;  // 4.5" actual OD of 4" PVC pipe
pvc_inner_diameter = 101.6;  // 4" nominal ID
pvc_wall_thickness = 6.35;   // Standard Schedule 40 wall thickness

// Integrated assembly base parameters
base_length = 350;           // mm - overall length to accommodate pipe + electronics
base_width = 200;            // mm - width for stable floor mounting
base_height = 40;            // mm - height of base platform
wall_thickness = 4;          // mm - structural wall thickness

// Pipe saddle parameters (horizontal mounting)
saddle_length = 150;         // mm - length of pipe contact area
saddle_height = 60;          // mm - height above base to center of pipe
pipe_contact_angle = 120;    // degrees - wrap angle around pipe bottom

// Sensor positioning parameters (non-interfering placement)
sensor_tower_height = 80;    // mm - height of sensor mounting tower above base
sensor_overhang = 25;        // mm - distance sensors extend over pipe opening
vl53l0x_height_above_pipe = 40; // mm - optimal detection distance above pipe center

// Electronics housing parameters (integrated into base)
electronics_width = 180;     // mm - internal width for electronics
electronics_depth = 120;     // mm - internal depth for electronics
electronics_height = 70;     // mm - internal height for electronics
housing_wall_thickness = 4;  // mm - electronics housing wall thickness

// Component mounting parameters
esp32_s3_width = 51;         // ESP32-S3 Feather dimensions (Adafruit 5323)
esp32_s3_length = 23;
power_supply_width = 54;     // Mean Well LRS-35-5 dimensions
power_supply_length = 27;
power_supply_height = 23;

// Sensor housing parameters
sensor_housing_diameter = 35; // mm - enlarged for better protection
sensor_housing_depth = 25;   // mm - depth for sensor and connections
camera_housing_diameter = 45; // mm - larger for OV5640 5MP camera
camera_housing_depth = 30;   // mm - depth for camera assembly

// Hardware variant selection
camera_variant = true;       // Include OV5640 5MP camera for enhanced detection
environmental_sensors = true; // Include BME280 environmental monitoring

// Label parameters for component identification
label_depth = 0.8;          // mm - depth of embossed text
label_font_size = 5;        // mm - font size for labels
label_font = "Liberation Sans:style=Bold"; // Font for clear visibility
small_label_size = 3;       // mm - smaller font for detailed labels

// Assembly tolerances
snap_tolerance = 0.2;       // mm - clearance for smooth snap-fit operation
$fn = 48;                  // Resolution optimized for reasonable generation time

// ========== MAIN ASSEMBLY MODULE ==========

module floor_mount_integrated_assembly() {
    union() {
        // Base platform with integrated electronics housing
        integrated_base_platform();

        // Horizontal pipe saddle mount
        horizontal_pipe_saddle();

        // Sensor tower positioned above pipe opening
        sensor_mounting_tower();

        // Cable management and protection
        integrated_cable_management();

        // Floor anchoring points
        floor_anchoring_system();

        // Component identification labels
        integrated_assembly_labels();
    }
}

// ========== BASE PLATFORM WITH INTEGRATED ELECTRONICS ==========

module integrated_base_platform() {
    difference() {
        union() {
            // Main base platform
            cube([base_length, base_width, base_height]);

            // Electronics housing walls (integrated into base)
            translate([base_length - electronics_width - housing_wall_thickness - 20,
                      (base_width - electronics_depth - 2*housing_wall_thickness)/2,
                      base_height]) {
                difference() {
                    // Outer housing walls
                    cube([electronics_width + 2*housing_wall_thickness,
                          electronics_depth + 2*housing_wall_thickness,
                          electronics_height + housing_wall_thickness]);

                    // Internal electronics cavity
                    translate([housing_wall_thickness, housing_wall_thickness, housing_wall_thickness])
                    cube([electronics_width, electronics_depth, electronics_height + 1]);

                    // Front panel cutouts (user interface)
                    electronics_front_panel_cutouts();

                    // Rear panel cutouts (power connections)
                    electronics_rear_panel_cutouts();

                    // Ventilation slots
                    electronics_ventilation();
                }

                // Internal mounting posts for electronics
                internal_electronics_mounts();

                // Snap-fit lid interface
                electronics_housing_lid_interface();
            }
        }

        // Pipe saddle cutout
        translate([50, base_width/2, base_height])
        rotate([0, 90, 0])
        cylinder(d=pvc_outer_diameter + 4, h=saddle_length + 1);

        // Weight reduction cavities (non-critical areas)
        for(x = [20, base_length - 40]) {
            for(y = [20, base_width - 40]) {
                if(x < base_length - electronics_width - 80) { // Avoid electronics area
                    translate([x, y, 5])
                    cylinder(d=30, h=base_height - 10);
                }
            }
        }

        // Drainage holes (prevent water accumulation)
        for(i = [0:4]) {
            translate([30 + i*50, 15, -1])
            cylinder(d=4, h=10);

            translate([30 + i*50, base_width - 15, -1])
            cylinder(d=4, h=10);
        }
    }
}

// ========== HORIZONTAL PIPE SADDLE MOUNT ==========

module horizontal_pipe_saddle() {
    translate([50, base_width/2, base_height]) {
        difference() {
            union() {
                // Main saddle structure
                rotate([0, 90, 0])
                difference() {
                    cylinder(d=pvc_outer_diameter + 2*wall_thickness, h=saddle_length);
                    translate([0, 0, -1])
                    cylinder(d=pvc_outer_diameter, h=saddle_length + 2);

                    // Upper section removal (creates saddle)
                    translate([-pvc_outer_diameter, 0, -1])
                    cube([2*pvc_outer_diameter, pvc_outer_diameter, saddle_length + 2]);
                }

                // Saddle reinforcement ribs
                for(i = [0:4]) {
                    translate([i * saddle_length/4, 0, 0])
                    rotate([0, 90, 0])
                    difference() {
                        cylinder(d=pvc_outer_diameter + 8, h=6);
                        translate([0, 0, -1])
                        cylinder(d=pvc_outer_diameter - 2, h=8);
                        translate([-pvc_outer_diameter, 0, -1])
                        cube([2*pvc_outer_diameter, pvc_outer_diameter, 8]);
                    }
                }

                // Pipe retention clips (snap-fit)
                pipe_retention_clips();
            }
        }

        // Pipe saddle labels
        pipe_saddle_labels();
    }
}

// Pipe retention clips for securing pipe in saddle
module pipe_retention_clips() {
    for(i = [1, 3]) { // Position clips at 1/4 and 3/4 length
        translate([i * saddle_length/4, 0, 0]) {
            // Flexible retention arms
            for(angle = [-45, 45]) {
                rotate([0, 90, 0])
                rotate([0, 0, angle])
                translate([pvc_outer_diameter/2 + 2, 0, 0]) {
                    difference() {
                        cylinder(d=8, h=12);
                        translate([0, 0, 4])
                        cylinder(d=6, h=9);

                        // Snap groove
                        translate([-1, -6, 6])
                        cube([2, 12, 4]);
                    }
                }
            }
        }
    }
}

// ========== SENSOR MOUNTING TOWER ==========

module sensor_mounting_tower() {
    translate([50 + sensor_overhang, base_width/2, base_height]) {
        difference() {
            union() {
                // Main sensor tower structure
                cylinder(d=60, h=sensor_tower_height);

                // Tower base reinforcement
                cylinder(d=80, h=15);

                // Sensor housing mounts
                translate([0, 0, sensor_tower_height - sensor_housing_depth])
                vl53l0x_sensor_housing();

                // Camera housing (when enabled)
                if(camera_variant) {
                    translate([25, 0, sensor_tower_height - camera_housing_depth])
                    rotate([0, 15, 0]) // 15-degree angle for optimal coverage
                    ov5640_camera_housing();
                }

                // Environmental sensor housing (when enabled)
                if(environmental_sensors) {
                    translate([-20, 15, sensor_tower_height - 20])
                    bme280_sensor_housing();
                }
            }

            // Internal cable routing cavity
            translate([0, 0, 10])
            cylinder(d=20, h=sensor_tower_height - 15);

            // Cable entry point at base
            translate([0, -25, 5])
            rotate([90, 0, 0])
            cylinder(d=12, h=10);
        }

        // Sensor tower labels
        sensor_tower_labels();
    }
}

// VL53L0X sensor housing optimized for downward detection
module vl53l0x_sensor_housing() {
    difference() {
        union() {
            // Main sensor housing body
            cylinder(d=sensor_housing_diameter, h=sensor_housing_depth);

            // Mounting flange
            translate([0, 0, -3])
            cylinder(d=sensor_housing_diameter + 10, h=3);

            // Weather protection cap
            translate([0, 0, sensor_housing_depth - 2])
            cylinder(d=sensor_housing_diameter + 4, h=8);
        }

        // VL53L0X sensor board cavity (18x18mm STEMMA QT board)
        translate([0, 0, 5])
        cube([20, 20, sensor_housing_depth - 5], center=true);

        // Sensor aperture - positioned for downward detection into pipe
        translate([0, 0, -1])
        cylinder(d=12, h=sensor_housing_depth + 1);

        // STEMMA QT cable routing
        translate([-2, -sensor_housing_diameter/2 - 1, sensor_housing_depth/2])
        cube([4, sensor_housing_diameter + 2, 8]);

        // Mounting holes (snap-fit)
        for(a = [0:120:240]) {
            rotate([0, 0, a])
            translate([15, 0, -4])
            cylinder(d=3.2, h=8);
        }

        // Weather seal groove
        translate([0, 0, sensor_housing_depth + 2])
        rotate_extrude()
        translate([sensor_housing_diameter/2 + 2, 0, 0])
        circle(d=3);
    }

    // VL53L0X identification label
    translate([0, sensor_housing_diameter/2 + 2, sensor_housing_depth/2])
    rotate([90, 0, 0])
    component_label("VL53L0X", small_label_size);
}

// OV5640 5MP camera housing for enhanced detection
module ov5640_camera_housing() {
    difference() {
        union() {
            // Main camera housing body
            cylinder(d=camera_housing_diameter, h=camera_housing_depth);

            // Mounting flange
            translate([0, 0, -3])
            cylinder(d=camera_housing_diameter + 10, h=3);

            // Weather protection hood
            translate([0, 0, camera_housing_depth - 5])
            difference() {
                cylinder(d=camera_housing_diameter + 8, h=12);
                translate([0, 0, -1])
                cylinder(d=camera_housing_diameter - 4, h=14);
            }
        }

        // OV5640 camera module cavity (32x32mm board)
        translate([0, 0, 8])
        cube([35, 35, camera_housing_depth - 8], center=true);

        // Camera lens aperture
        translate([0, 0, -1])
        cylinder(d=25, h=camera_housing_depth + 1);

        // STEMMA QT cable routing
        translate([-2, -camera_housing_diameter/2 - 1, camera_housing_depth/2])
        cube([4, camera_housing_diameter + 2, 10]);

        // Mounting holes
        for(a = [0:90:270]) {
            rotate([0, 0, a])
            translate([18, 0, -4])
            cylinder(d=3.2, h=8);
        }
    }

    // OV5640 camera identification label
    translate([0, camera_housing_diameter/2 + 3, camera_housing_depth/2])
    rotate([90, 0, 0])
    component_label("OV5640", small_label_size);
}

// BME280 environmental sensor housing
module bme280_sensor_housing() {
    difference() {
        union() {
            // Main sensor housing
            cube([25, 25, 20], center=true);

            // Ventilation ports for accurate readings
            for(angle = [0:90:270]) {
                rotate([0, 0, angle])
                translate([15, 0, 0])
                cylinder(d=6, h=25, center=true);
            }
        }

        // BME280 sensor board cavity
        cube([20, 20, 15], center=true);

        // Cable routing
        translate([0, -15, 0])
        cube([4, 10, 15], center=true);
    }

    // BME280 identification label
    translate([0, 15, 0])
    rotate([90, 0, 0])
    component_label("BME280", small_label_size);
}

// ========== ELECTRONICS HOUSING INTERFACES ==========

// Front panel cutouts for user interface
module electronics_front_panel_cutouts() {
    // OLED display cutout
    translate([40, -1, 45])
    cube([27, housing_wall_thickness + 2, 27]);

    // Arcade button hole
    translate([90, -1, 45])
    cylinder(d=60, h=housing_wall_thickness + 2);

    // Emergency stop switch
    translate([140, -1, 45])
    cylinder(d=6.5, h=housing_wall_thickness + 2);
}

// Rear panel cutouts for power connections
module electronics_rear_panel_cutouts() {
    // IEC C14 power inlet
    translate([40, electronics_depth + 2*housing_wall_thickness - 1, 25])
    cube([20, housing_wall_thickness + 2, 13]);

    // NEMA 5-15R outlet
    translate([100, electronics_depth + 2*housing_wall_thickness - 1, 20])
    cube([15, housing_wall_thickness + 2, 20]);

    // Sensor cable entry
    translate([140, electronics_depth + 2*housing_wall_thickness - 1, 30])
    cylinder(d=12, h=housing_wall_thickness + 2);
}

// Ventilation slots for electronics cooling
module electronics_ventilation() {
    // Side ventilation slots
    for(i = [0:6]) {
        translate([electronics_width + 2*housing_wall_thickness - 1, 15 + i*10, 10])
        cube([housing_wall_thickness + 2, 6, 4]);

        translate([electronics_width + 2*housing_wall_thickness - 1, 15 + i*10, 25])
        cube([housing_wall_thickness + 2, 6, 4]);

        translate([electronics_width + 2*housing_wall_thickness - 1, 15 + i*10, 40])
        cube([housing_wall_thickness + 2, 6, 4]);
    }

    // Top ventilation slots
    for(i = [0:4]) {
        translate([25 + i*20, 20, electronics_height + housing_wall_thickness - 1])
        cube([12, 4, housing_wall_thickness + 2]);

        translate([25 + i*20, 60, electronics_height + housing_wall_thickness - 1])
        cube([12, 4, housing_wall_thickness + 2]);
    }
}

// Internal mounting posts for electronics components
module internal_electronics_mounts() {
    // ESP32-S3 Feather mounting posts
    translate([20, 20, housing_wall_thickness])
    esp32_mount_posts();

    // Power supply mounting posts
    translate([80, 20, housing_wall_thickness])
    power_supply_mount_posts();

    // SSR mounting posts
    translate([80, 80, housing_wall_thickness])
    ssr_mount_posts();

    // OLED display mount
    translate([40, 0, 45])
    oled_display_mount();
}

// ESP32-S3 mounting posts
module esp32_mount_posts() {
    for(x = [0, esp32_s3_width]) {
        for(y = [0, esp32_s3_length]) {
            translate([x, y, 0])
            snap_fit_post(6);
        }
    }
}

// Power supply mounting posts
module power_supply_mount_posts() {
    for(x = [0, power_supply_width]) {
        for(y = [0, power_supply_length]) {
            translate([x, y, 0])
            snap_fit_post(8);
        }
    }
}

// SSR mounting posts
module ssr_mount_posts() {
    for(x = [0, 45]) {
        for(y = [0, 32]) {
            translate([x, y, 0])
            snap_fit_post(6);
        }
    }
}

// OLED display mount
module oled_display_mount() {
    difference() {
        cube([27 + 6, housing_wall_thickness + 6, 27 + 6], center=true);
        cube([27, housing_wall_thickness + 8, 27], center=true);
    }
}

// Generic snap-fit mounting post
module snap_fit_post(height) {
    difference() {
        cylinder(d=8, h=height);
        translate([0, 0, -1])
        cylinder(d=3, h=height + 2);

        // Snap groove
        translate([-1, -5, height - 2])
        cube([2, 10, 3]);
    }
}

// Electronics housing lid interface for snap-fit closure
module electronics_housing_lid_interface() {
    // Snap-fit catches around perimeter
    for(x = [20, electronics_width/2, electronics_width - 20]) {
        for(y = [20, electronics_depth - 20]) {
            translate([x, y, electronics_height + housing_wall_thickness - 2])
            snap_catch();
        }
    }
}

// Individual snap catch
module snap_catch() {
    difference() {
        cube([6, 3, 2]);
        translate([3, 1.5, 1.5])
        rotate([45, 0, 0])
        cube([8, 2, 2], center=true);
    }
}

// ========== CABLE MANAGEMENT SYSTEM ==========

module integrated_cable_management() {
    // Main cable conduit from sensors to electronics
    translate([50 + sensor_overhang, base_width/2, base_height + 5])
    rotate([0, 90, 0])
    difference() {
        cylinder(d=16, h=base_length - electronics_width - 100);
        translate([0, 0, -1])
        cylinder(d=12, h=base_length - electronics_width - 98);
    }

    // Cable entry strain reliefs
    for(i = [0:2]) {
        translate([50 + sensor_overhang + i*50, base_width/2, base_height + 5])
        cable_strain_relief();
    }
}

// Cable strain relief fitting
module cable_strain_relief() {
    difference() {
        sphere(d=12);
        sphere(d=8);
        translate([-10, -10, 0])
        cube([20, 20, 10]);
    }
}

// ========== FLOOR ANCHORING SYSTEM ==========

module floor_anchoring_system() {
    // Corner anchoring points for securing to floor
    for(x = [20, base_length - 20]) {
        for(y = [20, base_width - 20]) {
            translate([x, y, 0]) {
                difference() {
                    cylinder(d=20, h=base_height);
                    translate([0, 0, 5])
                    cylinder(d=8, h=base_height); // For concrete anchor bolts

                    translate([0, 0, -1])
                    cylinder(d=12, h=7); // Countersink for bolt heads
                }
            }
        }
    }

    // Floor anchoring labels
    floor_anchor_labels();
}

// ========== COMPONENT LABELING SYSTEM ==========

// Module to create embossed component labels
module component_label(text, size=label_font_size) {
    translate([0, 0, label_depth])
    linear_extrude(height=label_depth, center=false)
    text(text, size=size, font=label_font,
         halign="center", valign="center");
}

// Integrated assembly identification labels
module integrated_assembly_labels() {
    // Main product identification on base
    translate([base_length/2, base_width/2, base_height + label_depth])
    component_label("SHOPVAC RAT TRAP 2025 INTEGRATED");

    // Installation direction arrows
    translate([30, base_width/2, base_height + label_depth])
    component_label("← PIPE INLET", small_label_size);

    translate([base_length - 30, base_width/2, base_height + label_depth])
    component_label("ELECTRONICS →", small_label_size);

    // Safety warnings
    translate([base_length - 100, 30, base_height + label_depth])
    component_label("⚠ 120V AC", small_label_size);

    translate([base_length - 100, base_width - 30, base_height + label_depth])
    component_label("NEC COMPLIANT", small_label_size);
}

// Pipe saddle identification labels
module pipe_saddle_labels() {
    // Pipe flow direction
    translate([10, 35, 10])
    rotate([0, 0, 90])
    component_label("INLET →", small_label_size);

    translate([saddle_length - 10, 35, 10])
    rotate([0, 0, 90])
    component_label("→ VACUUM", small_label_size);

    // Pipe size identification
    translate([saddle_length/2, 40, 0])
    component_label("4\" PVC", small_label_size);
}

// Sensor tower identification labels
module sensor_tower_labels() {
    // Tower identification
    translate([0, 35, 10])
    rotate([0, 0, 0])
    component_label("SENSORS", small_label_size);

    // Detection direction
    translate([0, -35, 10])
    rotate([0, 0, 180])
    component_label("↓ DETECTION", small_label_size);
}

// Floor anchor identification labels
module floor_anchor_labels() {
    translate([20, 20, base_height + label_depth])
    component_label("ANCHOR", small_label_size);

    translate([base_length - 20, 20, base_height + label_depth])
    component_label("ANCHOR", small_label_size);

    translate([20, base_width - 20, base_height + label_depth])
    component_label("ANCHOR", small_label_size);

    translate([base_length - 20, base_width - 20, base_height + label_depth])
    component_label("ANCHOR", small_label_size);
}

// ========== ELECTRONICS HOUSING LID ==========

module electronics_housing_lid() {
    translate([base_length - electronics_width - housing_wall_thickness - 20,
              (base_width - electronics_depth - 2*housing_wall_thickness)/2,
              base_height + electronics_height + housing_wall_thickness]) {
        difference() {
            // Main lid surface
            cube([electronics_width + 2*housing_wall_thickness,
                  electronics_depth + 2*housing_wall_thickness,
                  housing_wall_thickness]);

            // Component access holes
            translate([30, 30, -1])
            cylinder(d=12, h=housing_wall_thickness + 2); // ESP32 USB access

            // Additional ventilation
            for(i = [0:3]) {
                for(j = [0:2]) {
                    translate([50 + i*25, 40 + j*20, -1])
                    cylinder(d=5, h=housing_wall_thickness + 2);
                }
            }
        }

        // Snap-fit rim for enclosure overlap
        translate([3, 3, -3])
        difference() {
            cube([electronics_width + 2*housing_wall_thickness - 6,
                  electronics_depth + 2*housing_wall_thickness - 6,
                  3]);
            translate([housing_wall_thickness, housing_wall_thickness, -1])
            cube([electronics_width, electronics_depth, 5]);
        }

        // Snap-fit arms for lid retention
        electronics_lid_snap_arms();

        // Lid identification labels
        electronics_lid_labels();
    }
}

// Snap-fit arms on electronics lid
module electronics_lid_snap_arms() {
    for(x = [20, electronics_width/2, electronics_width - 20]) {
        for(y = [20, electronics_depth - 20]) {
            translate([x, y, -3])
            lid_snap_arm();
        }
    }
}

// Individual snap arm on lid
module lid_snap_arm() {
    difference() {
        hull() {
            cube([6, 1.5, 2]);
            translate([0, 0, 3])
            cube([5, 1.5, 1]);
        }

        translate([4, 0.75, 1])
        cylinder(d=1, h=4);
    }

    // Catch hook
    translate([4, 0, 3])
    difference() {
        cube([2, 2.5, 1]);
        translate([1, 2, 0.5])
        rotate([0, 45, 0])
        cube([2, 2, 2], center=true);
    }
}

// Electronics lid identification labels
module electronics_lid_labels() {
    // Main identification
    translate([electronics_width/2, electronics_depth/2, housing_wall_thickness + label_depth])
    component_label("CONTROL ELECTRONICS", small_label_size);

    // Version information
    translate([electronics_width/2, electronics_depth/2 - 15, housing_wall_thickness + label_depth])
    component_label("ESP32-S3 2025", small_label_size);

    // Access indicators
    translate([30, 30, housing_wall_thickness + label_depth])
    component_label("USB", small_label_size);

    // Installation orientation
    translate([electronics_width/2, 15, housing_wall_thickness + label_depth])
    component_label("↑ THIS SIDE UP", small_label_size);
}

// ========== PRINT LAYOUT AND MODULE SELECTION ==========

// Set which_part to generate specific components:
// "assembly" - Complete integrated assembly
// "electronics_lid" - Electronics housing lid (print separately)
// "all" - Assembly preview with lid positioned
// "print_set" - Both parts positioned for printing

which_part = "assembly"; // [assembly, electronics_lid, all, print_set]

// Validate parameter
assert(which_part == "assembly" || which_part == "electronics_lid" ||
       which_part == "all" || which_part == "print_set",
       "Invalid which_part value. Use: assembly, electronics_lid, all, or print_set");

if (which_part == "assembly") {
    floor_mount_integrated_assembly();
} else if (which_part == "electronics_lid") {
    electronics_housing_lid();
} else if (which_part == "all") {
    // Assembly preview with lid
    color("lightblue") floor_mount_integrated_assembly();
    color("darkblue", 0.7) electronics_housing_lid();
} else if (which_part == "print_set") {
    // Both parts positioned for printing
    floor_mount_integrated_assembly();
    translate([0, base_width + 50, 0]) electronics_housing_lid();
}

// ========== DESIGN NOTES ==========
/*
INTEGRATION BENEFITS:
1. Single print eliminates assembly complexity between inlet and control box
2. Horizontal pipe orientation allows natural floor/ground placement
3. Sensors positioned above pipe opening provide optimal detection without interference
4. Integrated cable management eliminates external cable runs
5. Stable base design prevents tipping and provides secure floor mounting

SENSOR POSITIONING STRATEGY:
- VL53L0X: Positioned directly above pipe opening for downward detection
- OV5640: Angled 15° for optimal field of view into pipe entrance
- BME280: Positioned away from pipe for accurate environmental readings
- All sensors elevated above pipe to prevent interference with rodent entry

MANUFACTURING NOTES:
- Print assembly with electronics housing facing up for optimal surface finish
- Electronics lid prints separately for access during assembly
- Support material required for sensor housings and overhangs
- Consider split-line placement to minimize support material

ASSEMBLY SEQUENCE:
1. Print main assembly and electronics lid
2. Install electronics components using snap-fit mounts
3. Route sensor cables through integrated conduits
4. Install sensors in respective housings
5. Connect STEMMA QT chain and test functionality
6. Secure electronics lid with snap-fit closure
7. Position pipe in saddle and secure with retention clips
8. Anchor assembly to floor using corner mounting points

MAINTENANCE ACCESS:
- Electronics accessible via snap-fit lid removal
- Sensors accessible from top for cleaning/replacement
- Pipe removable without disassembling electronics
- Cable routing designed for easy sensor replacement
*/
