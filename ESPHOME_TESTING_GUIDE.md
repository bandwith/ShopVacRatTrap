# ESPHome Firmware Testing Guide

This document provides a step-by-step guide for manually testing the ESPHome firmware and connected hardware components of the ShopVac Rat Trap 2025. Performing these tests after flashing a new firmware version is crucial to ensure all systems are operating correctly and safely.

**⚠️ Safety First:** Before proceeding, ensure the high-voltage AC components are wired correctly and safely. If you are not confident in your electrical work, do not connect the device to AC power.

## Test Environment

- **Hardware**: Fully assembled ShopVac Rat Trap with all sensors and components connected.
- **Software**: Device flashed with the latest ESPHome firmware (`rat-trap-2025.yaml` or `rat-trap-stemma-camera.yaml`).
- **Tools**:
    - A multimeter for continuity and voltage checks.
    - A small object (e.g., a piece of cardboard or your hand) to simulate a rodent.
    - Access to the Home Assistant instance connected to the device.

## Testing Checklist

### 1. Power-On and Boot Sequence

- **Test**: Connect the device to a 5V power source via the ESP32-S3's USB-C port (do not connect to AC power yet).
- **Expected Result**:
    - The OLED display should light up and show a boot screen, followed by the main status display.
    - The ESP32-S3 should connect to your WiFi network. The IP address should be visible on the OLED display and in the ESPHome logs.
    - The device should appear as "online" in your Home Assistant dashboard.

### 2. OLED Display Verification

- **Test**: Observe the OLED display.
- **Expected Result**:
    - The display should show the current system status (e.g., "Armed"), the distance reading from the ToF sensor, the capture count, and the WiFi IP address.
    - The display should be clear and free of artifacts.

### 3. Sensor Functionality Test

For these tests, you can view the live sensor readings in the ESPHome logs or the Home Assistant dashboard.

#### a. VL53L0X (Time-of-Flight) Sensor
- **Test**: Move an object (like your hand) up and down inside the trap tube, in front of the ToF sensor (located at the bottom).
- **Expected Result**:
    - The distance reading on the OLED display and in Home Assistant should change in real-time, accurately reflecting the distance to the object.

#### b. APDS9960 (Proximity) Sensor
- **Test**: Move an object towards and away from the APDS9960 sensor (located at the top of the tube).
- **Expected Result**:
    - The proximity value in Home Assistant should increase as the object gets closer.
    - The `binary_sensor.rodent_detected_proximity` entity should turn "on" when the object is close enough to cross the detection threshold.

#### c. PIR (Motion) Sensor
- **Test**: Wave your hand in front of the PIR sensor (located on the side of the tube).
- **Expected Result**:
    - The `binary_sensor.rodent_detected_motion` entity in Home Assistant should turn "on" when motion is detected and "off" after the cooldown period.

### 4. Detection Logic and SSR Trigger Test (Low Voltage)

This test verifies the "2 of 3" sensor logic without using high voltage.

- **Test**:
    1.  Place an object inside the trap tube to trigger both the APDS9960 and VL53L0X sensors simultaneously.
    2.  The object should also trigger the PIR sensor.
- **Expected Result**:
    - The `binary_sensor.rodent_detected` entity in Home Assistant should turn "on".
    - The OLED display should update to "Triggered".
    - You should hear a faint "click" from the SSR as it activates.
    - A red LED on the SSR may light up, indicating it has received the trigger signal.
    - The system should enter its cooldown state after the configured `vacuum_duration`.

### 5. Physical Controls Test

#### a. Manual Trigger Button
- **Test**: Press the large arcade button on the control box.
- **Expected Result**:
    - The SSR should activate (you'll hear a click).
    - The OLED display should show "Triggered (Manual)".
    - This test confirms the manual override is working.

#### b. Emergency Stop Button
- **Test**:
    1.  Trigger the trap using the manual trigger button.
    2.  While the SSR is active, press the Emergency Stop button.
- **Expected Result**:
    - The SSR should immediately deactivate.
    - The OLED display should show "Disabled".
    - The system should not be ableto be triggered again until the Emergency Stop is reset.

### 6. High-Voltage and Vacuum Test (Use Extreme Caution)

**⚠️ DANGER:** This test involves high voltage. Ensure all safety precautions are in place.

- **Test**:
    1.  Connect a shop vacuum to the AC outlet on the control box.
    2.  Connect the control box to a GFCI-protected AC outlet.
    3.  Trigger the trap using the manual trigger button.
- **Expected Result**:
    - The shop vacuum should turn on immediately and run for the configured `vacuum_duration`.
    - The vacuum should turn off automatically after the duration expires.
    - Pressing the Emergency Stop button during operation should immediately cut power to the vacuum.

### 7. Home Assistant Integration

- **Test**:
    1.  Trigger the trap.
    2.  Check your Home Assistant mobile app or interface.
- **Expected Result**:
    - You should receive a notification that a rodent was captured (if you have set up the example automation).
    - The state of all relevant entities (e.g., `binary_sensor.rodent_detected`, `switch.vacuum`) should be updated in real-time.
    - If using the camera variant, an image of the capture should be available in Home Assistant.

By completing this checklist, you can be confident that your ShopVac Rat Trap is fully functional and ready for deployment.
