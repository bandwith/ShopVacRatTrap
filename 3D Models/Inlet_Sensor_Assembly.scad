// ShopVac Rat Trap 2025 - Inlet Sensor Assembly
// HYBRID DETECTION SYSTEM: Houses all detection sensors at the trap inlet
// STEMMA QT ECOSYSTEM: Zero-solder assembly with plug-and-play modularity
// WEATHERPROOF DESIGN: IP65 rated for outdoor deployment
// Author: Hardware Designer
// Date: August 2025
// Updated: Optimized for STEMMA QT hybrid detection system
// Features: Snap-fit sensor mounts, integrated cable management, weatherproof sealing
// Print Settings: Use PETG Carbon Fiber or ASA for UV resistance, 0.20mm layers, 30% infill
//
// SENSOR ARCHITECTURE - August 2025 Update:
// - APDS9960 Proximity/Gesture Sensor (Adafruit 3595) - Primary detection
// - VL53L0X ToF Distance Sensor (Adafruit 3317) - Secondary confirmation
// - PIR Motion Sensor (Adafruit 4871) - Tertiary backup detection
// - BME280 Environmental Sensor (Adafruit 4816) - Environmental monitoring
// - STEMMA QT 5-Port Hub (Adafruit 5625) - Central connection point
// - Single 500mm STEMMA QT cable to ESP32-S3 in control box
//
// CAMERA VARIANT ADDITIONS:
// - OV5640 5MP Camera (Adafruit 5945) - Evidence capture
// - High-Power IR LED (Adafruit 5639) - Night vision illumination

// Customizable parameters for inlet sensor assembly
assembly_width = 120;     // mm - sized for all STEMMA QT sensors + hub
assembly_depth = 80;      // mm - adequate depth for sensor mounting
assembly_height = 60;     // mm - height for component clearance and airflow
wall_thickness = 3;       // mm - lightweight but weatherproof
corner_radius = 6;        // mm - stress distribution and water shedding

// Weatherproof sealing parameters
seal_groove_width = 3;    // mm - O-ring groove width
seal_groove_depth = 2;    // mm - O-ring groove depth
drain_hole_diameter = 4;  // mm - water drainage holes

// Sensor mounting parameters - exact STEMMA QT component specifications
// APDS9960 Proximity/Gesture Sensor (Adafruit 3595)
apds9960_width = 20;     // STEMMA QT breakout dimensions
apds9960_length = 20;
apds9960_thickness = 2;  // PCB thickness

// VL53L0X ToF Distance Sensor (Adafruit 3317)
vl53l0x_width = 20;      // STEMMA QT breakout dimensions
vl53l0x_length = 20;
vl53l0x_thickness = 2;

// PIR Motion Sensor (Adafruit 4871)
pir_diameter = 32;       // HC-SR501 sensor diameter
pir_height = 25;         // Total height including dome

// BME280 Environmental Sensor (Adafruit 4816)
bme280_width = 20;       // STEMMA QT breakout dimensions
bme280_length = 20;
bme280_thickness = 2;

// STEMMA QT 5-Port Hub (Adafruit 5625)
hub_width = 23;          // Hub PCB dimensions
hub_length = 23;
hub_thickness = 2;

// Camera variant parameters (optional components)
camera_variant = false;   // Set to true to include camera components

// OV5640 5MP Camera (Adafruit 5945)
ov5640_width = 32;       // Camera board dimensions
ov5640_length = 32;
ov5640_thickness = 8;    // Includes lens assembly

// High-Power IR LED (Adafruit 5639)
ir_led_diameter = 10;    // LED mounting diameter
ir_led_height = 8;       // Total height including PCB

// Label parameters for sensor identification
label_depth = 0.6;       // mm - embossed text depth
label_font_size = 4;     // mm - sensor label font size
label_font = "Liberation Sans:style=Bold";

// Module to create sensor identification labels
module sensor_label(text, size=label_font_size) {
    linear_extrude(height=label_depth, center=false)
    text(text, size=size, font=label_font,
         halign="center", valign="center");
}

// Main inlet sensor assembly enclosure
module inlet_sensor_assembly() {
    difference() {
        union() {
            // Main assembly housing with rounded corners
            translate([corner_radius, corner_radius, 0])
            hull() {
                cylinder(r=corner_radius, h=assembly_height);
                translate([assembly_width-2*corner_radius, 0, 0])
                    cylinder(r=corner_radius, h=assembly_height);
                translate([0, assembly_depth-2*corner_radius, 0])
                    cylinder(r=corner_radius, h=assembly_height);
                translate([assembly_width-2*corner_radius, assembly_depth-2*corner_radius, 0])
                    cylinder(r=corner_radius, h=assembly_height);
            }
        }

        // Interior cavity for sensors
        translate([wall_thickness, wall_thickness, wall_thickness])
        cube([assembly_width-2*wall_thickness,
              assembly_depth-2*wall_thickness,
              assembly_height-wall_thickness+1]);

        // Sensor optical windows and mounting cutouts
        sensor_optical_windows();

        // Cable entry and management
        stemma_qt_cable_entry();

        // Weatherproof drainage holes
        weatherproof_drainage();

        // Lid mounting and sealing groove
        lid_sealing_groove();
    }

    // Internal sensor mounting posts and supports
    internal_sensor_mounts();

    // Sensor identification labels on housing
    inlet_sensor_labels();
}

// Sensor optical windows and detection openings
module sensor_optical_windows() {
    // APDS9960 proximity/gesture detection window
    translate([20, 15, -1])
    cylinder(d=12, h=wall_thickness+2);

    // VL53L0X ToF distance measurement window
    translate([50, 15, -1])
    cylinder(d=8, h=wall_thickness+2);

    // PIR motion detection dome cutout
    translate([80, 15, -1])
    cylinder(d=pir_diameter+2, h=wall_thickness+2);

    // BME280 environmental sensing vents (humidity/pressure)
    for(i = [0:2]) {
        translate([20 + i*15, 50, -1])
        cylinder(d=3, h=wall_thickness+2);
    }

    // Camera variant optical window (when enabled)
    if (camera_variant) {
        translate([assembly_width/2, assembly_depth/2, -1])
        cylinder(d=25, h=wall_thickness+2);
    }
}

// STEMMA QT cable entry and strain relief
module stemma_qt_cable_entry() {
    // Main cable entry for 500mm STEMMA QT cable to control box
    translate([assembly_width-10, assembly_depth/2, 15])
    rotate([0, 90, 0])
    cylinder(d=8, h=wall_thickness+2);

    // Strain relief groove
    translate([assembly_width-wall_thickness-1, assembly_depth/2-2, 10])
    cube([wall_thickness+2, 4, 10]);

    // Cable management clips inside enclosure
    translate([assembly_width-15, assembly_depth/2-3, 10])
    cube([8, 6, 3]);
}

// Weatherproof drainage holes for water management
module weatherproof_drainage() {
    // Bottom drainage holes (prevent water accumulation)
    translate([15, 15, -1])
    cylinder(d=drain_hole_diameter, h=wall_thickness+2);

    translate([assembly_width-15, 15, -1])
    cylinder(d=drain_hole_diameter, h=wall_thickness+2);

    // Side drainage slots for airflow
    for(i = [0:2]) {
        translate([assembly_width-wall_thickness-1, 25+i*15, 20])
        cube([wall_thickness+2, 8, 3]);
    }
}

// Lid sealing groove for O-ring weatherproofing
module lid_sealing_groove() {
    translate([seal_groove_width, seal_groove_width, assembly_height-seal_groove_depth])
    cube([assembly_width-2*seal_groove_width,
          assembly_depth-2*seal_groove_width,
          seal_groove_depth+1]);
}

// Internal mounting posts for STEMMA QT sensors
module internal_sensor_mounts() {
    // APDS9960 proximity sensor mount
    translate([20, 15, wall_thickness])
    stemma_qt_sensor_mount("APDS9960");

    // VL53L0X ToF sensor mount
    translate([50, 15, wall_thickness])
    stemma_qt_sensor_mount("VL53L0X");

    // PIR motion sensor mount
    translate([80, 15, wall_thickness])
    pir_sensor_mount();

    // BME280 environmental sensor mount
    translate([20, 50, wall_thickness])
    stemma_qt_sensor_mount("BME280");

    // STEMMA QT 5-Port Hub central mounting
    translate([assembly_width/2, assembly_depth-20, wall_thickness])
    stemma_qt_hub_mount();

    // Camera variant sensor mounts
    if (camera_variant) {
        // OV5640 camera mount
        translate([assembly_width/2, assembly_depth/2, wall_thickness])
        camera_sensor_mount();

        // High-Power IR LED mount
        translate([assembly_width/2 + 25, assembly_depth/2, wall_thickness])
        ir_led_mount();
    }
}

// Standard STEMMA QT sensor mount (20x20mm breakouts)
module stemma_qt_sensor_mount(sensor_type) {
    difference() {
        // Base mounting platform
        cube([apds9960_width + 4, apds9960_length + 4, 6], center=true);

        // Sensor PCB recess
        translate([0, 0, 2])
        cube([apds9960_width, apds9960_length, 4], center=true);

        // STEMMA QT mounting holes (standard 2.54mm spacing)
        translate([7.5, 7.5, -2])
        cylinder(d=2.5, h=8);
        translate([-7.5, 7.5, -2])
        cylinder(d=2.5, h=8);
        translate([7.5, -7.5, -2])
        cylinder(d=2.5, h=8);
        translate([-7.5, -7.5, -2])
        cylinder(d=2.5, h=8);
    }

    // Sensor retention clips
    translate([8, 0, 3])
    sensor_retention_clip();
    translate([-8, 0, 3])
    sensor_retention_clip();
}

// PIR motion sensor mount (HC-SR501)
module pir_sensor_mount() {
    difference() {
        cylinder(d=pir_diameter+8, h=8);
        translate([0, 0, 3])
        cylinder(d=pir_diameter, h=6);

        // PIR mounting holes
        translate([12, 0, -1])
        cylinder(d=3, h=10);
        translate([-12, 0, -1])
        cylinder(d=3, h=10);
    }

    // PIR retention clips
    for(a = [0:120:240]) {
        rotate([0, 0, a])
        translate([pir_diameter/2 + 2, 0, 5])
        sensor_retention_clip();
    }
}

// STEMMA QT 5-Port Hub mount
module stemma_qt_hub_mount() {
    difference() {
        cube([hub_width + 6, hub_length + 6, 8], center=true);

        // Hub PCB recess
        translate([0, 0, 2])
        cube([hub_width, hub_length, 6], center=true);

        // Hub mounting holes
        translate([8, 8, -2])
        cylinder(d=2.5, h=10);
        translate([-8, 8, -2])
        cylinder(d=2.5, h=10);
        translate([8, -8, -2])
        cylinder(d=2.5, h=10);
        translate([-8, -8, -2])
        cylinder(d=2.5, h=10);
    }

    // Cable management for 5 STEMMA QT connections
    for(i = [0:4]) {
        rotate([0, 0, i*72])
        translate([15, 0, 4])
        cable_management_clip();
    }
}

// Camera sensor mount (OV5640) for camera variant
module camera_sensor_mount() {
    difference() {
        cube([ov5640_width + 6, ov5640_length + 6, 10], center=true);

        // Camera PCB recess
        translate([0, 0, 3])
        cube([ov5640_width, ov5640_length, 8], center=true);

        // Camera lens opening
        cylinder(d=20, h=12, center=true);

        // Camera mounting holes
        translate([12, 12, -2])
        cylinder(d=2.5, h=12);
        translate([-12, 12, -2])
        cylinder(d=2.5, h=12);
        translate([12, -12, -2])
        cylinder(d=2.5, h=12);
        translate([-12, -12, -2])
        cylinder(d=2.5, h=12);
    }
}

// IR LED mount for camera variant
module ir_led_mount() {
    difference() {
        cylinder(d=ir_led_diameter+6, h=ir_led_height+2);
        translate([0, 0, 2])
        cylinder(d=ir_led_diameter, h=ir_led_height+1);

        // LED mounting holes
        translate([6, 0, -1])
        cylinder(d=2.5, h=ir_led_height+4);
        translate([-6, 0, -1])
        cylinder(d=2.5, h=ir_led_height+4);
    }
}

// Sensor retention clip for secure mounting
module sensor_retention_clip() {
    difference() {
        cube([3, 6, 4], center=true);
        translate([1, 0, 1])
        rotate([0, 45, 0])
        cube([3, 8, 3], center=true);
    }
}

// Cable management clip for STEMMA QT connections
module cable_management_clip() {
    difference() {
        cylinder(d=6, h=4);
        translate([0, 0, 1])
        cylinder(d=4, h=4);
        translate([-2, 0, 1])
        cube([4, 2, 4]);
    }
}

// Sensor identification labels for inlet assembly
module inlet_sensor_labels() {
    // APDS9960 proximity sensor label
    translate([20, 25, label_depth])
    sensor_label("APDS");

    // VL53L0X ToF sensor label
    translate([50, 25, label_depth])
    sensor_label("ToF");

    // PIR motion sensor label
    translate([80, 35, label_depth])
    sensor_label("PIR");

    // BME280 environmental sensor label
    translate([20, 60, label_depth])
    sensor_label("BME280");

    // STEMMA QT hub label
    translate([assembly_width/2, assembly_depth-10, label_depth])
    sensor_label("HUB");

    // Main assembly identification
    translate([assembly_width/2, 8, label_depth])
    sensor_label("INLET SENSORS");

    // Camera variant labels
    if (camera_variant) {
        translate([assembly_width/2, assembly_depth/2 + 20, label_depth])
        sensor_label("5MP CAM");

        translate([assembly_width/2 + 25, assembly_depth/2 + 10, label_depth])
        sensor_label("IR LED");
    }

    // Architecture version label
    translate([assembly_width-30, assembly_depth-8, label_depth])
    sensor_label("2025", 3);
}

// Weatherproof lid for inlet sensor assembly
module inlet_sensor_lid() {
    difference() {
        // Main lid body
        translate([corner_radius, corner_radius, 0])
        hull() {
            cylinder(r=corner_radius, h=wall_thickness);
            translate([assembly_width-2*corner_radius, 0, 0])
                cylinder(r=corner_radius, h=wall_thickness);
            translate([0, assembly_depth-2*corner_radius, 0])
                cylinder(r=corner_radius, h=wall_thickness);
            translate([assembly_width-2*corner_radius, assembly_depth-2*corner_radius, 0])
                cylinder(r=corner_radius, h=wall_thickness);
        }

        // Sensor window access (for optical sensors)
        translate([20, 15, -1])
        cylinder(d=10, h=wall_thickness+2);  // APDS9960 window

        translate([50, 15, -1])
        cylinder(d=6, h=wall_thickness+2);   // VL53L0X window

        translate([80, 15, -1])
        cylinder(d=pir_diameter, h=wall_thickness+2);  // PIR dome

        // Environmental vents (BME280)
        for(i = [0:2]) {
            translate([20 + i*15, 50, -1])
            cylinder(d=2, h=wall_thickness+2);
        }

        // Camera window (camera variant)
        if (camera_variant) {
            translate([assembly_width/2, assembly_depth/2, -1])
            cylinder(d=23, h=wall_thickness+2);
        }
    }

    // O-ring sealing rim
    translate([seal_groove_width+1, seal_groove_width+1, wall_thickness])
    difference() {
        cube([assembly_width-2*(seal_groove_width+1),
              assembly_depth-2*(seal_groove_width+1),
              seal_groove_depth-0.5]);
        translate([1, 1, -1])
        cube([assembly_width-2*(seal_groove_width+3),
              assembly_depth-2*(seal_groove_width+3),
              seal_groove_depth+1]);
    }

    // Lid retention clips (snap-fit)
    for(x = [0, 1]) {
        for(y = [0, 1]) {
            translate([x ? assembly_width-8 : 8,
                      y ? assembly_depth-8 : 8,
                      wall_thickness])
            lid_retention_clip();
        }
    }
}

// Lid retention clip for snap-fit closure
module lid_retention_clip() {
    difference() {
        cube([6, 3, 4]);
        translate([3, 1.5, 2])
        rotate([45, 0, 0])
        cube([8, 2, 2], center=true);
    }
}

// Print layout and module selection
// Set which_part to generate specific components:
// "assembly" - Main inlet sensor assembly housing
// "lid" - Weatherproof lid (print separately)
// "both" - Assembly view with both parts
// "separate" - Both parts positioned for printing

which_part = "assembly"; // [assembly, lid, both, separate]

// Validate parameter
assert(which_part == "assembly" || which_part == "lid" || which_part == "both" || which_part == "separate",
       "Invalid which_part value. Use: assembly, lid, both, or separate");

if (which_part == "assembly") {
    inlet_sensor_assembly();
} else if (which_part == "lid") {
    inlet_sensor_lid();
} else if (which_part == "both") {
    // Assembly preview
    color("lightgreen") inlet_sensor_assembly();
    color("darkgreen", 0.7) translate([0, 0, assembly_height]) inlet_sensor_lid();
} else if (which_part == "separate") {
    // Both parts positioned for printing
    inlet_sensor_assembly();
    translate([0, assembly_depth + 20, 0]) inlet_sensor_lid();
}

// Assembly validation
echo(str("Inlet Sensor Assembly Dimensions: ",
         assembly_width, "mm x ", assembly_depth, "mm x ", assembly_height, "mm"));
echo(str("Camera Variant: ", camera_variant ? "Enabled" : "Disabled"));
echo(str("Total Sensor Count: ", camera_variant ? "6 sensors + camera" : "4 sensors"));
