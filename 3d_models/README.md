# 3D Models

This directory contains all the 3D models for the ShopVac Rat Trap 2025.

## File Structure

Each component is in its own SCAD file, ready for printing.

- `trap_entrance.scad`: The 4-inch opening with sensor mounts and a snap-fit connector.
- `trap_body_main.scad`: The main body of the trap with a flat bottom, snap-fit connectors, and a port for the bait station.
- `trap_funnel_adapter.scad`: A modular funnel to connect to the shop vacuum with a snap-fit connector.
- `bait_station.scad`: A removable bait station.
- `control_box_enclosure.scad`: A new enclosure for the low-voltage electronics with mounting tabs and a separate lid.
- `control_box_lid.scad`: The lid for the new control box.
- `sensor_mount.scad`: A mount for attaching sensors to a PVC pipe.
- `vacuum_funnel.scad`: A funnel for connecting a PVC pipe to a shop vacuum hose.
- `camera_mount.scad`: A mount for attaching a camera to a PVC pipe.

## Generating STL Files

To generate the STL files for printing, you can use the following command:

```bash
python .github/scripts/build.py --build
```

This script will generate STL files for all of the SCAD files in this directory.

## Printing Recommendations

- **Material**: PETG or ASA for UV resistance and durability.
- **Layer Height**: 0.2mm
- **Infill**: 20%
- **Supports**: Required for some parts, especially the snap-fit clips.
