# ShopVac Rat Trap - Assembly Guide

This guide provides step-by-step instructions for building the ShopVac Rat Trap . It covers 3D printing, mechanical assembly, electrical wiring, and firmware flashing.

## 1. 3D Printing

All parts are designed to be printed without supports if oriented correctly.

### Recommended Settings
- **Material**: PETG or ABS (PLA is not recommended for durability).
- **Layer Height**: 0.2mm.
- **Infill**: 40% Gyroid (for strength).
- **Wall Thickness**: **4mm** (Critical for chew resistance).

### Parts List
| File | Description | Notes |
|------|-------------|-------|
| `trap_body_main.stl` | Main tube body | Print vertically. |
| `trap_entrance.stl` | Bottom entrance with sensor mounts | Print flat side down. |
| `vacuum_funnel.stl` | Funnel connecting to vacuum hose | Print flange down. |
| `bait_station.stl` | Side bait holder | Print with opening up. |
| `camera_mount.stl` | (Optional) Camera clamp | Print in two parts. |

---

## 2. Mechanical Assembly

![Exploded View](docs/images/exploded_view.png)

### Steps
1.  **Prepare Parts**: Remove any brim or stringing from prints. Ensure sensor ports are clear.
2.  **Install Inserts**: Heat-set M3 threaded inserts into all mounting holes (sensor mounts, flange connections).
3.  **Assemble Body**:
    *   Attach `vacuum_funnel` to the top of `trap_body_main` using M3x10mm screws.
    *   Attach `trap_entrance` to the bottom of `trap_body_main`.
    *   Screw the `bait_station` into the side port.
4.  **Mount Sensors**:
    *   Secure VL53L0X to the top mount on `trap_entrance`.
    *   Secure PIR sensor to the side mount on `trap_body_main`.
    *   Secure APDS9960 to the bait station mount.
5.  **Camera (Optional)**: Clamp the camera mount to the top of the tube and secure the OV5640.

---

## 3. Electrical Wiring

> [!WARNING]
> **High Voltage Hazard**: This project controls mains voltage (120V/240V). Ensure the device is unplugged while wiring the relay.

![Wiring Diagram](docs/images/wiring_diagram.png)

### Connections

| Component | ESP32 Pin | Notes |
|-----------|-----------|-------|
| **I2C Bus** | SDA=GPIO3, SCL=GPIO4 | Connect APDS9960, VL53L0X, BME280, OLED |
| **PIR Sensor** | GPIO13 | Input (Pull-down) |
| **Relay Control** | GPIO5 | Output (Active High) |
| **Emergency Stop** | GPIO18 | Input (Pull-up, Inverted) |
| **Grove Vision AI V2 TX** | GPIO17 (ESP32 RX) | UART Communication |
| **Grove Vision AI V2 RX** | GPIO16 (ESP32 TX) | UART Communication |

### Power Distribution
- **ESP32**: Powered via USB-C or 5V regulator.
- **Sensors**: 3.3V from ESP32 regulator (ensure total current < 500mA).
- **Vacuum**: Switched via SSR/Relay on the Live wire.

---

## 4. Firmware Flashing

1.  **Install ESPHome**: `pip install esphome`
2.  **Connect**: Plug ESP32 into computer via USB.
3.  **Flash**:
    ```bash
    # For Standard Version
    esphome run esphome/rat-trap-.yaml

    # For Camera Version
    esphome run esphome/rat-trap-stemma-camera.yaml
    ```
4.  **Verify**: Check logs for "WiFi Connected" and sensor initialization.

---

## 5. Testing & Calibration

1.  **Sensor Check**: Use the OLED display or Web Interface to verify all sensors show "OK".
2.  **Thresholds**: Adjust `detection_threshold` (ToF) and `apds_proximity_threshold` in the Web UI if needed.
3.  **Dry Run**: Use the "Manual Trigger" button in the Web UI to test the vacuum activation (ensure vacuum is connected!).
