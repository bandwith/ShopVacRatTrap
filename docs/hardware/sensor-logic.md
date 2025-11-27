# Sensor Logic & Placement Strategy

This document details the "Intelligent Hybrid Detection" system used in the ShopVac Rat Trap . The system employs a "2 of 3" confirmation logic to virtually eliminate false positives while ensuring reliable triggering for actual targets.

## Sensor Placement Diagram

![Sensor Placement Diagram](docs/images/sensor_placement_diagram.png)

> [!TIP]
> For physical mounting instructions, see the **[Assembly Guide](ASSEMBLY_GUIDE.md)**.

## The "2 of 3" Confirmation Logic

To trigger the trap, at least two of the three primary sensors must confirm the presence of a rodent within a specific time window.

1.  **PIR Motion Sensor (The "Wake-Up" Call)**
    *   **Role**: Wide-area detection.
    *   **Placement**: Side-mounted on the trap body.
    *   **FOV**: Wide cone (~100°).
    *   **Logic**: Detects the thermal signature of a moving animal approaching or entering the trap. This wakes the ESP32 from light sleep and activates the other sensors.

2.  **VL53L0X Time-of-Flight Sensor (The "Height" Check)**
    *   **Role**: Precise distance/presence measurement.
    *   **Placement**: Top-mounted on the trap entrance, pointing straight down.
    *   **FOV**: Narrow beam (25°).
    *   **Logic**: Measures the distance to the floor of the tube.
        *   *Empty*: Distance = Tube Diameter (e.g., 100mm).
        *   *Occupied*: Distance < Tube Diameter (e.g., 60mm).
    *   **Validation**: If the measured distance corresponds to the expected height of a rat (40-60mm), it counts as a positive detection.

3.  **APDS9960 Proximity Sensor (The "Position" Check)**
    *   **Role**: Short-range proximity and color/light detection.
    *   **Placement**: Side-mounted near the bait station.
    *   **FOV**: Short range (~10-20cm).
    *   **Logic**: Confirms the rodent is deep enough inside the trap and near the bait. It ensures the tail is likely clear of the entrance valve.

## Visual Classification (Camera Variant)

For the camera-equipped variant, a **Grove Vision AI V2** provides intelligent classification:

*   **Role**: Real-time visual classification with onboard NPU.
*   **Placement**: Mounted to view the trap interior via camera mount.
*   **Logic**: Uses 8MB PSRAM to run TinyML models (TensorFlow Lite) directly on-device.
    *   **Dimension Capture**: Captures image and estimates size.
    *   **Species Classification**: Runs YOLOv5/MobileNet models to identify target species.

## Trigger Sequence

1.  **Idle**: System in low-power mode. PIR is active.
2.  **Alert**: PIR detects motion. ESP32 wakes up. VL53L0X and APDS9960 are powered on.
3.  **Verify**:
    *   VL53L0X checks for height/presence.
    *   APDS9960 checks for proximity/position.
4.  **Confirm**: If (PIR + VL53L0X) OR (PIR + APDS9960) OR (VL53L0X + APDS9960) are positive:
    *   **TRIGGER**: Vacuum is activated.
    *   **CAPTURE**: Camera takes a photo (if equipped).
    *   **CLASSIFY**: The onboard CV pipeline analyzes the image to confirm the target.
5.  **Reset**: System waits for reset condition (time or manual).

## Visual Classification Pipeline (CV-Ready)

The system is designed to support on-device classification using **TensorFlow Lite Micro**.

1.  **Image Capture**: The OV5640 captures an 800x600 image.
2.  **Preprocessing**: The image is resized and normalized for the model.
3.  **Inference**: A custom C++ component (`rodent_classifier`) runs the TFLite interpreter.
4.  **Decision**:
    *   **Target Confirmed**: The trap remains active/triggered.
    *   **Non-Target**: (Future Logic) The trap could potentially release or notify without vacuum activation.
