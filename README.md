ShopVac Rat Trap
================

Details and rough instructions here:

<link here>

Materials:
----------

* 2 ft. length of 4 in. black ABS sewer pipe
* Roll of Plumber's Tape
* 3/4in. wide-head wood screws
* Wire loom
* Wire loom tape
* WAGO or equivalent wire fasteners, some 2 and 3 wire variants
* 1x2 ft. piece of 3/4 in. plywood
* One plastic, deep 1 Gang Outlet Box
* One Single Gang, Single 15Amp Outlet, outlet (ideally outdoor rated)
* One corresponding, outdoor rated, single gang, single outlet face plate
* One six foot power cable with male end
* Couple feet of 16/3 wire (16 gauge, 3 wires)
* Roll of 22 AWG solid core wire
* One APDS9930 IR RGB and Proximity Sensor
* One 3V relay with optical isolation (generic part)
* One NodeMCU v3 ESP8266 dev board
* One small USB charging wall wart of at least 1 Amp
* Solder
* Polyimide (Kapton) Tape
* Thick CA Glue
* CA Glue Fixer

Wiring Diagram:
---------------
[Wiring Diagram](https://github.com/shellster/ShopVacRatTrap/tree/main/Pictures/RatTrapCircuitDiagram.png)

### High Voltage Side:

* Ground (Typically Green or Unsheathed) on Power Cord -> Ground on Outlet
* Neutral (Typically White) on Power Cord -> Neutral on USB Wall Wart
* Neutral (Typically White) on Power Cord -> Neutral on Outlet
* Line (Typically Black) on Power Cord -> Line on USB Wall Wart
* Line (Typically Black) on Power Cord -> COM on Relay Board
* NO (Normally Open) on Relay Board -> Line on Outlet

### Low Voltage Side:

* DC Ground on USB side of wall wart -> GND on NodeMCU
* DC Ground on USB side of wall wart -> GND on Relay Board
* DC Ground on USB side of wall wart -> GND on APDS9930 board
* 5V VCC on USB side of wall wart -> Vin on NodeMCU
* 3V3 on NodeMCU goes to VCC on Relay Board
* 3V3 on NodeMCU goes to VCC on APDS9930
* D1 on NodeMCU -> SDA on APDS9930
* D2 on NodeMCU -> SCL on APDS9930
* D5 on NodeMCU -> IN on Relay Board
* Two small solder pads on back of APDS9930 get jumpered with solder


Credits
-------

Original Inspiration: https://shoprodentstoppers.com/products/rat-vac-motion-sensor-rodent-catching-systems

APDS9930 Arduino Library: https://github.com/depau/APDS9930

Shop Vacuum Adapter OpenSCAD starting point: https://www.thingiverse.com/thing:1246651
