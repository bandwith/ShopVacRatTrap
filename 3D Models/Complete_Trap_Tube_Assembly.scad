// ShopVac Rat Trap 2025 - Complete 3D Printed Trap Tube Assembly
// ====================================================================
// REVOLUTIONARY DESIGN: ELIMINATE PVC PIPE ENTIRELY!
// ====================================================================
// DATE: August 2025
// PHILOSOPHY: Complete 3D printed solution with integrated sensors and bait system
// BENEFITS: Perfect sensor integration, gnaw resistance, refillable bait, no pipe joints
// SENSORS: APDS9960 + PIR + VL53L0X + OV5640 integrated into tube walls
// FEATURES: External bait compartment, complete gnaw resistance, embedded labels
// ====================================================================

// ========== DESIGN PHILOSOPHY ==========
// This design eliminates all PVC pipe components and creates a complete
// 3D printed trap tube with the following advantages:
// 1. Perfect sensor integration - sensors designed into walls during printing
// 2. No pipe joints or couplings to fail or leak
// 3. Custom internal geometry optimized for rodent capture
// 4. Uniform gnaw resistance throughout (no weak points)
// 5. Integrated bait compartment with external refill access
// 6. Professional appearance with embedded component labels
// 7. Single print operation vs. multiple assembly steps

// ========== FOUR-SENSOR DETECTION STRATEGY ==========
// Sequential detection as rodent progresses through tube:
// 1. ENTRANCE: Rodent enters through funnel opening (0mm)
// 2. BAIT ZONE: Accessible bait compartment at 50mm to attract rodent deeper
// 3. PRIMARY: APDS9960 proximity sensor at 75mm (tube top wall)
// 4. SECONDARY: PIR motion sensor at 100mm (tube side wall)
// 5. TERTIARY: VL53L0X ToF sensor at 125mm (tube bottom wall)
// 6. EVIDENCE: OV5640 camera at 75mm (tube top wall, offset from APDS9960)
// 7. VACUUM ACTIVATION: 2 of 3 sensors must confirm detection
// 8. EXIT: High-flow vacuum connection at 200mm (tapered for maximum suction)

// ========== CORE PARAMETERS ==========

// [Hardware Variants]
camera_variant = true;          // Include OV5640 5MP camera?
bait_compartment_enabled = true; // Include refillable bait system?

// [Tube Dimensions]
trap_tube_length = 250;      // [mm] Total length from entrance to vacuum connection
trap_tube_diameter = 100;    // [mm] Internal diameter (4" equivalent)
tube_wall_thickness = 6;     // [mm] Thick walls for gnaw resistance and sensor mounting
entrance_diameter = 85;      // [mm] Funnel entrance diameter
exit_diameter = 50;          // [mm] Tapered exit for maximum vacuum efficiency

// [Gnaw Resistance]
gnaw_guard_thickness = 8;    // [mm] Extra thick outer shell at vulnerable points
anti_gnaw_texture_depth = 1; // [mm] Surface texture depth to discourage gnawing
protective_ridge_spacing = 5; // [mm] Spacing of anti-gnaw ridges
hardened_zone_length = 50;   // [mm] Length of extra-thick entrance section

// [Sensor Positioning]
apds_detection_position = 75;   // [mm] APDS9960 position (primary detection)
pir_detection_position = 100;   // [mm] PIR position (secondary confirmation)
tof_detection_position = 125;   // [mm] VL53L0X position (tertiary backup)
camera_position = 75;           // [mm] OV5640 position (evidence capture)

// [Sensor Housing]
sensor_housing_diameter = 32;   // [mm] Housing for standard sensors
sensor_housing_depth = 18;      // [mm] Depth for sensor and weatherproofing
camera_housing_diameter = 45;   // [mm] Larger housing for OV5640 camera
camera_housing_depth = 25;      // [mm] Depth for camera assembly and lens

// [Modular Bait System]
bait_holder_position = 50; // [mm] Z-axis position for the bait holder
rail_width = 30;
rail_thickness = 3;
rail_tongue_thickness = 1.5;
rail_groove_tolerance = 0.4;

// STEMMA QT hub housing (centralized sensor management)
qwiic_hub_position = 30;        // mm - position from entrance
qwiic_hub_width = 26;           // mm - STEMMA QT 5-Port Hub width
qwiic_hub_length = 26;          // mm - STEMMA QT 5-Port Hub length
qwiic_hub_thickness = 2;        // mm - PCB thickness with clearance

// Mounting and connection parameters
base_mount_width = 150;         // mm - stable base platform width
base_mount_depth = 120;         // mm - base platform depth
base_mount_height = 40;         // mm - base platform height
vacuum_connection_diameter = 38; // mm - standard shop vacuum hose connection

// Push-fit latching parameters for control box mounting
// These must match the parameters in Side_Mount_Control_Box.scad
latch_arm_length = 22;
latch_arm_thickness = 3;
latch_width = 18;
latch_head_height = 6;
latch_head_overhang = 2.5;
receptacle_clearance = 0.5;
control_box_mount_position = 150; // Z-axis position for the control box

// Component identification parameters
label_depth = 1.0;              // mm - deeper embossed text for durability
label_font_size = 6;            // mm - larger font for outdoor visibility
label_font = "Liberation Sans:style=Bold"; // Font for clear visibility
small_label_size = 4;           // mm - smaller font for detailed labels

// Assembly and printing parameters
wall_minimum_thickness = 4;     // mm - minimum wall thickness anywhere
snap_tolerance = 0.15;          // mm - tighter tolerance for better weather sealing
print_layer_height = 0.25;      // mm - recommended layer height for strength
$fn = 64;                      // Higher resolution for smooth curves and threads

// ========== PARAMETER VALIDATION ==========
assert(trap_tube_diameter > exit_diameter, "Trap tube diameter must be greater than exit diameter.");
assert(trap_tube_length > apds_detection_position, "APDS9960 sensor must be within the tube length.");
assert(trap_tube_length > pir_detection_position, "PIR sensor must be within the tube length.");
assert(trap_tube_length > tof_detection_position, "ToF sensor must be within the tube length.");
assert(tube_wall_thickness > 0, "Tube wall thickness must be a positive value.");
assert(entrance_diameter < trap_tube_diameter, "Entrance diameter must be smaller than tube diameter.");

// ========== MAIN ASSEMBLY MODULE ==========

include <Modular_Bait_Holder.scad>

module complete_trap_tube_assembly() {
    difference() {
        union() {
            // Main trap tube body
            main_trap_tube_body();

            // Stable base platform for mounting
            base_mounting_platform();

            // Sensor mounting reinforcements
            sensor_mount_reinforcements();

            // Component identification labels
            complete_labeling_system();
        }

        // Subtract all internal cavities
        internal_cavities();
    }
}

// ========== MAIN TRAP TUBE STRUCTURE ==========

module main_trap_tube_body() {
    difference() {
        union() {
            // Main tube body with tapered entrance and exit
            main_tube_body_geometry();

            // Reinforced entrance section (gnaw resistance)
            reinforced_entrance_section();
        }

        // Subtract cavities for the tube itself
        // Add receptacles for the push-fit latches
        push_fit_receptacles();

        // Internal cavity with optimized geometry
        internal_cavity_profile();

        // Cable management integrated into structure
        integrated_cable_management();
    }
}

// This module groups all the negative spaces (cutouts) together.
module internal_cavities() {
    union() {
        // Main tube internal profile
        internal_cavity_profile();

        // Push-fit receptacles for the control box
        push_fit_receptacles();

        // Sensor housing cavities
        apds9960_housing(is_cavity=true);
        pir_housing(is_cavity=true);
        vl53l0x_housing(is_cavity=true);
        if (camera_variant) {
            ov5640_camera_housing(is_cavity=true);
        }

        // Bait compartment cavity
        if (bait_compartment_enabled) {
            modular_bait_holder_slot();
        }

        // STEMMA QT hub cavity
        qwiic_hub_cavity();

        // Cable routing channels
        cable_routing_channels();

        // Vacuum connection
        vacuum_connection_cavity();
    }
}

module main_tube_body_geometry() {
    // Create smooth tapered tube from entrance to exit
    hull() {
        // Entrance end
        translate([0, 0, 0]) {
            cylinder(h = 20, d = entrance_diameter + 2*tube_wall_thickness, $fn = $fn);
        }

        // Main section
        translate([0, 0, 50]) {
            cylinder(h = trap_tube_length - 100,
                    d = trap_tube_diameter + 2*tube_wall_thickness, $fn = $fn);
        }

        // Exit end (tapered for vacuum efficiency)
        translate([0, 0, trap_tube_length - 30]) {
            cylinder(h = 30, d = exit_diameter + 2*tube_wall_thickness, $fn = $fn);
        }
    }
}

module reinforced_entrance_section() {
    // Extra-thick gnaw-resistant entrance
    translate([0, 0, 0]) {
        difference() {
            cylinder(h = hardened_zone_length,
                    d = entrance_diameter + 2*(tube_wall_thickness + gnaw_guard_thickness),
                    $fn = $fn);
            cylinder(h = hardened_zone_length + 2,
                    d = entrance_diameter + 2*tube_wall_thickness, $fn = $fn);
        }
    }

    // Anti-gnaw surface texture
    for (z = [0:protective_ridge_spacing:hardened_zone_length]) {
        translate([0, 0, z]) {
            difference() {
                cylinder(h = 2,
                        d = entrance_diameter + 2*(tube_wall_thickness + gnaw_guard_thickness + anti_gnaw_texture_depth),
                        $fn = $fn);
                cylinder(h = 3,
                        d = entrance_diameter + 2*(tube_wall_thickness + gnaw_guard_thickness),
                        $fn = $fn);
            }
        }
    }
}

module internal_cavity_profile() {
    // Optimized internal geometry for rodent movement and vacuum flow
    hull() {
        // Entrance funnel
        translate([0, 0, -1]) {
            cylinder(h = 30, d = entrance_diameter, $fn = $fn);
        }

        // Main detection zone
        translate([0, 0, 30]) {
            cylinder(h = trap_tube_length - 80, d = trap_tube_diameter, $fn = $fn);
        }

        // Exit taper for maximum vacuum efficiency
        translate([0, 0, trap_tube_length - 50]) {
            cylinder(h = 51, d = exit_diameter, $fn = $fn);
        }
    }
}

// ========== PUSH-FIT RECEPTACLE FOR CONTROL BOX ==========
module push_fit_receptacle() {
    receptacle_opening_width = latch_width + 2 * receptacle_clearance;
    receptacle_opening_height = latch_arm_thickness + 2 * receptacle_clearance;
    catch_lip_height = latch_head_height - latch_arm_thickness;

    difference() {
        // A block representing part of the main tube wall (for subtraction)
        cube([tube_wall_thickness + 15, receptacle_opening_width + 10, latch_head_height + 15]);

        // The cutout for the latch arm to pass through
        translate([-1, 5, 5])
        cube([tube_wall_thickness + 2, receptacle_opening_width, receptacle_opening_height]);

        // The cavity for the latch head
        translate([tube_wall_thickness, 5, 5])
        cube([latch_head_overhang + 5, receptacle_opening_width, latch_head_height]);

        // Create the catch lip
        translate([tube_wall_thickness, 5, 5 + receptacle_opening_height])
        difference() {
            cube([latch_head_overhang + 2, receptacle_opening_width, catch_lip_height]);
            // Chamfer on the catch for better engagement
            translate([latch_head_overhang+2, 0, 0])
            rotate([0,-45,0])
            translate([-catch_lip_height,0,0])
            cube([catch_lip_height, receptacle_opening_width, catch_lip_height]);
        }
    }
}

module push_fit_receptacles() {
    // Position the receptacles to match the latches on the control box
    translate([0, 0, control_box_mount_position]) {
        // Top receptacle
        translate([0, trap_tube_diameter/2, 0])
        rotate([90, 0, 0])
        push_fit_receptacle();

        // Bottom receptacle
        translate([0, -trap_tube_diameter/2, 0])
        rotate([-90, 0, 0])
        push_fit_receptacle();
    }
}


// ========== MODULAR SENSOR & BAIT SYSTEMS ==========

module apds9960_housing(is_cavity=false) {
    translate([0, 0, apds_detection_position]) {
        if (is_cavity) {
            translate([0, 0, trap_tube_diameter/2 + tube_wall_thickness - sensor_housing_depth])
            cylinder(h = sensor_housing_depth + 2, d = sensor_housing_diameter, $fn = 32);
        } else {
            translate([0, 0, trap_tube_diameter/2 + tube_wall_thickness - 2])
            difference() {
                cylinder(h = 6, d = sensor_housing_diameter + 12, $fn = 32);
                cylinder(h = 8, d = sensor_housing_diameter, $fn = 32);
            }
        }
    }
}

module pir_housing(is_cavity=false) {
    translate([0, 0, pir_detection_position]) {
        if (is_cavity) {
            translate([trap_tube_diameter/2 + tube_wall_thickness - sensor_housing_depth, 0, 0])
            rotate([0, 90, 0])
            cylinder(h = sensor_housing_depth + 2, d = sensor_housing_diameter, $fn = 32);
        } else {
            translate([trap_tube_diameter/2 + tube_wall_thickness - 2, 0, 0])
            rotate([0, 90, 0])
            difference() {
                cylinder(h = 6, d = sensor_housing_diameter + 12, $fn = 32);
                cylinder(h = 8, d = sensor_housing_diameter, $fn = 32);
            }
        }
    }
}

module vl53l0x_housing(is_cavity=false) {
    translate([0, 0, tof_detection_position]) {
        if (is_cavity) {
            translate([0, 0, -trap_tube_diameter/2 - tube_wall_thickness + sensor_housing_depth])
            cylinder(h = sensor_housing_depth + 2, d = sensor_housing_diameter, $fn = 32);
        } else {
            translate([0, 0, -trap_tube_diameter/2 - tube_wall_thickness - 4])
            difference() {
                cylinder(h = 6, d = sensor_housing_diameter + 12, $fn = 32);
                cylinder(h = 8, d = sensor_housing_diameter, $fn = 32);
            }
        }
    }
}

module ov5640_camera_housing(is_cavity=false) {
    translate([0, 0, camera_position]) {
        if (is_cavity) {
            translate([25, 0, trap_tube_diameter/2 + tube_wall_thickness - camera_housing_depth])
            cylinder(h = camera_housing_depth + 2, d = camera_housing_diameter, $fn = 32);
        } else {
            translate([25, 0, trap_tube_diameter/2 + tube_wall_thickness - 2])
            difference() {
                cylinder(h = 8, d = camera_housing_diameter + 12, $fn = 32);
                cylinder(h = 10, d = camera_housing_diameter, $fn = 32);
            }
        }
    }
}

module modular_bait_holder_slot() {
    // This module creates the slot (groove) in the main tube for the bait holder to slide into.
    translate([0, 0, bait_holder_position]) {
        rotate(90, [0, 0, 1]) {
            translate([-rail_width/2 - rail_groove_tolerance, trap_tube_diameter/2 - 5, 0]) {
                // Main groove for the rail base
                cube([
                    rail_width + 2 * rail_groove_tolerance,
                    rail_thickness + 5,
                    base_plate_thickness + 2 * rail_groove_tolerance
                ]);
                // Groove for the rail tongue
                translate([0, 0, base_plate_thickness]) {
                    cube([
                        rail_width + 2 * rail_groove_tolerance,
                        rail_thickness + 5,
                        rail_tongue_thickness + rail_groove_tolerance
                    ]);
                }
            }
        }
    }
}

// ========== STEMMA QT HUB HOUSING ==========

module qwiic_hub_cavity() {
    translate([0, 0, qwiic_hub_position]) {
        translate([0, 0, 0]) {
            cube([qwiic_hub_width + 2, qwiic_hub_length + 2, qwiic_hub_thickness + 2], center = true);
        }
    }
}

// ========== BASE MOUNTING PLATFORM ==========

module base_mounting_platform() {
    translate([0, 0, -base_mount_height]) {
        difference() {
            union() {
                // Main base platform
                cube([base_mount_width, base_mount_depth, base_mount_height], center = true);

                // Tube connection reinforcement
                translate([0, 0, base_mount_height/2]) {
                    cylinder(h = 20, d = trap_tube_diameter + 20, $fn = $fn);
                }
            }

            // Drainage holes
            for (x = [-40, 0, 40]) {
                for (y = [-30, 0, 30]) {
                    translate([x, y, -base_mount_height/2 - 1]) {
                        cylinder(h = 10, d = 8, $fn = 16);
                    }
                }
            }

            // Mounting holes for ground anchoring
            for (x = [-base_mount_width/2 + 20, base_mount_width/2 - 20]) {
                for (y = [-base_mount_depth/2 + 20, base_mount_depth/2 - 20]) {
                    translate([x, y, -base_mount_height/2 - 1]) {
                        cylinder(h = base_mount_height + 2, d = 10, $fn = 16);
                    }
                }
            }
        }
    }
}

// ========== VACUUM CONNECTION ==========

module vacuum_connection_cavity() {
    translate([0, 0, trap_tube_length - 20]) {
        cylinder(h = 25, d = vacuum_connection_diameter, $fn = 32);
    }
}

// ========== COMPREHENSIVE LABELING SYSTEM ==========

module complete_labeling_system() {
    // Main system identification
    translate([0, base_mount_depth/2 - 5, -base_mount_height + 2]) {
        rotate([90, 0, 0]) {
            linear_extrude(height = label_depth) {
                text("RAT TRAP 2025", size = label_font_size, font = label_font, halign = "center");
            }
        }
    }

    translate([0, base_mount_depth/2 - 5, -base_mount_height + 10]) {
        rotate([90, 0, 0]) {
            linear_extrude(height = label_depth) {
                text("4-SENSOR INTEGRATED", size = small_label_size, font = label_font, halign = "center");
            }
        }
    }

    // Sensor position labels
    sensor_position_labels();

    // Bait compartment labels
    if (bait_compartment_enabled) {
        bait_compartment_labels();
    }

    // Safety and operational labels
    safety_operational_labels();

    // Directional flow indicators
    flow_direction_indicators();
}

module sensor_position_labels() {
    // APDS9960 label (TOP)
    translate([15, 0, apds_detection_position + trap_tube_diameter/2 + tube_wall_thickness + 8]) {
        rotate([0, 0, 0]) {
            linear_extrude(height = label_depth) {
                text("APDS9960", size = small_label_size, font = label_font, halign = "center");
            }
        }
    }

    translate([12, 0, apds_detection_position + trap_tube_diameter/2 + tube_wall_thickness + 14]) {
        rotate([0, 0, 0]) {
            linear_extrude(height = label_depth) {
                text("PRIMARY", size = small_label_size, font = label_font, halign = "center");
            }
        }
    }

    // PIR label (SIDE)
    translate([trap_tube_diameter/2 + tube_wall_thickness + 8, 15, pir_detection_position]) {
        rotate([0, 0, 90]) {
            rotate([90, 0, 0]) {
                linear_extrude(height = label_depth) {
                    text("PIR", size = small_label_size, font = label_font, halign = "center");
                }
            }
        }
    }

    translate([trap_tube_diameter/2 + tube_wall_thickness + 8, 10, pir_detection_position]) {
        rotate([0, 0, 90]) {
            rotate([90, 0, 0]) {
                linear_extrude(height = label_depth) {
                    text("SECONDARY", size = small_label_size, font = label_font, halign = "center");
                }
            }
        }
    }

    // VL53L0X label (BOTTOM)
    translate([15, 0, tof_detection_position - trap_tube_diameter/2 - tube_wall_thickness - 16]) {
        rotate([0, 0, 0]) {
            linear_extrude(height = label_depth) {
                text("VL53L0X", size = small_label_size, font = label_font, halign = "center");
            }
        }
    }

    translate([12, 0, tof_detection_position - trap_tube_diameter/2 - tube_wall_thickness - 22]) {
        rotate([0, 0, 0]) {
            linear_extrude(height = label_depth) {
                text("TERTIARY", size = small_label_size, font = label_font, halign = "center");
            }
        }
    }

    // OV5640 camera label (TOP, offset)
    if (camera_variant) {
        translate([35, 0, camera_position + trap_tube_diameter/2 + tube_wall_thickness + 12]) {
            rotate([0, 0, 0]) {
                linear_extrude(height = label_depth) {
                    text("OV5640", size = small_label_size, font = label_font, halign = "center");
                }
            }
        }

        translate([32, 0, camera_position + trap_tube_diameter/2 + tube_wall_thickness + 18]) {
            rotate([0, 0, 0]) {
                linear_extrude(height = label_depth) {
                    text("CAMERA", size = small_label_size, font = label_font, halign = "center");
                }
            }
        }
    }
}

module bait_compartment_labels() {
    translate([0, trap_tube_diameter/2 + tube_wall_thickness + 25, bait_holder_position + 10]) {
        rotate([90, 0, 0]) {
            linear_extrude(height = label_depth) {
                text("MODULAR BAIT", size = label_font_size, font = label_font, halign = "center");
            }
        }
    }
}

module safety_operational_labels() {
    // Vacuum connection label
    translate([0, 0, trap_tube_length - 5]) {
        rotate([0, 0, 0]) {
            linear_extrude(height = label_depth) {
                text("VACUUM", size = small_label_size, font = label_font, halign = "center");
            }
        }
    }

    // Entry direction label
    translate([0, 0, 10]) {
        rotate([0, 0, 0]) {
            linear_extrude(height = label_depth) {
                text("ENTRY", size = small_label_size, font = label_font, halign = "center");
            }
        }
    }
}

module flow_direction_indicators() {
    // Arrow indicators showing rodent path
    for (z = [20, 40, 60, 80, 120, 140, 160, 180]) {
        translate([0, trap_tube_diameter/2 + tube_wall_thickness + 2, z]) {
            rotate([90, 0, 0]) {
                linear_extrude(height = label_depth) {
                    polygon(points=[[0,0], [3,2], [3,1], [8,1], [8,-1], [3,-1], [3,-2]]);
                }
            }
        }
    }
}

// ========== CABLE MANAGEMENT ==========

module cable_routing_channels() {
    // Main cable channel from STEMMA QT hub to external connection
    translate([0, 0, qwiic_hub_position]) {
        translate([0, trap_tube_diameter/2, 0]) {
            rotate([90, 0, 0]) {
                cylinder(h = tube_wall_thickness + 10, d = 12, $fn = 16);
            }
        }
    }

    // Individual sensor cable channels
    sensor_cable_channels();
}

module sensor_cable_channels() {
    // APDS9960 cable channel
    translate([0, 0, apds_detection_position]) {
        translate([0, 0, 0]) {
            cube([6, trap_tube_diameter + 20, 6], center = true);
        }
    }

    // PIR cable channel
    translate([0, 0, pir_detection_position]) {
        translate([0, 0, 0]) {
            cube([trap_tube_diameter + 20, 6, 6], center = true);
        }
    }

    // VL53L0X cable channel
    translate([0, 0, tof_detection_position]) {
        translate([0, 0, 0]) {
            cube([6, trap_tube_diameter + 20, 6], center = true);
        }
    }

    // Camera cable channel (when enabled)
    if (camera_variant) {
        translate([0, 0, camera_position]) {
            translate([12, 0, 0]) {
                cube([8, trap_tube_diameter + 20, 8], center = true);
            }
        }
    }
}

module integrated_cable_management() {
    // External cable strain relief
    translate([0, trap_tube_diameter/2 + tube_wall_thickness + 5, qwiic_hub_position]) {
        rotate([90, 0, 0]) {
            difference() {
                cylinder(h = 15, d = 20, $fn = 24);
                cylinder(h = 17, d = 12, $fn = 16);
            }
        }
    }

    // Protective cable conduit
    translate([0, trap_tube_diameter/2 + tube_wall_thickness, qwiic_hub_position]) {
        rotate([90, 0, 0]) {
            difference() {
                cylinder(h = 30, d = 16, $fn = 24);
                cylinder(h = 32, d = 12, $fn = 16);
            }
        }
    }
}

module sensor_mount_reinforcements() {
    // Additional structural reinforcement around sensor mounts
    // APDS9960 reinforcement
    translate([0, 0, apds_detection_position]) {
        translate([0, 0, trap_tube_diameter/2 + tube_wall_thickness]) {
            cylinder(h = 4, d = sensor_housing_diameter + 20, $fn = 32);
        }
    }

    // PIR reinforcement
    translate([0, 0, pir_detection_position]) {
        translate([trap_tube_diameter/2 + tube_wall_thickness, 0, 0]) {
            rotate([0, 90, 0]) {
                cylinder(h = 4, d = sensor_housing_diameter + 20, $fn = 32);
            }
        }
    }

    // VL53L0X reinforcement
    translate([0, 0, tof_detection_position]) {
        translate([0, 0, -trap_tube_diameter/2 - tube_wall_thickness - 4]) {
            cylinder(h = 4, d = sensor_housing_diameter + 20, $fn = 32);
        }
    }
}

// ========== ASSEMBLY CALL ==========

// Generate the complete assembly
complete_trap_tube_assembly();
