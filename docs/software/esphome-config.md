# ESPHome Configuration

Documentation for the ESPHome firmware configuration that powers the ShopVac Rat Trap.

## Configuration Overview

The trap uses a modular package-based ESPHome configuration for maintainability and variant support.

## Configuration Variants

### Standard Configuration

**File**: [`rat-trap.yaml`](https://github.com/bandwith/ShopVacRatTrap/blob/main/esphome/rat-trap.yaml)

```yaml
packages:
  common: !include packages/common.yaml
  sensors: !include packages/sensors.yaml
  safety: !include packages/safety.yaml
  display: !include packages/display-base.yaml
  base: !include packages/rat-trap-base.yaml

substitutions:
  device_name: rat-trap
  friendly_name: ShopVac Rat Trap
```

**Includes:**
- APDS9960 proximity sensor
- VL53L0X ToF sensor
- PIR motion sensor
- BME280 environmental sensor
- OLED display
- Safety systems

### Camera Configuration

**File**: [`rat-trap-stemma-camera.yaml`](https://github.com/bandwith/ShopVacRatTrap/blob/main/esphome/rat-trap-stemma-camera.yaml)

Adds camera and IR LED support to standard configuration.

## Package Structure

### common.yaml

Core ESPHome configuration:
- WiFi setup
- API and OTA
- Web server
- ESP32-S3 platform config
- Logging

### sensors.yaml

Environmental and system monitoring:
- BME280 temperature/humidity/pressure
- ESP32 temperature monitoring
- WiFi signal strength
- Uptime tracking
- Fault monitoring

### safety.yaml

Safety-critical features:
- Emergency stop handling
- Thermal shutdown logic
- System arm/disarm
- Fault tracking

### rat-trap-base.yaml

Core trap logic:
- I2C sensor setup
- Detection algorithms
- "2 of 3" confirmation logic
- Vacuum control
- Capture counting

### display-base.yaml

OLED display configuration:
- Status screens
- Sensor readings
- System info
- Capture count

## Key Configuration Sections

### Detection Logic

The "2 of 3" sensor confirmation:

```yaml
binary_sensor:
  - platform: template
    name: "Rodent Detection Group"
    id: rodent_detection_group
    lambda: |-
      int active_sensors = 0;
      if (id(apds_detection).state) active_sensors++;
      if (id(tof_detection).state) active_sensors++;
      if (id(pir_detection).state) active_sensors++;
      return active_sensors >= 2;
```

### Configurable Thresholds

Adjustable via Home Assistant:

```yaml
number:
  - platform: template
    name: "Detection Threshold (mm)"
    id: detection_threshold
    min_value: 50
    max_value: 500
    step: 10
    initial_value: 150
```

### Safety Features

ESP32 thermal management:

```yaml
sensor:
  - platform: template
    name: "ESP32 Temperature"
    lambda: return temperatureRead();
    filters:
      - lambda: |-
          if (x > id(esp32_temp_critical_threshold).state) {
            ESP_LOGW("thermal", "CRITICAL: Initiating emergency shutdown");
            id(thermal_shutdown_button).press();
          }
          return x;
```

## Customization

### Adjusting Detection Sensitivity

Modify thresholds in `rat-trap-base.yaml`:

```yaml
number:
  - platform: template
    name: "APDS Proximity Threshold"
    id: apds_proximity_threshold
    initial_value: 50  # Adjust this value
    min_value: 10
    max_value: 255
```

### Changing Vacuum Runtime

```yaml
number:
  - platform: template
    name: "Vacuum Runtime (seconds)"
    id: vacuum_runtime
    initial_value: 8  # Adjust this value
    min_value: 1
    max_value: 30
```

### Cooldown Period

```yaml
number:
  - platform: template
    name: "Cooldown Period (seconds)"
    id: cooldown_period
    initial_value: 30  # Adjust this value
    min_value: 10
    max_value: 300
```

## GPIO Pin Reference

Critical to maintain these assignments:

```yaml
# SAFETY CRITICAL - Do not modify
GPIO5: SSR Control (via optocoupler)
GPIO18: Emergency Stop Button

# Standard assignments
GPIO3: I2C SDA (STEMMA QT)
GPIO4: I2C SCL (STEMMA QT)
GPIO13: PIR Motion Sensor
GPIO10: Reset Button
```

## I2C Configuration

Bus configuration:

```yaml
i2c:
  - id: bus_a
    sda: 3
    scl: 4
    scan: true
    frequency: 100kHz
```

**Device Addresses:**
- APDS9960: 0x39
- VL53L0X: 0x29
- BME280: 0x77
- OLED: 0x3C

## Secrets Management

Store credentials in `secrets.yaml`:

```yaml
# WiFi
wifi_ssid: "YourNetwork"
wifi_password: "YourPassword"

# OTA
ota_password: "SecurePassword"

# API
api_encryption_key: "base64-encoded-key"
```

**Generate keys:**
```bash
# OTA password
openssl rand -base64 16

# API encryption key
openssl rand -base64 32
```

## Building and Flashing

### Validate Configuration

```bash
esphome config rat-trap.yaml
```

### Compile Firmware

```bash
esphome compile rat-trap.yaml
```

### Initial Flash (USB)

```bash
esphome upload rat-trap.yaml --device /dev/ttyUSB0
```

### OTA Updates

```bash
esphome upload rat-trap.yaml --device rat-trap-ip
```

### Monitor Logs

```bash
esphome logs rat-trap.yaml
```

## Advanced Features

### Web Server

Access at `http://rat-trap-ip`:
- Real-time sensor data
- Manual controls
- System diagnostics
- Configuration changes

### Diagnostics Button

Runs system health checks:

```yaml
button:
  - platform: template
    name: "Run Diagnostics"
    on_press:
      - logger.log: "Running diagnostics..."
      - lambda: |-
          // Check sensor connectivity
          // Verify temperature
          // Log results
```

## Troubleshooting

### Compilation Errors

**Issue**: Package not found
```
Solution: Check package paths in yaml file
```

**Issue**: Unknown platform
```
Solution: Update ESPHome: pip install --upgrade esphome
```

### Runtime Issues

**Issue**: Sensors not detected
```
Solution: Check I2C scan results in logs
```

**Issue**: WiFi won't connect
```
Solution: Verify secrets.yaml credentials
```

## Related Documentation

- [Installation Guide](installation.md) - Setup and flashing
- [Testing Guide](testing.md) - Validation procedures
- [Troubleshooting](../reference/troubleshooting.md) - Common issues

## Configuration Repository

Full configuration files:

[:material-github: ESPHome Configurations](https://github.com/bandwith/ShopVacRatTrap/tree/main/esphome)
