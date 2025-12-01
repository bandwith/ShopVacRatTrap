// ShopVac Rat Trap - Universal Vacuum Adapter
// Features: Stepped IDs for multiple hose sizes, friction fit

$fn = 100;

// Dimensions
trap_od = 101.6; // 4" PVC equivalent
adapter_len = 100;
wall_thickness = 3;

// Hose IDs (Stepped)
id_1 = 31.75; // 1.25"
id_2 = 47.6;  // 1.875"
id_3 = 63.5;  // 2.5"
id_4 = 76.2;  // 3.0"

step_len = 25;

module vacuum_adapter_universal() {
    difference() {
        union() {
            // === TRAP CONNECTION FLANGE ===
            cylinder(d=trap_od + 6, h=20);

            // === STEPPED ADAPTER BODY ===
            translate([0, 0, 20]) {
                // Stage 3 (Base)
                cylinder(d=id_4 + wall_thickness*2, h=step_len);

                // Stage 2
                translate([0, 0, step_len])
                    cylinder(d=id_3 + wall_thickness*2, h=step_len);

                // Stage 1
                translate([0, 0, step_len*2])
                    cylinder(d=id_2 + wall_thickness*2, h=step_len);

                // Stage 0 (Tip)
                translate([0, 0, step_len*3])
                    cylinder(d=id_1 + wall_thickness*2, h=step_len);
            }

            // === CONTROL BOX MOUNTING FLANGE ===
            translate([-40, -trap_od/2 - 5, 0]) {
                cube([80, 5, 80]); // Vertical plate
            }
        }

        // === INTERNAL HOLLOW ===
        // Trap connection
        translate([0, 0, -1])
            cylinder(d=trap_od, h=21);

        // Stepped Hollows
        translate([0, 0, 20]) {
            translate([0, 0, -1])
                cylinder(d=id_4, h=step_len + 2);

            translate([0, 0, step_len - 1])
                cylinder(d=id_3, h=step_len + 2);

            translate([0, 0, step_len*2 - 1])
                cylinder(d=id_2, h=step_len + 2);

            translate([0, 0, step_len*3 - 1])
                cylinder(d=id_1, h=step_len + 2);
        }

        // === MOUNTING HOLES ===
        translate([-40, -trap_od/2 - 10, 10]) {
             // Match control box spacing
             translate([40 - 40, 0, 0]) rotate([-90,0,0]) cylinder(d=3.5, h=20);
             translate([40 + 40, 0, 0]) rotate([-90,0,0]) cylinder(d=3.5, h=20);
             translate([40 - 40, 0, 55]) rotate([-90,0,0]) cylinder(d=3.5, h=20);
             translate([40 + 40, 0, 55]) rotate([-90,0,0]) cylinder(d=3.5, h=20);
        }
    }

    // === FRICTION RIBS ===
    // Add small rings for grip
    for(i=[1:3]) {
        translate([0, 0, 20 + i*step_len - 5])
            difference() {
                cylinder(d=id_4 + wall_thickness*2 + 1, h=2);
                translate([0,0,-1]) cylinder(d=id_4, h=4);
            }
    }
}

vacuum_adapter_universal();
