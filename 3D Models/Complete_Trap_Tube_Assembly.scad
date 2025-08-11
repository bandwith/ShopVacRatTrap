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

// Complete trap tube dimensions (optimized for 3D printing)
trap_tube_length = 250;      // mm - total length from entrance to vacuum connection
trap_tube_diameter = 100;    // mm - internal diameter (4" equivalent)
tube_wall_thickness = 6;     // mm - thick walls for gnaw resistance and sensor mounting
entrance_diameter = 85;      // mm - funnel entrance diameter
exit_diameter = 50;          // mm - tapered exit for maximum vacuum efficiency

// Gnaw resistance parameters (critical for outdoor use)
gnaw_guard_thickness = 8;    // mm - extra thick outer shell at vulnerable points
anti_gnaw_texture_depth = 1; // mm - surface texture depth to discourage gnawing
protective_ridge_spacing = 5; // mm - spacing of anti-gnaw ridges
hardened_zone_length = 50;   // mm - length of extra-thick entrance section

// Four-sensor positioning (integrated into tube walls)
apds_detection_position = 75;   // mm - APDS9960 position (primary detection)
pir_detection_position = 100;   // mm - PIR position (secondary confirmation)
tof_detection_position = 125;   // mm - VL53L0X position (tertiary backup)
camera_position = 75;           // mm - OV5640 position (evidence capture)

// Sensor housing parameters (integrated mounting)
sensor_housing_diameter = 32;   // mm - housing for standard sensors
sensor_housing_depth = 18;      // mm - depth for sensor and weatherproofing
camera_housing_diameter = 45;   // mm - larger housing for OV5640 camera
camera_housing_depth = 25;      // mm - depth for camera assembly and lens

// Bait compartment parameters (externally refillable)
bait_compartment_position = 50; // mm - position from entrance
bait_compartment_diameter = 40; // mm - internal diameter
bait_compartment_depth = 60;    // mm - depth into tube wall
bait_access_diameter = 30;      // mm - external access port diameter
bait_cap_thread_pitch = 2;      // mm - thread pitch for secure closure

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

// Hardware variant selection
camera_variant = true;          // Include OV5640 5MP camera
environmental_sensors = true;   // Include BME280 environmental monitoring
bait_compartment_enabled = true; // Include refillable bait system

// ========== MAIN ASSEMBLY MODULE ==========

module complete_trap_tube_assembly() {
    union() {
        // Main trap tube with integrated sensors
        main_trap_tube();

        // Stable base platform for mounting
        base_mounting_platform();

        // External bait compartment with refill access
        if (bait_compartment_enabled) {
            external_bait_compartment();
        }

        // Sensor mounting and protection systems
        integrated_sensor_mounts();

        // Component identification labels throughout
        complete_labeling_system();

        // Cable management integrated into structure
        integrated_cable_management();
    }
}

// ========== MAIN TRAP TUBE STRUCTURE ==========

module main_trap_tube() {
    difference() {
        union() {
            // Main tube body with tapered entrance and exit
            main_tube_body();

            // Reinforced entrance section (gnaw resistance)
            reinforced_entrance_section();

            // Sensor mounting reinforcements
            sensor_mount_reinforcements();
        }

        // Internal cavity with optimized geometry
        internal_cavity_profile();

        // Sensor housing cavities
        all_sensor_cavities();

        // Bait compartment cavity
        if (bait_compartment_enabled) {
            bait_compartment_cavity();
        }

        // STEMMA QT hub cavity
        qwiic_hub_cavity();

        // Cable routing channels
        cable_routing_channels();

        // Vacuum connection
        vacuum_connection_cavity();
    }
}

module main_tube_body() {
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

// ========== INTEGRATED SENSOR SYSTEMS ==========

module all_sensor_cavities() {
    // APDS9960 cavity (TOP of tube)
    translate([0, 0, apds_detection_position]) {
        translate([0, 0, trap_tube_diameter/2 + tube_wall_thickness - sensor_housing_depth]) {
            cylinder(h = sensor_housing_depth + 2, d = sensor_housing_diameter, $fn = 32);
        }
    }

    // PIR cavity (SIDE of tube)
    translate([0, 0, pir_detection_position]) {
        translate([trap_tube_diameter/2 + tube_wall_thickness - sensor_housing_depth, 0, 0]) {
            rotate([0, 90, 0]) {
                cylinder(h = sensor_housing_depth + 2, d = sensor_housing_diameter, $fn = 32);
            }
        }
    }

    // VL53L0X cavity (BOTTOM of tube)
    translate([0, 0, tof_detection_position]) {
        translate([0, 0, -trap_tube_diameter/2 - tube_wall_thickness + sensor_housing_depth]) {
            cylinder(h = sensor_housing_depth + 2, d = sensor_housing_diameter, $fn = 32);
        }
    }

    // OV5640 camera cavity (TOP of tube, offset from APDS9960)
    if (camera_variant) {
        translate([0, 0, camera_position]) {
            translate([25, 0, trap_tube_diameter/2 + tube_wall_thickness - camera_housing_depth]) {
                cylinder(h = camera_housing_depth + 2, d = camera_housing_diameter, $fn = 32);
            }
        }
    }
}

module integrated_sensor_mounts() {
    // APDS9960 mounting ring (TOP)
    translate([0, 0, apds_detection_position]) {
        translate([0, 0, trap_tube_diameter/2 + tube_wall_thickness - 2]) {
            difference() {
                cylinder(h = 6, d = sensor_housing_diameter + 12, $fn = 32);
                cylinder(h = 8, d = sensor_housing_diameter, $fn = 32);
            }
        }
    }

    // PIR mounting ring (SIDE)
    translate([0, 0, pir_detection_position]) {
        translate([trap_tube_diameter/2 + tube_wall_thickness - 2, 0, 0]) {
            rotate([0, 90, 0]) {
                difference() {
                    cylinder(h = 6, d = sensor_housing_diameter + 12, $fn = 32);
                    cylinder(h = 8, d = sensor_housing_diameter, $fn = 32);
                }
            }
        }
    }

    // VL53L0X mounting ring (BOTTOM)
    translate([0, 0, tof_detection_position]) {
        translate([0, 0, -trap_tube_diameter/2 - tube_wall_thickness - 4]) {
            difference() {
                cylinder(h = 6, d = sensor_housing_diameter + 12, $fn = 32);
                cylinder(h = 8, d = sensor_housing_diameter, $fn = 32);
            }
        }
    }

    // OV5640 camera mounting ring (TOP, offset)
    if (camera_variant) {
        translate([0, 0, camera_position]) {
            translate([25, 0, trap_tube_diameter/2 + tube_wall_thickness - 2]) {
                difference() {
                    cylinder(h = 8, d = camera_housing_diameter + 12, $fn = 32);
                    cylinder(h = 10, d = camera_housing_diameter, $fn = 32);
                }
            }
        }
    }
}

// ========== EXTERNAL BAIT COMPARTMENT SYSTEM ==========

module external_bait_compartment() {
    translate([0, 0, bait_compartment_position]) {
        translate([0, trap_tube_diameter/2 + tube_wall_thickness, 0]) {
            difference() {
                union() {
                    // Main bait compartment housing
                    cylinder(h = bait_compartment_depth, d = bait_compartment_diameter + 8, $fn = 32);

                    // External access port
                    translate([0, 0, bait_compartment_depth - 10]) {
                        cylinder(h = 20, d = bait_access_diameter + 4, $fn = 32);
                    }
                }

                // Internal bait cavity
                translate([0, 0, 4]) {
                    cylinder(h = bait_compartment_depth - 4, d = bait_compartment_diameter, $fn = 32);
                }

                // Access port with threads
                translate([0, 0, bait_compartment_depth - 5]) {
                    cylinder(h = 25, d = bait_access_diameter, $fn = 32);
                }

                // Thread pattern for secure cap
                for (thread_turn = [0:bait_cap_thread_pitch:20]) {
                    translate([0, 0, bait_compartment_depth + thread_turn]) {
                        rotate([0, 0, thread_turn * 360 / bait_cap_thread_pitch]) {
                            translate([bait_access_diameter/2 - 1, 0, 0]) {
                                cube([2, 1, 1], center = true);
                            }
                        }
                    }
                }
            }
        }
    }
}

module bait_compartment_cavity() {
    // Internal connection from bait compartment to main tube
    translate([0, 0, bait_compartment_position]) {
        translate([0, trap_tube_diameter/2 - 5, 0]) {
            rotate([90, 0, 0]) {
                cylinder(h = 15, d = 20, $fn = 24);
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
    translate([0, trap_tube_diameter/2 + tube_wall_thickness + 25, bait_compartment_position + 10]) {
        rotate([90, 0, 0]) {
            linear_extrude(height = label_depth) {
                text("BAIT", size = label_font_size, font = label_font, halign = "center");
            }
        }
    }

    translate([0, trap_tube_diameter/2 + tube_wall_thickness + 25, bait_compartment_position - 5]) {
        rotate([90, 0, 0]) {
            linear_extrude(height = label_depth) {
                text("REFILLABLE", size = small_label_size, font = label_font, halign = "center");
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
