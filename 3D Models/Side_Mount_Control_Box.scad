// ShopVac Rat Trap 2025 - Side-Mount Control Electronics Enclosure
// SIDE-MOUNT DESIGN: Mounts to side of Complete_Trap_Tube_Assembly for easy access
// BOM-Compatible Design: ESP32-S3 Feather + STEMMA QT sensors + chassis mount PSU
// SNAP-FIT ASSEMBLY: No screws, bolts, or mechanical fasteners needed
// NEC/IEC compliant: Proper thermal management and safety features
// UV-RESISTANT DESIGN: For long-term outdoor field deployment
// Author: Hardware Designer
// Date: August 2025
// Updated: Optimized for STEMMA QT hybrid detection system
// Features: Universal mounting brackets, tool-free assembly, snap-fit lid, easy service access
// Print Settings: Use PETG Carbon Fiber or ASA for UV resistance, 0.20mm layers, 25% infill
//
// ARCHITECTURE UPDATE - August 2025:
// - Detection sensors (APDS9960, VL53L0X, PIR, BME280) relocated to INLET assembly
// - Single 500mm STEMMA QT cable connects inlet sensors to ESP32-S3 in control box
// - Only OLED display remains in control box for user interface
// - Simplified wiring: ESP32-S3 → STEMMA QT hub at inlet → all detection sensors
// - Camera variant: Additional OV5640 5MP camera and IR LED at inlet location

// [Enclosure Dimensions]
box_width = 200;        // [mm] Sized for Mean Well LRS-35-5 + ESP32-S3 Feather
box_depth = 150;        // [mm] Adequate depth for all components
box_height = 80;        // [mm] Increased for proper component clearance
wall_thickness = 4;     // [mm] Increased for UV resistance and durability
corner_radius = 8;      // [mm] Larger radius for stress distribution

// [Mounting Parameters]
trap_tube_diameter = 114.3;    // [mm] Matches Complete_Trap_Tube_Assembly outer diameter
mount_radius = trap_tube_diameter / 2;  // Radius for curved mounting surface
tube_contact_width = 100;      // [mm] Width of tube contact area
tube_mount_height = 30;        // [mm] Height of curved mounting section

// [Push-fit Latching]
latch_arm_length = 22;      // [mm] Length of the flexible arm
latch_arm_thickness = 3;     // [mm] Thickness of the arm for flexibility and strength
latch_width = 18;            // [mm] Width of the latch components
latch_head_height = 6;       // [mm] Height of the catch
latch_head_overhang = 2.5;   // [mm] Overhang of the catch to lock it in place
latch_release_angle = 30;    // [deg] Angle of the release surface
latch_insertion_angle = 45;  // [deg] Angle of the insertion ramp for smooth engagement

// [Lid Snap-Fit]
snap_arm_length = 8;        // [mm] Length of snap arm
snap_arm_thickness = 1.5;   // [mm] Thickness for flexibility
snap_catch_height = 2;      // [mm] Height of catch feature
snap_tolerance = 0.2;       // [mm] Clearance for smooth operation
lid_overlap = 3;            // [mm] How much lid overlaps base

// ========== PARAMETER VALIDATION ==========
assert(box_width > 0, "Box width must be positive.");
assert(box_depth > 0, "Box depth must be positive.");
assert(box_height > 0, "Box height must be positive.");
assert(wall_thickness > 0, "Wall thickness must be positive.");
assert(latch_arm_thickness > 0, "Latch arm thickness must be positive.");
assert(snap_arm_thickness > 0, "Snap arm thickness must be positive.");
tube_contact_width = 100;      // mm - width of tube contact area
tube_mount_height = 30;        // mm - height of curved mounting section
flat_base_width = 80;          // mm - width of flat base for table mounting

// Push-fit latching parameters for tube mounting
latch_arm_length = 22;      // Length of the flexible arm
latch_arm_thickness = 3;     // Thickness of the arm for flexibility and strength
latch_width = 18;            // Width of the latch components
latch_head_height = 6;       // Height of the catch
latch_head_overhang = 2.5;   // Overhang of the catch to lock it in place
latch_release_angle = 30;    // Angle of the release surface
latch_insertion_angle = 45;  // Angle of the insertion ramp for smooth engagement

// Snap-fit parameters for tool-free assembly
snap_arm_length = 8;        // mm - length of snap arm
snap_arm_thickness = 1.5;   // mm - thickness for flexibility
snap_catch_height = 2;      // mm - height of catch feature
snap_tolerance = 0.2;       // mm - clearance for smooth operation
lid_overlap = 3;            // mm - how much lid overlaps base

// Component mounting parameters - exact BOM component specifications
// ESP32-S3 Feather (Adafruit 5323) - PRIMARY CONTROLLER (remains in control box)
esp32_s3_width = 51;    // ESP32-S3 Feather dimensions
esp32_s3_length = 23;
esp32_s3_hole_spacing_x = 45.7;
esp32_s3_hole_spacing_y = 17.8;

// OLED Display (Adafruit 326) - USER INTERFACE (remains in control box)
// All detection sensors moved to inlet assembly via STEMMA QT
oled_width = 27;        // SSD1306 OLED STEMMA QT dimensions (Adafruit 326)
oled_height = 27;
oled_thickness = 4;

// INLET SENSOR ASSEMBLY (connected via single 500mm STEMMA QT cable):
// - APDS9960 Proximity/Gesture Sensor (Adafruit 3595) - Primary detection
// - VL53L0X ToF Distance Sensor (Adafruit 3317) - Secondary confirmation
// - PIR Motion Sensor (Adafruit 4871) - Tertiary backup detection
// - BME280 Environmental Sensor (Adafruit 4816) - Environmental monitoring
// - STEMMA QT 5-Port Hub (Adafruit 5625) - Central sensor connection hub

// Camera variant additional components (when camera_variant = true):
// - OV5640 5MP Camera (Adafruit 5945) - Evidence capture
// - High-Power IR LED (Adafruit 5639) - Night vision illumination

// Camera variant parameters (when using camera configuration)
camera_variant = false;     // Set to true for camera configuration
ov5640_width = 32;          // OV5640 5MP camera board (Adafruit 5945)
ov5640_length = 32;
ov5640_thickness = 8;       // Includes lens assembly

// Label parameters for component identification
label_depth = 0.8;          // mm - depth of embossed text
label_font_size = 5;        // mm - larger font size for control box labels
label_font = "Liberation Sans:style=Bold"; // Font for clear visibility
small_label_size = 3;       // mm - smaller font for detailed labels

// Mean Well LRS-35-5 power supply dimensions (BOM PS1)
power_supply_width = 54;  // LRS-35-5 chassis mount exact dimensions
power_supply_length = 27;
power_supply_height = 23;

// SparkFun SSR-40A chassis mount dimensions (BOM K1)
ssr_width = 58;         // SparkFun COM-13015 SSR dimensions
ssr_length = 45;
ssr_height = 32;

// Front panel components - exact BOM specifications
arcade_button_diameter = 60;  // Adafruit 368 Large Arcade Button diameter
display_width = 27;     // Adafruit 326 OLED display
display_height = 27;

// Rear panel components - exact BOM specifications
iec_inlet_width = 20;   // Schurter 4300.0030 IEC C14 inlet dimensions
iec_inlet_height = 13;
nema_outlet_width = 15; // Leviton 5320-W NEMA 5-15R outlet dimensions
nema_outlet_height = 20;

// Front panel component positions - BOM component layout
display_x = 40;
display_y = 40;

arcade_button_x = 120;       // Adafruit 368 Large Arcade Button position
arcade_button_y = 40;

emergency_switch_x = 160;    // Safety critical per NEC 422.31(B) / IEC 60204-1
emergency_switch_y = 40;

// Module to create embossed component labels for control box
module component_label(text, size=label_font_size) {
    linear_extrude(height=label_depth, center=false)
    text(text, size=size, font=label_font,
         halign="center", valign="center");
}

// --- Push-Fit Latch Module (for mounting to trap tube) ---
module push_fit_latch() {
    union() {
        // Base of the latch arm with a fillet for stress relief
        difference() {
            cube([5, latch_width, latch_arm_thickness]);
            translate([5, -1, -1])
            rotate([0, 90, 0])
            cylinder(r=2, h=latch_width+2, $fn=32);
        }

        // The flexible arm
        translate([2, 0, 0])
        cube([latch_arm_length, latch_width, latch_arm_thickness]);

        // The latching head with improved geometry
        translate([latch_arm_length + 2, 0, 0]) {
            difference() {
                // Main body of the head
                cube([latch_head_overhang + 4, latch_width, latch_head_height]);

                // Angled surface for smooth insertion (insertion ramp)
                translate([-1, -1, 0])
                rotate([0, latch_insertion_angle, 0])
                translate([-latch_head_height, 0, 0])
                cube([latch_head_height + 2, latch_width + 2, latch_head_height + 2]);

                // Angled surface for easy release
                translate([latch_head_overhang + 4, -1, latch_head_height])
                rotate([0, -latch_release_angle, 0])
                translate([-latch_head_height, 0, -latch_head_height])
                cube([latch_head_height + 2, latch_width + 2, latch_head_height + 2]);
            }

            // Add a textured grip for release
            translate([latch_head_overhang + 2, 2, latch_head_height])
            rotate([90,0,0])
            linear_extrude(height=1)
            text("|||", size=3, font="Liberation Sans:style=Bold");
        }
    }
}

// Mounting base with integrated push-fit latches
module push_fit_mounting_base() {
    difference() {
        // Main mounting body with curved surface
        union() {
            translate([box_width/2, 0, 0])
            intersection() {
                cylinder(r=mount_radius + wall_thickness, h=tube_mount_height, $fn=64);
                translate([-tube_contact_width/2, -mount_radius - wall_thickness, 0])
                cube([tube_contact_width, mount_radius + wall_thickness, tube_mount_height]);
            }
        }

        // Hollow out the trap tube mounting cavity
        translate([box_width/2, 0, wall_thickness])
        intersection() {
            cylinder(r=mount_radius, h=tube_mount_height, $fn=64);
            translate([-tube_contact_width/2, -mount_radius, 0])
            cube([tube_contact_width, mount_radius, tube_mount_height]);
        }
    }

    // Add push-fit latches to the mounting base
    // Position two latches for secure mounting
    translate([box_width/2 - latch_width/2, -mount_radius - wall_thickness - latch_arm_length - 5, tube_mount_height/2 - latch_arm_thickness/2])
    rotate([0, 0, 180])
    rotate([0, -90, 0])
    push_fit_latch();

    translate([box_width/2 - latch_width/2, mount_radius + wall_thickness + 5, tube_mount_height/2 - latch_arm_thickness/2])
    rotate([0, 90, 0])
    push_fit_latch();
}

// Main enclosure module
module control_box_enclosure() {
    union() {
        // Curved pipe mounting base with push-fit latches
        push_fit_mounting_base();

        // Main enclosure box
        translate([0, 0, tube_mount_height]) {
            difference() {
                // Main box body with rounded corners
                translate([corner_radius, corner_radius, 0])
                hull() {
                    cylinder(r=corner_radius, h=box_height);
                    translate([box_width-2*corner_radius, 0, 0])
                        cylinder(r=corner_radius, h=box_height);
                    translate([0, box_depth-2*corner_radius, 0])
                        cylinder(r=corner_radius, h=box_height);
                    translate([box_width-2*corner_radius, box_depth-2*corner_radius, 0])
                        cylinder(r=corner_radius, h=box_height);
                }

                // Interior cavity
                translate([wall_thickness, wall_thickness, wall_thickness])
                cube([box_width-2*wall_thickness,
                      box_depth-2*wall_thickness,
                      box_height-wall_thickness+1]);

                // Front panel cutouts
                front_panel_cutouts();

                // Rear panel cutouts - BOM-compatible components
                bom_rear_panel_cutouts();

                // Ventilation slots
                ventilation_slots();

                // Snap-fit lid interface (replaces screw mounting holes)
                snap_fit_recesses();
            }

            // Internal mounting posts and supports
            internal_supports();

            // Snap-fit catches for lid retention
            snap_fit_catches();
        }
    }

    // Component identification labels on enclosure
    control_box_labels();
}

// Front panel cutouts - USER INTERFACE COMPONENTS (mounted in control box)
module front_panel_cutouts() {
    // OLED display cutout (Adafruit 326) - Status display and system information
    translate([display_x-oled_width/2, -1, display_y-oled_height/2])
    cube([oled_width, wall_thickness+2, oled_height]);

    // Large arcade button hole (Adafruit 368 - 60mm diameter) - Manual trigger/reset
    translate([arcade_button_x, -1, arcade_button_y])
    cylinder(d=arcade_button_diameter, h=wall_thickness+2);

    // Emergency disable switch hole (6mm) - NEC 422.31(B) / IEC 60204-1 compliant
    translate([emergency_switch_x, -1, emergency_switch_y])
    cylinder(d=6.5, h=wall_thickness+2);

    // NOTE: Detection sensors relocated to inlet assembly in 2025 update:
    // - APDS9960, VL53L0X, PIR, BME280 sensors mounted at inlet location
    // - Single 500mm STEMMA QT cable connects inlet hub to ESP32-S3 in control box
    // - Simplified control box contains only user interface elements
    // - Camera variant adds OV5640 camera and IR LED at inlet (not control box)
}

// Component identification labels for control box
module control_box_labels() {
    // Front panel component labels
    translate([display_x, wall_thickness + label_depth, display_y - 15])
    rotate([90, 0, 0])
    component_label("OLED", small_label_size);

    translate([arcade_button_x, wall_thickness + label_depth, arcade_button_y - 20])
    rotate([90, 0, 0])
    component_label("TRIGGER", small_label_size);

    translate([emergency_switch_x, wall_thickness + label_depth, emergency_switch_y - 15])
    rotate([90, 0, 0])
    component_label("EMERGENCY", small_label_size);

    // Main identification label on front panel
    translate([box_width/2, wall_thickness + label_depth, box_height - 15])
    rotate([90, 0, 0])
    component_label("RAT TRAP 2025");

    // Hybrid detection system identifier
    translate([box_width/2, wall_thickness + label_depth, box_height - 25])
    rotate([90, 0, 0])
    component_label("HYBRID DETECTION", small_label_size);

    // Side panel labels for internal components
    translate([wall_thickness + label_depth, box_depth/6, box_height/2])
    rotate([0, 0, 90])
    rotate([90, 0, 0])
    component_label("ESP32-S3", small_label_size);

    translate([wall_thickness + label_depth, 2*box_depth/6, box_height/2])
    rotate([0, 0, 90])
    rotate([90, 0, 0])
    component_label("POWER", small_label_size);

    translate([wall_thickness + label_depth, 3*box_depth/6, box_height/2])
    rotate([0, 0, 90])
    rotate([90, 0, 0])
    component_label("SSR", small_label_size);

    // Rear panel power connection label
    translate([50, box_depth - wall_thickness - label_depth, 35])
    rotate([90, 0, 0])
    component_label("120V AC", small_label_size);

    // STEMMA QT cable entry label (single cable to inlet sensors)
    translate([150, box_depth - wall_thickness - label_depth, 40])
    rotate([90, 0, 0])
    component_label("INLET SENSORS", small_label_size);

    translate([150, box_depth - wall_thickness - label_depth, 25])
    rotate([90, 0, 0])
    component_label("STEMMA QT", small_label_size);
}

// OPTION A: Integrated IEC inlet with fuse and switch (RECOMMENDED)
module integrated_iec_cutout() {
    // Single cutout for IEC inlet with integrated fuse holder and switch
    // Schurter 6200.4210 or equivalent
    translate([25, box_depth-wall_thickness-1, 20])
    cube([48, wall_thickness+2, 27.8]);  // Standard IEC cutout with fuse/switch integration
}

// BOM-compatible rear panel cutouts
module bom_rear_panel_cutouts() {
    // IEC C14 power inlet (Schurter 4300.0030)
    translate([40, box_depth-wall_thickness-1, 25])
    cube([iec_inlet_width, wall_thickness+2, iec_inlet_height]);

    // NEMA 5-15R outlet (Leviton 5320-W)
    translate([100, box_depth-wall_thickness-1, 20])
    cube([nema_outlet_width, wall_thickness+2, nema_outlet_height]);

    // Cable strain relief holes (for Adafruit silicone wire)
    translate([160, box_depth-wall_thickness-1, 30])
    cylinder(d=8, h=wall_thickness+2);
}

// Ventilation slots for heat dissipation - enhanced for field deployment
module ventilation_slots() {
    for(i = [0:6]) {
        // Side ventilation slots - larger for better airflow
        translate([box_width-wall_thickness-1, 15+i*10, 10])
        cube([wall_thickness+2, 6, 4]);

        translate([box_width-wall_thickness-1, 15+i*10, 25])
        cube([wall_thickness+2, 6, 4]);

        translate([box_width-wall_thickness-1, 15+i*10, 40])
        cube([wall_thickness+2, 6, 4]);

        // Top ventilation slots - increased for heat dissipation
        if(i < 5) {
            translate([25+i*20, 20, box_height-wall_thickness-1])
            cube([12, 4, wall_thickness+2]);

            translate([25+i*20, 60, box_height-wall_thickness-1])
            cube([12, 4, wall_thickness+2]);
        }
    }

    // UV protection drain holes (prevent water accumulation)
    translate([10, box_depth-10, -1])
    cylinder(d=3, h=wall_thickness+2);

    translate([box_width-10, box_depth-10, -1])
    cylinder(d=3, h=wall_thickness+2);
}

// Snap-fit recesses in main enclosure for lid clips
module snap_fit_recesses() {
    // Corner snap recesses (4 corners)
    for(x = [0, 1]) {
        for(y = [0, 1]) {
            translate([x ? box_width-15 : 15,
                      y ? box_depth-15 : 15,
                      box_height-snap_catch_height-1])
            cube([snap_arm_length+snap_tolerance,
                  3+snap_tolerance,
                  snap_catch_height+2]);
        }
    }

    // Side snap recesses (center of each side)
    translate([box_width/2-snap_arm_length/2-snap_tolerance/2, -1, box_height-snap_catch_height-1])
    cube([snap_arm_length+snap_tolerance, 3+snap_tolerance, snap_catch_height+2]);

    translate([box_width/2-snap_arm_length/2-snap_tolerance/2, box_depth-2, box_height-snap_catch_height-1])
    cube([snap_arm_length+snap_tolerance, 3+snap_tolerance, snap_catch_height+2]);
}

// Snap-fit catches on main enclosure for lid clips
module snap_fit_catches() {
    // Corner catches (4 corners)
    for(x = [0, 1]) {
        for(y = [0, 1]) {
            translate([x ? box_width-12 : 12,
                      y ? box_depth-12 : 12,
                      box_height-snap_catch_height])
            snap_catch();
        }
    }

    // Side catches (center of front and back)
    translate([box_width/2, 5, box_height-snap_catch_height])
    snap_catch();

    translate([box_width/2, box_depth-5, box_height-snap_catch_height])
    snap_catch();
}

// Individual snap catch feature
module snap_catch() {
    difference() {
        cube([6, 3, snap_catch_height]);
        translate([3, 1.5, snap_catch_height-0.5])
        rotate([45, 0, 0])
        cube([8, 2, 2], center=true);
    }
}

// Internal mounting posts and component supports - snap-fit assembly
module internal_supports() {
    // ESP32-S3 Feather mounting posts - primary controller
    esp32_x_offset = 20;
    esp32_y_offset = 20;

    // ESP32-S3 Feather mounting posts (Adafruit 5323)
    translate([esp32_x_offset, esp32_y_offset, wall_thickness])
    snap_fit_component_mount(6);  // 6mm height for standard clearance

    translate([esp32_x_offset+esp32_s3_hole_spacing_x, esp32_y_offset, wall_thickness])
    snap_fit_component_mount(6);

    translate([esp32_x_offset, esp32_y_offset+esp32_s3_hole_spacing_y, wall_thickness])
    snap_fit_component_mount(6);

    translate([esp32_x_offset+esp32_s3_hole_spacing_x, esp32_y_offset+esp32_s3_hole_spacing_y, wall_thickness])
    snap_fit_component_mount(6);

    // Mean Well LRS-35-5 power supply snap-fit mounts (BOM PS1)
    translate([100, 20, wall_thickness])
    psu_snap_mount();

    translate([100+power_supply_width, 20, wall_thickness])
    psu_snap_mount();

    translate([100, 20+power_supply_length, wall_thickness])
    psu_snap_mount();

    translate([100+power_supply_width, 20+power_supply_length, wall_thickness])
    psu_snap_mount();

    // SparkFun SSR-40A snap-fit mounts (BOM K1)
    translate([100, 80, wall_thickness])
    ssr_snap_mount();

    translate([100+ssr_width, 80, wall_thickness])
    ssr_snap_mount();

    translate([100, 80+ssr_length, wall_thickness])
    ssr_snap_mount();

    translate([100+ssr_width, 80+ssr_length, wall_thickness])
    ssr_snap_mount();

    // OLED Display mount (remains in control box for user interface)
    translate([display_x, display_y, wall_thickness])
    oled_display_snap_mount();

    // Single cable entry point for inlet sensor connection
    // STEMMA QT cable from ESP32 to inlet sensor hub
    translate([160, 100, wall_thickness])
    cable_entry_mount(); // For 500mm cable to inlet sensors

    // Terminal block snap-fit mount (Adafruit 4090)
    translate([20, 80, wall_thickness])
    terminal_block_snap_mount();
}

// Snap-fit component mount (replaces threaded mounting posts)
module snap_fit_component_mount(height) {
    difference() {
        cylinder(d=10, h=height);
        // Central post for component positioning
        translate([0, 0, -1])
        cylinder(d=3, h=height+2);

        // Snap-fit grooves for component retention
        translate([-1, -5, height-2])
        cube([2, 10, 3]);

        translate([-5, -1, height-2])
        cube([10, 2, 3]);
    }

    // Flexible snap arms
    for(a = [0:90:270]) {
        rotate([0, 0, a])
        translate([4, 0, height-1])
        snap_arm();
    }
}

// PSU snap-fit mount for Mean Well LRS-35-5
module psu_snap_mount() {
    difference() {
        cylinder(d=12, h=8);
        translate([0, 0, -1])
        cylinder(d=4, h=10);

        // Relief cut for PSU edge
        translate([-2, -8, 4])
        cube([4, 16, 5]);
    }

    // Snap clip for PSU retention
    translate([0, 6, 4])
    psu_snap_clip();
}

// SSR snap-fit mount for SparkFun COM-13015
module ssr_snap_mount() {
    difference() {
        cylinder(d=10, h=6);
        translate([0, 0, -1])
        cylinder(d=3.5, h=8);
    }

    // SSR retention clips
    translate([0, 4, 3])
    ssr_snap_clip();
}

// Flexible snap arm for component retention
module snap_arm() {
    hull() {
        cylinder(d=1, h=1);
        translate([snap_arm_length, 0, 0])
        cylinder(d=2, h=0.5);
    }
}

// OLED display snap mount (remains in control box)
module oled_display_snap_mount() {
    difference() {
        cube([oled_width + 6, oled_height + 6, 6], center=true);
        cube([oled_width, oled_height, 5], center=true);

        // STEMMA QT mounting holes
        translate([10, 10, -2]) cylinder(d=2.5, h=8);
        translate([-10, 10, -2]) cylinder(d=2.5, h=8);
        translate([10, -10, -2]) cylinder(d=2.5, h=8);
        translate([-10, -10, -2]) cylinder(d=2.5, h=8);
    }
}

// Terminal block snap-fit mount (Adafruit 4090)
module terminal_block_snap_mount() {
    difference() {
        cube([35, 10, 8]);
        translate([2, 2, 4])
        cube([31, 6, 5]);  // Terminal block recess

        // Wire access slots
        translate([5, -1, 2])
        cube([25, 4, 4]);
    }

    // Snap retention for terminal block
    translate([5, 8, 4])
    cube([25, 2, 2]);
}

// Flexible snap arm for component retention
module snap_arm() {
    hull() {
        cylinder(d=1, h=1);
        translate([snap_arm_length, 0, 0])
        cylinder(d=2, h=0.5);
    }
}

// PSU retention clip
module psu_snap_clip() {
    difference() {
        cube([3, 2, 4]);
        translate([1.5, 0, 2])
        rotate([-45, 0, 0])
        cube([2, 2, 2]);
    }
}

// SSR retention clip
module ssr_snap_clip() {
    difference() {
        cube([2, 3, 3]);
        translate([1, 1.5, 1.5])
        rotate([0, 45, 0])
        cube([2, 4, 2], center=true);
    }
}

// Cable management clip (enhanced for simplified wiring)
module cable_clip() {
    difference() {
        cylinder(d=8, h=6);
        translate([0, 0, 2])
        cylinder(d=6, h=5);
        translate([-3, 0, 2])
        cube([6, 3, 5]);
    }
}

// Thermal management post for single PSU heat dissipation
module thermal_post() {
    difference() {
        cylinder(d=6, h=12);
        translate([0, 0, -1])
        cylinder(d=3.2, h=14);  // M3 mounting hole
    }
}

// Snap-fit lid module (no screws required)
module control_box_lid() {
    difference() {
        // Lid base with snap-fit rim
        union() {
            // Main lid surface
            translate([corner_radius, corner_radius, 0])
            hull() {
                cylinder(r=corner_radius, h=wall_thickness);
                translate([box_width-2*corner_radius, 0, 0])
                    cylinder(r=corner_radius, h=wall_thickness);
                translate([0, box_depth-2*corner_radius, 0])
                    cylinder(r=corner_radius, h=wall_thickness);
                translate([box_width-2*corner_radius, box_depth-2*corner_radius, 0])
                    cylinder(r=corner_radius, h=wall_thickness);
            }

            // Snap-fit rim for enclosure overlap
            translate([lid_overlap, lid_overlap, wall_thickness])
            difference() {
                cube([box_width-2*lid_overlap, box_depth-2*lid_overlap, lid_overlap]);
                translate([wall_thickness, wall_thickness, -1])
                cube([box_width-2*lid_overlap-2*wall_thickness,
                      box_depth-2*lid_overlap-2*wall_thickness,
                      lid_overlap+2]);
            }
        }

        // Component access holes (no mounting holes needed)
        translate([30, 30, -1])
        cylinder(d=12, h=wall_thickness+2);  // ESP32 USB access

        // Additional ventilation
        for(i = [0:3]) {
            for(j = [0:2]) {
                translate([50+i*25, 40+j*20, -1])
                cylinder(d=5, h=wall_thickness+2);
            }
        }
    }

    // Snap-fit arms for lid retention
    snap_fit_lid_arms();

    // Lid identification labels
    control_box_lid_labels();
}

// Snap-fit arms on lid for engaging with enclosure catches
module snap_fit_lid_arms() {
    // Corner snap arms (4 corners)
    for(x = [0, 1]) {
        for(y = [0, 1]) {
            translate([x ? box_width-12 : 12,
                      y ? box_depth-12 : 12,
                      wall_thickness+lid_overlap])
            lid_snap_arm();
        }
    }

    // Side snap arms (center of front and back)
    translate([box_width/2, 5, wall_thickness+lid_overlap])
    lid_snap_arm();

    translate([box_width/2, box_depth-5, wall_thickness+lid_overlap])
    lid_snap_arm();
}

// Individual snap arm on lid
module lid_snap_arm() {
    difference() {
        // Flexible arm
        hull() {
            cube([snap_arm_length, snap_arm_thickness, 2]);
            translate([0, 0, snap_catch_height])
            cube([snap_arm_length-1, snap_arm_thickness, 1]);
        }

        // Relief cut for flexibility
        translate([snap_arm_length-2, snap_arm_thickness/2, 1])
        cylinder(d=1, h=snap_catch_height+1);
    }

    // Catch hook
    translate([snap_arm_length-2, 0, snap_catch_height])
    difference() {
        cube([2, snap_arm_thickness+1, 1]);
        translate([1, snap_arm_thickness+0.5, 0.5])
        rotate([0, 45, 0])
        cube([2, 2, 2], center=true);
    }
}

// Lid identification labels
module control_box_lid_labels() {
    // Main product identification
    translate([box_width/2, box_depth/2, wall_thickness + label_depth])
    component_label("SHOPVAC RAT TRAP");

    // Version and date
    translate([box_width/2, box_depth/2 - 15, wall_thickness + label_depth])
    component_label("2025 ESP32-S3", small_label_size);

    // Warning labels
    translate([20, 20, wall_thickness + label_depth])
    component_label("⚠ 120V", small_label_size);

    translate([box_width - 60, 20, wall_thickness + label_depth])
    component_label("STEMMA QT", small_label_size);

    // Installation direction arrow
    translate([box_width/2, 20, wall_thickness + label_depth])
    component_label("↑ THIS SIDE UP", small_label_size);

    // Service access indicators
    translate([20, box_depth - 20, wall_thickness + label_depth])
    component_label("SERVICE", small_label_size);

    translate([box_width - 40, box_depth - 20, wall_thickness + label_depth])
    component_label("SNAP-FIT", small_label_size);
}

// Cable entry mount for inlet sensor connection (single STEMMA QT cable)
module cable_entry_mount() {
    difference() {
        cylinder(d=15, h=8);
        translate([0, 0, -1])
        cylinder(d=8, h=10);  // Cable entry hole for 500mm STEMMA QT cable

        // Strain relief groove
        translate([-2, -10, 4])
        cube([4, 20, 6]);
    }

    // Cable retention clip
    translate([0, 8, 4])
    rotate([90, 0, 0])
    cube([8, 3, 2], center=true);
}

// Print layout and module selection
// Set which_part to generate specific components:
// "enclosure" - Main control box enclosure
// "lid" - Snap-fit lid (print separately)
// "all" - Assembly preview with both parts
// "separate" - Both parts positioned for printing

which_part = "enclosure"; // [enclosure, lid, all, separate]

// Validate parameter
assert(which_part == "enclosure" || which_part == "lid" || which_part == "all" || which_part == "separate",
       "Invalid which_part value. Use: enclosure, lid, all, or separate");

if (which_part == "enclosure") {
    control_box_enclosure();
} else if (which_part == "lid") {
    control_box_lid();
} else if (which_part == "all") {
    // Assembly preview with BOM-compatible design
    color("lightblue") control_box_enclosure();
    color("darkblue", 0.7) translate([0, 0, box_height]) control_box_lid();
} else if (which_part == "separate") {
    // Both parts positioned for printing
    control_box_enclosure();
    translate([0, box_depth + 20, 0]) control_box_lid();
}
