# ShopVac Rat Trap - Wiring Diagram

This diagram illustrates the connections between the ESP32-S3 Feather, sensors, and power components.

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

    subgraph Sensors_I2C_Bus [I2C Bus (SDA=3, SCL=4)]
        Hub[STEMMA QT Hub]
        ESP32 --> |I2C| Hub
        Hub --> ToF[VL53L0X Distance]
        Hub --> APDS[APDS9960 Proximity]
        Hub --> BME[BME280 Env Sensor]
        Hub --> OLED[OLED Display]
    end

    subgraph GPIO_Connections
        PIR[PIR Motion Sensor] --> |GPIO13| ESP32
        SSR_Ctrl[SSR Control Input] --> |GPIO5| ESP32
        Btn[Reset Button] --> |GPIO10| ESP32
    end

    %% Wiring Details
    PSU --> |5V| Hub
    ESP32 --> |3.3V| PIR
    ESP32 --> |3.3V| SSR_Ctrl
```

## Pin Mapping Table

| Component | Pin / Bus | Notes |
|-----------|-----------|-------|
| **I2C SDA** | GPIO 3 | STEMMA QT Chain |
| **I2C SCL** | GPIO 4 | STEMMA QT Chain |
| **Vacuum Relay** | GPIO 5 | Controls SSR |
| **Reset Button** | GPIO 10 | Active Low (Pull-up) |
| **PIR Sensor** | GPIO 13 | Active High |
| **Neopixel** | GPIO 33 | On-board Status LED |

## Cable Routing Guide
- **Main Trunk**: Runs from Control Box through the top channel of the Trap Body.
- **Sensor Branch**: Splits at the Sensor Module to reach ToF (Top) and PIR (Side).
- **Power**: AC lines stay within the Control Box (Left side). DC lines (5V) run to the Feather (Right side).
