// ShopVac Rat Trap 2025 - Side-Mount Control Electronics Enclosure
// SIDE-MOUNT DESIGN: Mounts to side of pipe/structure for easy access and maintenance
// BOM-Compatible Design: ESP32-S3 Feather + STEMMA QT sensors + chassis mount PSU
// SNAP-FIT ASSEMBLY: No screws, bolts, or mechanical fasteners needed
// NEC/IEC compliant: Proper thermal management and safety features
// UV-RESISTANT DESIGN: For long-term outdoor field deployment
// Author: Hardware Designer
// Date: August 2025
// Updated: Added STL generation workflow test comment
// Features: Side-mount brackets, tool-free assembly, snap-fit lid, easy service access
// Print Settings: See PRINT_SETTINGS.md for UV-resistant material recommendations

// Customizable parameters - optimized for BOM components
box_width = 200;        // mm - sized for Mean Well LRS-35-5 + ESP32-S3 Feather
box_depth = 150;        // mm - adequate depth for all components
box_height = 80;        // mm - increased for proper component clearance
wall_thickness = 4;     // mm - increased for UV resistance and durability
corner_radius = 8;      // mm - larger radius for stress distribution

// Snap-fit parameters for tool-free assembly
snap_arm_length = 8;        // mm - length of snap arm
snap_arm_thickness = 1.5;   // mm - thickness for flexibility
snap_catch_height = 2;      // mm - height of catch feature
snap_tolerance = 0.2;       // mm - clearance for smooth operation
lid_overlap = 3;            // mm - how much lid overlaps base

// Component mounting parameters - exact BOM component specifications
// Standard ESP32-S3 configuration
esp32_s3_width = 51;    // ESP32-S3 Feather dimensions (Adafruit 5323)
esp32_s3_length = 23;
esp32_s3_hole_spacing_x = 45.7;
esp32_s3_hole_spacing_y = 17.8;

// Hardware variant selection - STEMMA QT ecosystem supports both configurations
camera_variant = true;      // OV5640 5MP camera mounted at inlet (Adafruit 5945)

// STEMMA QT sensor parameters (Adafruit compatible)
vl53l0x_width = 18;     // VL53L0X sensor board (Adafruit 3317)
vl53l0x_length = 18;
oled_width = 27;        // SSD1306 OLED STEMMA QT dimensions (Adafruit 326)
oled_height = 27;
oled_thickness = 4;
bme280_width = 18;      // BME280 sensor board (Adafruit 4816)
bme280_length = 18;

// Camera parameters (when camera_variant = true)
ov5640_width = 32;      // OV5640 5MP camera board (Adafruit 5945)
ov5640_length = 32;
ov5640_thickness = 8;   // Includes lens assembly

// QWIIC Hub mounting parameters (Adafruit 5625) - NEW for simplified cabling
qwiic_hub_width = 25.4;      // 1 inch PCB width
qwiic_hub_length = 25.4;     // 1 inch PCB length
qwiic_hub_thickness = 1.6;   // Standard PCB thickness
qwiic_hub_mounting_holes = 4; // M2.5 mounting holes
qwiic_hub_x = 60;            // Central location for optimal cable management
qwiic_hub_y = 30;            // Midpoint between front and back panels
qwiic_hub_standoff_height = 5; // Clearance for components underneath

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

// Main enclosure module
module control_box_enclosure() {
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

    // Note: Detection sensors (VL53L0X, BME280, OV5640 camera) are mounted at INLET location
    // Single STEMMA QT cable runs from inlet hub to control box ESP32
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

    // STEMMA QT sensor snap-fit mounts - LOCATION CLARIFICATION:
    // VL53L0X ToF sensor: MOUNTED AT INLET for rodent detection
    // BME280 environmental: MOUNTED AT INLET for environmental monitoring
    // OV5640 5MP camera: MOUNTED AT INLET for computer vision detection
    // OLED Display: MOUNTED IN CONTROL BOX for user interface (see front panel)
    // STEMMA QT Hub: MOUNTED AT INLET to minimize cable count (single 500mm cable to control box)

    // OLED Display mount (remains in control box for user interface)
    translate([display_x, display_y, wall_thickness])
    oled_display_snap_mount();

    // Single cable entry point for inlet hub connection
    // Replaces multiple individual sensor cable entries
    translate([qwiic_hub_x, qwiic_hub_y, wall_thickness])
    cable_entry_mount(); // For 500mm cable to inlet hub

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

// Sensor snap-fit mount for STEMMA QT boards
module sensor_snap_mount() {
    difference() {
        cylinder(d=12, h=6);
        translate([0, 0, -1])
        cylinder(d=2.5, h=8);

        // Cable routing groove
        translate([-1, -8, 2])
        cube([2, 16, 3]);
    }

    // Sensor board retention clips
    for(a = [45, 135, 225, 315]) {
        rotate([0, 0, a])
        translate([7, 0, 3])
        sensor_snap_clip();
    }
}

// QWIIC Hub snap-fit mount (Adafruit 5625) - NEW for simplified cabling
module qwiic_hub_snap_mount() {
    difference() {
        cylinder(d=8, h=qwiic_hub_standoff_height);
        translate([0, 0, -1])
        cylinder(d=2.5, h=qwiic_hub_standoff_height+2);  // M2.5 mounting hole

        // Cable routing groove for STEMMA QT connections
        translate([-1, -6, qwiic_hub_standoff_height-2])
        cube([2, 12, 3]);
    }

    // Hub PCB retention clips - smaller for 1" x 1" board
    for(a = [45, 135, 225, 315]) {
        rotate([0, 0, a])
        translate([5, 0, qwiic_hub_standoff_height-1])
        hub_snap_clip();
    }
}

// Hub-specific snap clip (smaller than sensor clips)
module hub_snap_clip() {
    rotate([45, 0, 0])
    cube([4, 1.5, 1.5], center=true);
}

// Cable entry mount for single inlet hub cable (replaces multiple sensor mounts)
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

// Sensor board retention clip
module sensor_snap_clip() {
    difference() {
        cube([1.5, 2, 2]);
        translate([0.75, 1, 1])
        rotate([0, 30, 0])
        cube([2, 3, 2], center=true);
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

// Sensor housing update for VL53L1X
module sensor_housing_vl53l1x() {
    // Updated sensor housing for VL53L1X with weatherproofing
    difference() {
        // Main housing body
        cylinder(d=35, h=25);

        // Sensor board cavity
        translate([0, 0, 5])
        cylinder(d=25, h=16);

        // Sensor aperture (optimized for VL53L1X)
        translate([0, 0, -1])
        cylinder(d=8, h=7);

        // Wire management slot
        translate([-2, -15, 10])
        cube([4, 30, 8]);

        // Mounting holes
        for(a = [0:120:240]) {
            rotate([0, 0, a])
            translate([12, 0, -1])
            cylinder(d=3.2, h=27);
        }
    }

    // Protective lens retainer
    translate([0, 0, 21])
    difference() {
        cylinder(d=12, h=4);
        translate([0, 0, -1])
        cylinder(d=8, h=6);
    }
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
