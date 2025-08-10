//ShopVac Rat Trap 2025 - Outlet Vacuum Hose Connection Adapter
//OUTLET DESIGN: Connects trap outlet to shop vacuum hose
//UV-RESISTANT DESIGN: For long-term outdoor deployment
//SNAP-FIT CONNECTIONS: Secure hose retention without clamps
//Adapted from: https://www.thingiverse.com/thing:1246651
//Vacuum Hose Adapter Rev 4 (August 10, 2025)
//Print Settings: See PRINT_SETTINGS.md for UV-resistant material recommendations
//Gather the parameters
/* [Parameters] */

//Example is ShopVac Nominal 2.5" machine port to 1.5" accessory.  -- For the large end, is the measurement the adapter's outside or inside diameter?
LargeEndMeasured = "outside"; //[outside, inside]
//Diameter of Large End? (mm)
LargeEndDiameter = 100;
// Length of Large End? (mm)
LargeEndLength = 15.1;
//For the small end, is the measurement the adapter's outside or inside diameter?
SmallEndMeasured = "inside"; //[outside, inside]
//Diameter of Small End? (mm)
SmallEndDiameter = 58.5;
// Length of Small End? (mm)
SmallEndLength = 25.1;
// Length of Taper Section? (mm)
TaperLength = 25.1;
//What is the thickness of the adapter's walls? (Increased for durability)
 WallThickness = 3;  // Increased from 2mm for field durability
// Create snap-fit retention rings instead of simple grip rings (enhanced retention)
LargeEndSnapProjection = 4.1;  // Increased for snap-fit retention

// Create snap-fit retention rings for small end as well
SmallEndSnapProjection = 4.1;  // Enhanced for secure hose connection

 $fn=120 *1;

     WT=WallThickness;
     LL=LargeEndLength;
     SL=SmallEndLength;
     TL=TaperLength;

// Calculate Large End Outside Diamater
     LOD=  LargeEndMeasured =="inside" ? LargeEndDiameter + 2*WT : LargeEndDiameter;
// Calculate Small End Outside Diameter
     SOD=  SmallEndMeasured =="inside" ? SmallEndDiameter + 2*WT : SmallEndDiameter;
// Calculate Large End Inside Diamater
     LID = LOD - 2*WT;
// Calculate Small End Inside Diamater
     SID = SOD - 2*WT;
// Calculate Ring Diameter for snap-fit
     DR = LOD + LargeEndSnapProjection;

// Calculate Small End Ring Diameter for snap-fit
     SR = SOD + SmallEndSnapProjection;


module TransCylinder(D1, D2, H, Z)
    {
        translate([0, 0, Z])
        {
            cylinder(d1=D1, d2=D2, h=H, center=false);
        }
    }

// Print layout and module selection
// Set which_part to generate specific components:
// "adapter" - Main vacuum hose adapter with snap-fit retention
// "large_end" - Large end for shop vacuum connection
// "small_end" - Small end for hose connection
// "test_fit" - Scaled test piece for fit verification

which_part = "adapter"; // [adapter, large_end, small_end, test_fit]

// Validate parameter
assert(which_part == "adapter" || which_part == "large_end" || which_part == "small_end" || which_part == "test_fit",
       "Invalid which_part value. Use: adapter, large_end, small_end, or test_fit");

if (which_part == "adapter") {
    // Generate main adapter body
    difference() {
        union() {
            TransCylinder(LOD, LOD, LL, 0);
            TransCylinder(LOD, DR, WT, LL);
            TransCylinder(DR, DR, WT, LL + WT);
            TransCylinder(SR, SR, WT, SL + 20 + 2*WT);
            TransCylinder(LOD, SOD, TL, LL + 2*WT);
            TransCylinder(SOD, SOD, SL, LL + TL + 2*WT);
        }
        union() {
            TransCylinder(LID, LID, LL, 0);
            TransCylinder(LID, LID, WT, LL);
            TransCylinder(LID, LID,  WT, LL + WT);
            TransCylinder(LID, SID, TL, LL + 2*WT);
            TransCylinder(SID, SID, SL, LL +TL + 2*WT);

            // Snap retention grooves
            translate([0, 0, LL + WT/2])
            rotate_extrude()
            translate([DR/2 - 1, 0, 0])
            square([2, 1]);

            translate([0, 0, SL + LL + TL + 2*WT - 5])
            rotate_extrude()
            translate([SR/2 - 1, 0, 0])
            square([2, 1]);
        }
    }
} else if (which_part == "large_end") {
    // Large end section only
    difference() {
        union() {
            TransCylinder(LOD, LOD, LL, 0);
            TransCylinder(LOD, DR, WT, LL);
            TransCylinder(DR, DR, WT, LL + WT);
        }
        union() {
            TransCylinder(LID, LID, LL + 2*WT, 0);
            translate([0, 0, LL + WT/2])
            rotate_extrude()
            translate([DR/2 - 1, 0, 0])
            square([2, 1]);
        }
    }
} else if (which_part == "small_end") {
    // Small end section only
    difference() {
        union() {
            TransCylinder(SOD, SOD, SL, 0);
            TransCylinder(SR, SR, WT, SL);
        }
        union() {
            TransCylinder(SID, SID, SL + WT, 0);
            translate([0, 0, SL - 5])
            rotate_extrude()
            translate([SR/2 - 1, 0, 0])
            square([2, 1]);
        }
    }
} else if (which_part == "test_fit") {
    // 50% scale test piece for fit verification
    scale([0.5, 0.5, 0.5]) {
        difference() {
            TransCylinder(LOD, LOD, LL/2, 0);
            TransCylinder(LID, LID, LL/2 + 2, -1);
        }
    }
}
