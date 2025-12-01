# ShopVac Rat Trap - Wiring Diagram

This diagram illustrates the connections between the ESP32-S3 Feather, sensors, and power components.

## ESP32-S3 Feather Pinout

```mermaid
--8<-- "docs/diagrams/pinout_graph.mmd"
```

## Pin Mapping Table

| Component | Pin / Bus | Function | Notes |
|-----------|-----------|----------|-------|
| **I2C Bus A** | GPIO 3 (SDA) | Data | Shared: Display, ToF, BME280, IMU, IR Presence |
| **I2C Bus A** | GPIO 4 (SCL) | Clock | Shared: Display, ToF, BME280, IMU, IR Presence |
| **Vacuum Relay** | GPIO 5 | Output | Controls SSR (Active High) |
| **Emergency Stop** | GPIO 6 | Input | Safety Switch (Active Low, Pull-up) |
| **Reset Button** | GPIO 9 | Input | System Reset (Active Low, Pull-up) |
| **Camera XCLK** | GPIO 10 | Clock | Camera External Clock |
| **Camera D6** | GPIO 11 | Data | Camera Data |
| **Camera D5** | GPIO 12 | Data | Camera Data |
| **Camera PCLK** | GPIO 13 | Clock | Camera Pixel Clock |
| **Camera D4** | GPIO 14 | Data | Camera Data |
| **Camera D0** | GPIO 15 | Data | Camera Data |
| **Camera D3** | GPIO 16 | Data | Camera Data |
| **Camera D1** | GPIO 17 | Data | Camera Data |
| **Camera D2** | GPIO 18 | Data | Camera Data |
| **IR LED** | GPIO 21 | Output | Night Vision Illumination |
| **Camera VSYNC** | GPIO 38 | Sync | Camera Vertical Sync |
| **Camera I2C** | GPIO 40 (SDA) | Data | Camera Control Bus |
| **Camera I2C** | GPIO 41 (SCL) | Clock | Camera Control Bus |
| **Camera HREF** | GPIO 47 | Sync | Camera Horizontal Reference |
| **Camera D7** | GPIO 48 | Data | Camera Data |

## System Architecture

```mermaid
graph TD
    subgraph Power
        AC[AC Mains 110/220V] --> Inlet[IEC Inlet w/ Fuse]
        Inlet --> PSU[Mean Well LRS-35-5 (5V PSU)]
        Inlet --> SSR_AC[SSR AC Load Side]
        SSR_AC --> Outlet[IEC Outlet (To Vacuum)]
        PSU --> |5V| ESP32_5V[ESP32 USB/Bat Pin]
        PSU --> |GND| ESP32_GND[ESP32 GND]
    end

    subgraph Controller
        ESP32[Adafruit ESP32-S3 Feather]
    end

    subgraph Sensors_I2C_Bus [I2C Bus A (SDA=3, SCL=4)]
        Hub[STEMMA QT Hub]
        ESP32 --> |I2C| Hub
        Hub --> ToF[VL53L4CX Distance]
        Hub --> APDS[APDS9960 Proximity]
        Hub --> BME[BME280 Env Sensor]
        Hub --> OLED[OLED Display]
        Hub --> IMU[LSM6DSOX IMU]
        Hub --> IR[STHS34PF80 IR Presence]
    end

    subgraph Camera_Module
        ESP32 --> |D0-D7, Ctrl| Cam[OV5640 Camera]
    end

    subgraph GPIO_Connections
        SSR_Ctrl[SSR Control Input] --> |GPIO5| ESP32
        Stop[Emergency Stop] --> |GPIO6| ESP32
        Btn[Reset Button] --> |GPIO9| ESP32
        LED[IR LED] --> |GPIO21| ESP32
    end

    %% Wiring Details
    PSU --> |5V| Hub
    ESP32 --> |3.3V| Stop
    ESP32 --> |3.3V| SSR_Ctrl
```

## Cable Routing Guide
- **Main Trunk**: Runs from Control Box through the top channel of the Trap Body.
- **Sensor Branch**: Splits at the Sensor Module to reach ToF (Top) and PIR (Side).
- **Power**: AC lines stay within the Control Box (Left side). DC lines (5V) run to the Feather (Right side).
