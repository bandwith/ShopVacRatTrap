// ShopVac Rat Trap 2025 - Inlet Rodent Detection Assembly
// INLET DESIGN: Rodent entry point with integrated VL53L0X sensor mounting
// Designed for 4" domestic wastewater pipe mounting with SNAP-FIT ASSEMBLY
// NO FASTENERS REQUIRED: Tool-free installation and maintenance
// RODENT DAMAGE PROTECTION: Enhanced anti-gnaw features and sensor protection
// Author: Hardware Designer
// Date: August 2025

// Parameters for 4" PVC pipe (standard domestic wastewater)
pvc_outer_diameter = 114.3;  // 4.5" actual OD of 4" PVC pipe
pvc_inner_diameter = 101.6;  // 4" nominal ID
pvc_wall_thickness = 6.35;   // Standard Schedule 40 wall thickness

// Trap inlet parameters (optimized for detection and durability)
inlet_length = 120;          // mm - increased length for animal guidance
inlet_diameter = 102;        // mm - matches PVC inner for seamless transition
inlet_wall_thickness = 4;    // mm - thick walls for structural integrity

// VL53L0X sensor parameters (optimized for centerline detection)
sensor_housing_diameter = 24;      // mm - compact housing for 18x18mm STEMMA QT board
sensor_housing_depth = 20;         // mm - depth for sensor and cable connections
sensor_angle = 15;                 // degrees - downward angle for optimal pipe detection
sensor_height_offset = 0;          // mm - centerline placement (previously 40mm)

// Rodent damage protection parameters
gnaw_guard_thickness = 3;          // mm - hardened outer shell thickness
cable_protection_diameter = 12;    // mm - armored cable conduit diameter
texture_feature_size = 0.5;        // mm - anti-gnaw surface texture depth
protective_ridge_height = 2;       // mm - height of anti-gnaw ridges

// Mounting flange parameters - snap-fit design (no bolts)
flange_diameter = 140;       // mm - oversized for secure mounting
flange_thickness = 8;        // mm - thick for structural integrity
snap_clip_count = 8;         // Number of snap clips around circumference
snap_clip_length = 12;       // mm - length of each snap clip
snap_clip_thickness = 2;     // mm - thickness for flexibility

// Seal groove parameters (for O-ring weatherproofing)
seal_groove_diameter = 110;  // mm
seal_groove_width = 3;       // mm
seal_groove_depth = 2;       // mm

// Funnel parameters for animal guidance
funnel_length = 80;          // mm
funnel_inlet_diameter = 85;  // mm - slightly smaller than pipe ID
funnel_outlet_diameter = 65; // mm - guides to sensor area

// Sensor mounting parameters - optimized for VL53L0X detection
sensor_mount_height = 0;      // mm - mounted at pipe centerline for optimal detection
sensor_protection_thickness = 3; // mm - rodent-proof sensor guard thickness

// Camera mounting parameters (when camera_variant = true)
camera_variant = true;        // Set true to include OV5640 5MP camera (Adafruit 5945)
camera_housing_diameter = 40; // mm - larger housing for camera module
camera_housing_depth = 30;    // mm - depth for camera and lens assembly
camera_angle = 10;            // degrees - angle for optimal view into pipe
camera_mount_offset = 45;     // mm - offset from sensor for clear view

// Additional protection parameters
protective_coating_thickness = 2; // mm - additional protection layer

$fn = 100;  // High resolution for smooth curves

// Main pipe inlet module with snap-fit mounting
module pipe_inlet() {
    difference() {
        union() {
            // Main inlet tube
            cylinder(d=inlet_diameter + 2*inlet_wall_thickness,
                    h=inlet_length);

            // Mounting flange with snap clips
            translate([0, 0, -flange_thickness])
            cylinder(d=flange_diameter, h=flange_thickness);

            // Internal funnel for animal guidance
            translate([0, 0, inlet_length])
            funnel_guide();
        }

        // Internal cavity
        translate([0, 0, -flange_thickness-1])
        cylinder(d=inlet_diameter, h=inlet_length + flange_thickness + 2);

        // PVC pipe connection recess
        translate([0, 0, -flange_thickness-1])
        cylinder(d=pvc_outer_diameter + 1, h=flange_thickness + 2);

        // O-ring seal groove
        translate([0, 0, -seal_groove_depth])
        rotate_extrude()
        translate([seal_groove_diameter/2, 0, 0])
        square([seal_groove_width, seal_groove_depth]);

        // Optimized sensor mounting hole - positioned at centerline for best detection
        translate([0, 0, inlet_length/2])
        rotate([sensor_angle, 0, 0])
        translate([0, -inlet_wall_thickness-1, 0])
        cylinder(d=sensor_housing_diameter, h=inlet_wall_thickness + 2);

        // Cable protection conduit entry
        translate([sensor_housing_diameter/2 + 5, -inlet_wall_thickness-1, inlet_length/2])
        rotate([0, 0, 0])
        cylinder(d=cable_protection_diameter, h=inlet_wall_thickness + 2);

        // Camera mounting hole (when camera_variant = true)
        if (camera_variant) {
            translate([camera_mount_offset, 0, inlet_length/2])
            rotate([camera_angle, 0, 0])
            translate([0, -inlet_wall_thickness-1, 0])
            cylinder(d=camera_housing_diameter, h=inlet_wall_thickness + 2);
        }
    }

    // Snap-fit clips for pipe mounting (replaces bolts)
    snap_fit_pipe_clips();

    // Reinforcement ribs
    reinforcement_ribs();

    // VL53L0X sensor housing with rodent protection
    vl53l0x_sensor_housing();

    // Camera housing (when camera_variant = true)
    if (camera_variant) {
        ov5640_camera_housing();
    }

    // Cable protection and routing
    cable_protection_system();

    // Anti-gnaw surface texturing on critical areas
    gnaw_resistant_texturing();
}

// Anti-gnaw surface texturing module
module gnaw_resistant_texturing() {
    // Add aggressive surface texture to deter gnawing
    intersection() {
        union() {
            // Textured surface on exposed areas
            for(z = [0:2:inlet_length]) {
                for(angle = [0:30:330]) {
                    rotate([0, 0, angle])
                    translate([inlet_diameter/2 + 1, 0, z])
                    sphere(r=0.5);
                }
            }
        }

        // Limit texturing to main body
        cylinder(d=inlet_diameter + 6, h=inlet_length);
    }
}

// Snap-fit clips for mounting to PVC pipe (no bolts required)
module snap_fit_pipe_clips() {
    for(i = [0:snap_clip_count-1]) {
        rotate([0, 0, i * 360/snap_clip_count])
        translate([flange_diameter/2-5, 0, -flange_thickness])
        pipe_snap_clip();
    }
}

// Individual snap clip for pipe mounting
module pipe_snap_clip() {
    difference() {
        // Flexible clip arm
        hull() {
            cube([snap_clip_length, snap_clip_thickness, flange_thickness]);
            translate([snap_clip_length-2, 0, flange_thickness])
            cube([2, snap_clip_thickness+2, 2]);
        }

        // Relief cut for flexibility
        translate([snap_clip_length-4, snap_clip_thickness/2, flange_thickness/2])
        cylinder(d=1, h=flange_thickness);
    }

    // Catch hook for pipe edge
    translate([snap_clip_length, 0, flange_thickness])
    difference() {
        cube([2, snap_clip_thickness+2, 2]);
        translate([1, snap_clip_thickness+1, 1])
        rotate([0, 45, 0])
        cube([2, 3, 2], center=true);
    }
}

// Internal funnel for animal guidance
module funnel_guide() {
    difference() {
        // Funnel shape
        cylinder(d1=funnel_inlet_diameter, d2=funnel_outlet_diameter, h=funnel_length);

        // Internal cavity
        translate([0, 0, -1])
        cylinder(d1=funnel_inlet_diameter - 6, d2=funnel_outlet_diameter - 6, h=funnel_length + 2);
    }
}

// Reinforcement ribs for structural strength
module reinforcement_ribs() {
    for(i = [0:3]) {
        rotate([0, 0, i * 90])
        translate([inlet_diameter/2 + inlet_wall_thickness/2, 0, 0])
        cube([2, 8, inlet_length], center=true);
    }
}

// VL53L0X sensor housing with rodent-proof protection
module vl53l0x_sensor_housing() {
    translate([0, 0, inlet_length/2])
    rotate([sensor_angle, 0, 0])
    translate([0, -inlet_wall_thickness-sensor_housing_depth, 0]) {
        difference() {
            union() {
                // Main sensor housing body
                cylinder(d=sensor_housing_diameter, h=sensor_housing_depth);

                // Rodent-proof gnaw guard (hardened outer shell)
                cylinder(d=sensor_housing_diameter + 2*gnaw_guard_thickness, h=gnaw_guard_thickness);

                // Mounting flange
                translate([0, 0, -3])
                cylinder(d=sensor_housing_diameter + 10, h=3);
            }

            // VL53L0X sensor board cavity (18x18mm STEMMA QT board)
            translate([0, 0, 5])
            cube([18, 18, sensor_housing_depth], center=true);

            // Sensor aperture - optimized for VL53L0X field of view
            translate([0, 0, -1])
            cylinder(d=10, h=7);  // Larger aperture for better detection

            // STEMMA QT cable routing slot
            translate([-2, -sensor_housing_diameter/2, sensor_housing_depth/2])
            cube([4, sensor_housing_diameter, 8]);

            // Mounting screw holes (snap-fit alternative)
            for(a = [0:120:240]) {
                rotate([0, 0, a])
                translate([12, 0, -4])
                cylinder(d=3.2, h=8);
            }
        }

        // Protective lens cover (prevents damage from debris)
        translate([0, 0, sensor_housing_depth-1])
        difference() {
            cylinder(d=16, h=4);
            translate([0, 0, -1])
            cylinder(d=10, h=6);
        }

        // Anti-gnaw protective ridges
        for(i = [0:7]) {
            rotate([0, 0, i * 45])
            translate([sensor_housing_diameter/2 + gnaw_guard_thickness/2, 0, gnaw_guard_thickness/2])
            cube([gnaw_guard_thickness, 2, gnaw_guard_thickness], center=true);
        }
    }
}

// OV5640 5MP camera housing with rodent protection (when camera_variant = true)
module ov5640_camera_housing() {
    translate([camera_mount_offset, 0, inlet_length/2])
    rotate([camera_angle, 0, 0])
    translate([0, -inlet_wall_thickness-camera_housing_depth, 0]) {
        difference() {
            union() {
                // Main camera housing body
                cylinder(d=camera_housing_diameter, h=camera_housing_depth);

                // Rodent-proof gnaw guard (hardened outer shell)
                cylinder(d=camera_housing_diameter + 2*gnaw_guard_thickness, h=gnaw_guard_thickness);

                // Mounting flange
                translate([0, 0, -3])
                cylinder(d=camera_housing_diameter + 10, h=3);
            }

            // OV5640 camera module cavity (32x32mm board)
            translate([0, 0, 8])
            cube([32, 32, camera_housing_depth], center=true);

            // Camera lens aperture - optimized for OV5640 field of view
            translate([0, 0, -1])
            cylinder(d=20, h=10);  // Larger aperture for camera lens

            // STEMMA QT cable routing slot
            translate([-2, -camera_housing_diameter/2, camera_housing_depth/2])
            cube([4, camera_housing_diameter, 8]);

            // Mounting screw holes (snap-fit alternative)
            for(a = [0:90:270]) {
                rotate([0, 0, a])
                translate([16, 0, -4])
                cylinder(d=3.2, h=8);
            }
        }

        // Protective lens cover (prevents damage from debris)
        translate([0, 0, camera_housing_depth-2])
        difference() {
            cylinder(d=25, h=6);
            translate([0, 0, -1])
            cylinder(d=20, h=8);
        }

        // Anti-gnaw protective ridges
        for(i = [0:7]) {
            rotate([0, 0, i * 45])
            translate([camera_housing_diameter/2 + gnaw_guard_thickness/2, 0, gnaw_guard_thickness/2])
            cube([gnaw_guard_thickness, 2, gnaw_guard_thickness], center=true);
        }
    }
}

// Cable protection and routing system
module cable_protection_system() {
    // Armored cable conduit from sensor to control box
    translate([sensor_housing_diameter/2 + 5, -inlet_wall_thickness-cable_protection_diameter, inlet_length/2])
    rotate([0, 0, 0]) {
        difference() {
            // Outer protection tube
            cylinder(d=cable_protection_diameter, h=30);

            // Inner cable passage
            translate([0, 0, -1])
            cylinder(d=6, h=32);  // 4-conductor STEMMA QT cable
        }

        // Anti-gnaw ridges on cable conduit
        for(i = [0:6]) {
            translate([0, 0, i*4])
            rotate_extrude()
            translate([cable_protection_diameter/2, 0, 0])
            square([2, 1]);
        }
    }

    // Strain relief at sensor connection
    translate([sensor_housing_diameter/2, -inlet_wall_thickness, inlet_length/2])
    rotate([0, 45, 0]) {
        difference() {
            cylinder(d=8, h=15);
            translate([0, 0, -1])
            cylinder(d=4, h=17);
        }
    }
}

// Pipe to vacuum adapter module
module pipe_to_vacuum_adapter() {
    // Standard shop vacuum connection (2.5" nominal)
    vacuum_diameter = 63.5;     // mm - 2.5" shop vac hose
    vacuum_length = 40;         // mm

    // Transition section
    transition_length = 60;     // mm

    difference() {
        union() {
            // Pipe connection end
            cylinder(d=inlet_diameter + 2*inlet_wall_thickness, h=20);

            // Transition section
            translate([0, 0, 20])
            cylinder(d1=inlet_diameter + 2*inlet_wall_thickness,
                    d2=vacuum_diameter + 6, h=transition_length);

            // Vacuum hose connection
            translate([0, 0, 20 + transition_length])
            cylinder(d=vacuum_diameter + 6, h=vacuum_length);

            // Grip rings
            for(i = [0:2]) {
                translate([0, 0, 20 + transition_length + 10 + i*12])
                cylinder(d=vacuum_diameter + 10, h=2);
            }
        }

        // Internal passages
        translate([0, 0, -1])
        cylinder(d=inlet_diameter, h=21);

        translate([0, 0, 20])
        cylinder(d1=inlet_diameter, d2=vacuum_diameter, h=transition_length);

        translate([0, 0, 20 + transition_length - 1])
        cylinder(d=vacuum_diameter, h=vacuum_length + 2);
    }
}

// Control box mounting bracket with snap-fit pipe clamps
module control_box_mount() {
    mount_width = 160;      // mm - fits control box
    mount_depth = 110;      // mm
    mount_thickness = 6;    // mm

    // Pipe clamp parameters
    clamp_diameter = pvc_outer_diameter + 10;
    clamp_width = 40;       // mm

    difference() {
        union() {
            // Main mounting plate
            cube([mount_width, mount_depth, mount_thickness]);

            // Pipe clamp base sections
            translate([mount_width/2, 0, mount_thickness])
            rotate([-90, 0, 0])
            difference() {
                cylinder(d=clamp_diameter, h=clamp_width);
                translate([0, 0, -1])
                cylinder(d=pvc_outer_diameter + 2, h=clamp_width + 2);
                translate([-clamp_diameter/2, 0, -1])
                cube([clamp_diameter, clamp_diameter/2, clamp_width + 2]);
            }
        }

        // Control box snap-fit mounting slots (no screws)
        for(x = [15, mount_width-15]) {
            for(y = [15, mount_depth-15]) {
                translate([x-2, y-2, -1])
                cube([4, 4, mount_thickness + 2]);

                translate([x, y, mount_thickness-2])
                cylinder(d=8, h=3);
            }
        }
    }

    // Snap-fit clamps for pipe mounting (replaces bolts)
    translate([mount_width/2 - 15, clamp_width/2, mount_thickness + clamp_diameter/2])
    rotate([0, 90, 0])
    pipe_clamp_snap();

    translate([mount_width/2 + 15, clamp_width/2, mount_thickness + clamp_diameter/2])
    rotate([0, 90, 0])
    pipe_clamp_snap();
}

// Snap-fit clamp for pipe mounting (replaces bolts)
module pipe_clamp_snap() {
    difference() {
        // Clamp arm
        hull() {
            cylinder(d=6, h=8);
            translate([0, 15, 0])
            cylinder(d=8, h=8);
        }

        // Flexibility groove
        translate([0, 8, 4])
        cube([8, 2, 2], center=true);
    }

    // Snap catch
    translate([0, 15, 4])
    difference() {
        cube([6, 4, 4], center=true);
        translate([0, 2, 0])
        rotate([45, 0, 0])
        cube([8, 4, 4], center=true);
    }
}

// Weatherproof cover for control box
module control_box_cover() {
    cover_width = 160;      // mm - slightly larger than control box
    cover_depth = 115;      // mm
    cover_height = 80;      // mm
    wall_thickness = 3;     // mm

    difference() {
        // Outer shell
        hull() {
            translate([5, 5, 0])
            cylinder(r=5, h=cover_height);
            translate([cover_width-5, 5, 0])
            cylinder(r=5, h=cover_height);
            translate([5, cover_depth-5, 0])
            cylinder(r=5, h=cover_height);
            translate([cover_width-5, cover_depth-5, 0])
            cylinder(r=5, h=cover_height);
        }

        // Internal cavity
        translate([wall_thickness, wall_thickness, wall_thickness])
        cube([cover_width - 2*wall_thickness,
              cover_depth - 2*wall_thickness,
              cover_height]);

        // Display window
        translate([25, -1, 35])
        cube([30, wall_thickness + 2, 25]);

        // Button access holes
        translate([70, -1, 45])
        cylinder(d=8, h=wall_thickness + 2);

        translate([90, -1, 45])
        cylinder(d=8, h=wall_thickness + 2);

        translate([110, -1, 35])
        cylinder(d=8, h=wall_thickness + 2);

        // Ventilation slots
        for(i = [0:4]) {
            translate([cover_width - wall_thickness - 1, 20 + i*15, 15])
            cube([wall_thickness + 2, 8, 4]);
        }

        // Cable entry port
        translate([cover_width/2, cover_depth - wall_thickness - 1, 20])
        cylinder(d=12, h=wall_thickness + 2);
    }

    // Mounting tabs
    for(x = [10, cover_width-10]) {
        for(y = [10, cover_depth-10]) {
            translate([x, y, -5])
            difference() {
                cylinder(d=12, h=5);
                translate([0, 0, -1])
                cylinder(d=4.5, h=7);
            }
        }
    }
}

// Print layout and module selection
// Set which_part to generate specific components:
// "inlet" - Main pipe inlet with sensors
// "adapter" - Pipe to vacuum adapter
// "mount" - Control box mounting bracket
// "cover" - Weatherproof cover
// "all" - Assembly preview with all components
// "print_set" - All parts positioned for printing

which_part = "inlet"; // [inlet, adapter, mount, cover, all, print_set]

// Validate parameter
assert(which_part == "inlet" || which_part == "adapter" || which_part == "mount" ||
       which_part == "cover" || which_part == "all" || which_part == "print_set",
       "Invalid which_part value. Use: inlet, adapter, mount, cover, all, or print_set");

if (which_part == "inlet") {
    pipe_inlet();
} else if (which_part == "adapter") {
    pipe_to_vacuum_adapter();
} else if (which_part == "mount") {
    control_box_mount();
} else if (which_part == "cover") {
    control_box_cover();
} else if (which_part == "all") {
    // Assembly preview (all components)
    color("lightblue") pipe_inlet();
    color("green") translate([0, 0, 120]) pipe_to_vacuum_adapter();
    color("red", 0.7) translate([200, -60, 0]) control_box_mount();
    color("yellow", 0.6) translate([200, -60, 6]) control_box_cover();
} else if (which_part == "print_set") {
    // All parts positioned for printing
    pipe_inlet();
    translate([150, 0, 0]) pipe_to_vacuum_adapter();
    translate([0, 150, 0]) control_box_mount();
    translate([200, 150, 0]) control_box_cover();
}
