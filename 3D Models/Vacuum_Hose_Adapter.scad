//FollyMaker
//Adapted from: https://www.thingiverse.com/thing:1246651
//Vacuum Hose Adapter Rev 2 (January 4, 2023) 
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
//What is the thickness of the adapter's walls?
 WallThickness = 2;
// Create a ring on the outside of the large end (for your fingers to grip when pulling the adapter out of the hose)  Use 0 projection for no ring.
LargeEndGripProjection = 3.1;

// Create a ring on the outside of the small end (for your fingers to grip when pulling the adapter out of the hose)  Use 0 projection for no ring.
SmallEndGripProjection = 3.1;
 
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
// Calculate Ring Diameter
     DR = LOD + LargeEndGripProjection;
     
// Calculate Small End Ring Diameter
     SR = SOD + SmallEndGripProjection;
     
 
module TransCylinder(D1, D2, H, Z)
    {
        translate([0, 0, Z])
        {
            cylinder(d1=D1, d2=D2, h=H, center=false);
        }
    }
   
difference()
{
      union()
        { 
            TransCylinder(LOD, LOD, LL, 0);
            TransCylinder(LOD, DR, WT, LL);
            TransCylinder(DR, DR, WT, LL + WT);
            TransCylinder(SR, SR, WT, SL + 20 + 2*WT);
            TransCylinder(LOD, SOD, TL, LL + 2*WT);
            TransCylinder(SOD, SOD, SL, LL + TL + 2*WT);
          } 
     union()
        {
            TransCylinder(LID, LID, LL, 0);
            TransCylinder(LID, LID, WT, LL);
            TransCylinder(LID, LID,  WT, LL + WT);
            TransCylinder(LID, SID, TL, LL + 2*WT);
            TransCylinder(SID, SID, SL, LL +TL + 2*WT);
        }
}   