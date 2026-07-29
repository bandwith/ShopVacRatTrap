// ShopVac Rat Trap - Shared Module Library
// Defines all shared parameters, BOM component dimensions, and reusable modules.
// This file is included by all part files via: include <trap_modules.scad>
// It must NOT contain any top-level geometry render calls.

$fn = 100;
include <helpers.scad>

// ============================================================
// CORE TUBE DIMENSIONS (4" PVC standard per design spec)
// ============================================================
tube_od = 101.6;                    // 4" PVC outer diameter (mm)
wall_thickness = 3.2;               // Tube wall thickness (mm)
tube_id = tube_od - 2*wall_thickness; // 95.2mm inner diameter

// ============================================================
// PRINT PARAMETERS
// ============================================================
print_tolerance = 0.3;              // FDM clearance for mating parts (mm)

// ============================================================
// CABLE CHANNEL PARAMETERS
// ============================================================
cable_channel_od = 12;              // Outer diameter of cable conduit
cable_channel_id = 8;               // Inner diameter - fits JST SH connectors (~6mm)

// ============================================================
// FLANGE JOINT PARAMETERS
// Bolted flange joint replaces twist-lock for reliable assembly.
// Male lip slides into female socket; 4x M4 bolts through flanges secure the joint.
// ============================================================
flange_od = 120;                    // Outer diameter of flange ring
flange_thickness = 5;               // Height of each flange plate
lip_length = 10;                    // Length of male lip / female socket depth
lip_clearance = print_tolerance;    // Radial clearance on lip
bolt_hole_diameter = 4.5;           // M4 clearance hole (4mm + tolerance)
bolt_hole_inset = 10;              // Distance from flange edge to bolt center
bolt_count = 4;                     // Number of bolts (evenly spaced at 90 deg)

// ============================================================
// SPLIT BODY JOINT PARAMETERS (front/rear halves)
// ============================================================
alignment_pin_diameter = 6;         // Alignment pin OD (mm)
alignment_pin_length = 12;          // Pin insertion depth (mm)
oring_groove_width = 3;             // For 2.5mm cross-section O-ring
oring_groove_depth = 1.5;           // Depth of O-ring channel

// ============================================================
// BOM COMPONENT DIMENSIONS - STEMMA QT Sensors (Adafruit Standard)
// ============================================================
stemma_qt_board_width = 17.78;      // 0.7" PCB width
stemma_qt_board_length = 25.4;      // 1.0" PCB length
stemma_qt_board_thickness = 1.6;    // Standard PCB thickness
stemma_qt_hole_diameter = 2.7;      // M2.5 clearance hole
stemma_qt_hole_spacing_x = 12.7;   // Mounting hole X spacing
stemma_qt_hole_spacing_y = 20.3;   // Mounting hole Y spacing

// ============================================================
// BOM COMPONENT DIMENSIONS - PIR Motion Sensor (Adafruit 4871)
// ============================================================
pir_board_width = 24;               // PCB width (mm)
pir_board_length = 32;              // PCB length (mm)
pir_hole_diameter = 3.2;            // M3 clearance hole
pir_hole_spacing = 28;             // Distance between mounting holes
pir_dome_diameter = 12;            // PIR dome/lens diameter
pir_dome_clearance = 14;           // Clearance hole for dome

// ============================================================
// BOM COMPONENT DIMENSIONS - Camera (Adafruit 5945 OV5640)
// ============================================================
camera_board_size = 32;             // Square PCB (32x32mm)
camera_hole_diameter = 2.7;         // M2.5 clearance hole
camera_hole_spacing = 28;           // Corner hole spacing
camera_lens_clearance = 14;         // M12 lens mount clearance hole

// ============================================================
// BOM COMPONENT DIMENSIONS - OLED Display (Adafruit 326, 128x64)
// ============================================================
oled_board_width = 27;              // Display PCB width
oled_board_height = 27.5;           // Display PCB height
oled_hole_diameter = 2.7;           // M2.5 clearance
oled_active_width = 23;             // Visible display area width
oled_active_height = 12;            // Visible display area height

// ============================================================
// BOM COMPONENT DIMENSIONS - ESP32 Feather
// ============================================================
esp32_board_width = 22.9;           // PCB width
esp32_board_length = 50.8;          // PCB length
esp32_hole_diameter = 2.7;          // M2.5 clearance
esp32_hole_spacing_x = 20.32;      // Mounting hole X spacing
esp32_hole_spacing_y = 48.26;      // Mounting hole Y spacing

// ============================================================
// BOM COMPONENT DIMENSIONS - SSR (Panasonic AQA411VL)
// ============================================================
ssr_width = 25.5;                   // SSR module width
ssr_length = 58;                    // SSR module length
ssr_height = 40;                    // SSR module height

// ============================================================
// BOM COMPONENT DIMENSIONS - Hammond Enclosure (PN-1334-C)
// ============================================================
hammond_ext_length = 200;           // External length
hammond_ext_width = 120;            // External width
hammond_ext_height = 75;            // External height
hammond_int_length = 192;           // Internal length
hammond_int_width = 112;            // Internal width
hammond_int_height = 69;            // Internal height

// ============================================================
// MODULES
// ============================================================

// ---------- FLANGE JOINT MALE ----------
// A lip cylinder on top of a flange ring, with bolt holes.
// The lip is slightly undersized to slide into the female socket.
// Attach at the END of a tube section (translate to tube top).
module flange_joint_male() {
    lip_od = tube_od - 2*lip_clearance;  // Undersized to fit inside female

    // Flange plate (base)
    flange(d=flange_od, thick=flange_thickness,
           center_hole_d=tube_id,
           hole_d=bolt_hole_diameter, inset=bolt_hole_inset,
           hole_count=bolt_count);

    // Lip (extends above flange)
    translate([0, 0, flange_thickness])
    difference() {
        cylinder(d=lip_od, h=lip_length);
        translate([0, 0, -1])
            cylinder(d=tube_id, h=lip_length + 2);
    }
}

// ---------- FLANGE JOINT FEMALE ----------
// A socket ring below a flange ring, with aligned bolt holes.
// The socket receives the male lip with clearance.
// Attach at the START of a tube section (sits below tube).
module flange_joint_female() {
    socket_id = tube_od + lip_clearance;  // Slightly oversized to receive male lip
    socket_od = tube_od + 2*wall_thickness;  // Outer wall of socket

    // Flange plate (top)
    translate([0, 0, lip_length])
    flange(d=flange_od, thick=flange_thickness,
           center_hole_d=tube_id,
           hole_d=bolt_hole_diameter, inset=bolt_hole_inset,
           hole_count=bolt_count);

    // Socket ring (extends below flange)
    difference() {
        cylinder(d=socket_od, h=lip_length);
        translate([0, 0, -1])
            cylinder(d=socket_id, h=lip_length + 2);
    }

    // Inner bore continuity (so tube ID is maintained through socket)
    difference() {
        cylinder(d=socket_id, h=lip_length);
        translate([0, 0, -1])
            cylinder(d=tube_id, h=lip_length + 2);
        // The male lip fills the annular gap between tube_id and socket_id
    }
}

// ---------- TRAP MODULE BASE ----------
// Base tube section with integrated cable channel and optional flange joints.
// Parameters:
//   length     - tube body length (not including joints)
//   male_end   - if true, add flange_joint_male at +Z end
//   female_end - if true, add flange_joint_female at Z=0 end
module trap_module_base(length, male_end=true, female_end=true) {
    // Offset body upward if female end is present (socket sits below)
    body_z_offset = female_end ? lip_length + flange_thickness : 0;

    translate([0, 0, body_z_offset]) {
        difference() {
            union() {
                // Main tube body
                tube(length=length, od=tube_od, wall=wall_thickness);

                // Integrated cable channel (top, external)
                translate([0, tube_od/2 + cable_channel_od/2 - 2, 0])
                    cylinder(d=cable_channel_od, h=length);

                // Bridge between tube and cable channel
                translate([-cable_channel_od/4, tube_od/2 - 1, 0])
                    cube([cable_channel_od/2, cable_channel_od/2 + 1, length]);
            }

            // Hollow cable channel
            translate([0, tube_od/2 + cable_channel_od/2 - 2, -1])
                cylinder(d=cable_channel_id, h=length + 2);
        }
    }

    // Add flange joints
    if (male_end) {
        translate([0, 0, body_z_offset + length])
            flange_joint_male();
    }

    if (female_end) {
        flange_joint_female();
    }
}

// ---------- SENSOR MODULE ----------
// Tube section with sensor cutouts for VL53L0X (ToF) and PIR.
// Uses trap_module_base as the structural body.
// Parameters:
//   length - body length (default 80mm)
module sensor_module(length=80) {
    difference() {
        trap_module_base(length);

        // Calculate body offset for cutout positioning
        body_z_offset = lip_length + flange_thickness;

        // ToF Sensor cutout (side-facing, centered along length)
        translate([0, 0, body_z_offset + length/2])
            rotate([90, 0, 0])
                cylinder(d=stemma_qt_board_width + 2*print_tolerance, h=tube_od);

        // PIR Sensor cutout (offset along length, larger dome clearance)
        translate([0, 0, body_z_offset + length/2 + 20])
            rotate([90, 0, 90])
                cylinder(d=pir_dome_clearance, h=tube_od);
    }

    // Sensor mount boss (external, for ToF sensor bracket)
    body_z_offset = lip_length + flange_thickness;
    translate([0, -tube_od/2 - 5, body_z_offset + length/2]) {
        difference() {
            cube([stemma_qt_board_length + 4, 8, stemma_qt_board_width + 4], center=true);
            // Cavity for sensor PCB
            cube([stemma_qt_board_length + 2*print_tolerance,
                  10,
                  stemma_qt_board_width + 2*print_tolerance], center=true);
            // Mounting holes (M2.5)
            for (dx = [-stemma_qt_hole_spacing_y/2, stemma_qt_hole_spacing_y/2]) {
                translate([dx, 0, 0])
                    rotate([90, 0, 0])
                        cylinder(d=stemma_qt_hole_diameter, h=12, center=true);
            }
        }
    }
}
