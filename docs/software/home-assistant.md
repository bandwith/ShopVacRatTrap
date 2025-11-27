# Home Assistant Integration

Complete guide for integrating your ShopVac Rat Trap with Home Assistant.

## Automatic Discovery

ESPHome devices are automatically discovered in Home Assistant when on the same network.

### Initial Setup

1. **ESPHome Add-on** (Recommended)
   - Navigate to **Settings → Add-ons → Add-on Store**
   - Install "ESPHome"
   - Click "Open Web UI"

2. **Add Device**
   - Devices automatically appear in **Settings → Integrations**
   - Click "Configure" on the discovered trap
   - Enter API encryption key from `secrets.yaml`

## Available Entities

### Sensors

| Entity ID | Description | Unit |
|-----------|-------------|------|
| `sensor.rat_trap_tof_distance` | Distance measurement | mm |
| `sensor.rat_trap_apds_proximity` | Proximity level | 0-255 |
| `sensor.rat_trap_environmental_temperature` | Ambient temp | °C |
| `sensor.rat_trap_environmental_humidity` | Humidity | % |
| `sensor.rat_trap_esp32_temperature` | Controller temp | °C |
| `sensor.rat_trap_capture_count` | Total captures | count |
| `sensor.rat_trap_wifi_signal` | Signal strength | dBm |
| `sensor.rat_trap_vacuum_runtime` | Total runtime | minutes |

### Binary Sensors

| Entity ID | Description |
|-----------|-------------|
| `binary_sensor.rat_trap_rodent_detected` | Rodent presence |
| `binary_sensor.rat_trap_trap_triggered` | Vacuum active |
| `binary_sensor.rat_trap_pir_motion` | Motion detected |
| `binary_sensor.rat_trap_apds_detection` | Proximity triggered |
| `binary_sensor.rat_trap_tof_detection` | Distance triggered |
| `binary_sensor.rat_trap_emergency_stop` | E-stop status |

### Controls (Numbers)

| Entity ID | Description | Range |
|-----------|-------------|-------|
| `number.rat_trap_detection_threshold` | ToF trigger distance | 50-500mm |
| `number.rat_trap_apds_proximity_threshold` | APDS sensitivity | 10-255 |
| `number.rat_trap_vacuum_runtime` | Vacuum duration | 1-30s |
| `number.rat_trap_cooldown_period` | Retrigger delay | 10-300s |

### Switches

| Entity ID | Description |
|-----------|-------------|
| `switch.rat_trap_system_armed` | Arm/disarm trap |
| `switch.rat_trap_manual_trigger` | Manual vacuum test |

### Buttons

| Entity ID | Description |
|-----------|-------------|
| `button.rat_trap_restart_esp32` | Restart controller |
| `button.rat_trap_run_diagnostics` | System health check |

## Dashboard Example

### Card Configuration

```yaml
type: vertical-stack
cards:
  # Status Card
  - type: entities
    title: Rat Trap Status
    entities:
      - entity: switch.rat_trap_system_armed
        name: System Armed
      - entity: binary_sensor.rat_trap_rodent_detected
        name: Rodent Detected
      - entity: binary_sensor.rat_trap_emergency_stop
        name: Emergency Stop
      - entity: sensor.rat_trap_capture_count
        name: Total Captures

  # Sensor Readings
  - type: entities
    title: Sensor Readings
    entities:
      - entity: sensor.rat_trap_tof_distance
        name: Distance
      - entity: sensor.rat_trap_apds_proximity
        name: Proximity
      - entity: binary_sensor.rat_trap_pir_motion
        name: Motion
      - entity: sensor.rat_trap_environmental_temperature
        name: Temperature

  # System Health
  - type: entities
    title: System Health
    entities:
      - entity: sensor.rat_trap_esp32_temperature
        name: ESP32 Temp
      - entity: sensor.rat_trap_wifi_signal
        name: WiFi Signal
      - entity: sensor.rat_trap_vacuum_runtime
        name: Vacuum Runtime

  # Controls
  - type: entities
    title: Configuration
    entities:
      - entity: number.rat_trap_detection_threshold
      - entity: number.rat_trap_vacuum_runtime
      - entity: number.rat_trap_cooldown_period
```

## Automations

### Basic Capture Notification

```yaml
automation:
  - alias: "Rat Trap - Capture Alert"
    description: "Notify when rodent is captured"
    trigger:
      - platform: state
        entity_id: binary_sensor.rat_trap_rodent_detected
        to: "on"
    action:
      - service: notify.mobile_app_your_phone
        data:
          title: "🐀 Rat Trap Alert"
          message: "Rodent captured at {{ now().strftime('%I:%M %p') }}"
          data:
            tag: rat_trap
            importance: high
            channel: Alerts
```

### Critical Temperature Warning

```yaml
automation:
  - alias: "Rat Trap - Temperature Warning"
    description: "Alert on high ESP32 temperature"
    trigger:
      - platform: numeric_state
        entity_id: sensor.rat_trap_esp32_temperature
        above: 75
    action:
      - service: notify.mobile_app_your_phone
        data:
          title: "⚠️ Rat Trap Warning"
          message: "ESP32 temperature is {{ states('sensor.rat_trap_esp32_temperature') }}°C"
          data:
            tag: rat_trap_warning
```

### Nightly Disarm

```yaml
automation:
  - alias: "Rat Trap - Auto Disarm at Night"
    description: "Disarm trap during sleep hours"
    trigger:
      - platform: time
        at: "23:00:00"
    action:
      - service: switch.turn_off
        target:
          entity_id: switch.rat_trap_system_armed
      - service:notify.mobile_app_your_phone
        data:
          message: "Rat trap disarmed for the night"
```

### Morning Re-arm

```yaml
automation:
  - alias: "Rat Trap - Auto Arm in Morning"
    description: "Rearm trap in the morning"
    trigger:
      - platform: time
        at: "06:00:00"
    action:
      - service: switch.turn_on
        target:
          entity_id: switch.rat_trap_system_armed
      - service: notify.mobile_app_your_phone
        data:
          message: "Rat trap armed for the day"
```

### Maintenance Reminder

```yaml
automation:
  - alias: "Rat Trap - Monthly Maintenance Reminder"
    description: "Remind to clean sensors"
    trigger:
      - platform: time
        at: "09:00:00"
    condition:
      - condition: template
        value_template: "{{ now().day == 1 }}"
    action:
      - service: notify.mobile_app_your_phone
        data:
          title: "🔧 Rat Trap Maintenance"
          message: "Time for monthly sensor cleaning and inspection"
```

### Capture Count Milestone

```yaml
automation:
  - alias: "Rat Trap - Capture Milestone"
    description: "Celebrate capture milestones"
    trigger:
      - platform: state
        entity_id: sensor.rat_trap_capture_count
    condition:
      - condition: template
        value_template: "{{ trigger.to_state.state | int % 10 == 0 }}"
    action:
      - service: notify.mobile_app_your_phone
        data:
          title: "🎉 Rat Trap Milestone"
          message: "Reached {{ states('sensor.rat_trap_capture_count') }} captures!"
```

## Advanced Features

### Camera Integration (Camera Variant)

```yaml
# configuration.yaml
camera:
  - platform: generic
    still_image_url: "http://rat-trap-ip/capture.jpg"
    name: "Rat Trap Camera"

automation:
  - alias: "Rat Trap - Capture with Photo"
    trigger:
      - platform: state
        entity_id: binary_sensor.rat_trap_rodent_detected
        to: "on"
    action:
      - service: camera.snapshot
        target:
          entity_id: camera.rat_trap_camera
        data:
          filename: "/config/www/rat_trap_{{ now().strftime('%Y%m%d_%H%M%S') }}.jpg"
      - service: notify.mobile_app_your_phone
        data:
          message: "Rodent captured - see photo"
          data:
            image: "/local/rat_trap_{{ now().strftime('%Y%m%d_%H%M%S') }}.jpg"
```

### Statistics Tracking

```yaml
# configuration.yaml
sensor:
  - platform: history_stats
    name: "Trap Triggers Today"
    entity_id: binary_sensor.rat_trap_trap_triggered
    state: "on"
    type: count
    start: "{{ now().replace(hour=0, minute=0, second=0) }}"
    end: "{{ now() }}"

  - platform: history_stats
    name: "Trap Armed Time Today"
    entity_id: switch.rat_trap_system_armed
    state: "on"
    type: time
    start: "{{ now().replace(hour=0, minute=0, second=0) }}"
    end: "{{ now() }}"
```

### Persistent Notifications

```yaml
automation:
  - alias: "Rat Trap - Persistent Capture Notification"
    trigger:
      - platform: state
        entity_id: binary_sensor.rat_trap_rodent_detected
        to: "on"
    action:
      - service: persistent_notification.create
        data:
          title: "Rat Trap Alert"
          message: "Rodent captured at {{ now().strftime('%I:%M %p on %B %d') }}"
          notification_id: "rat_trap_{{ now().timestamp() }}"
```

## Lovelace Custom Cards

### Mini Graph Card

```yaml
type: custom:mini-graph-card
entities:
  - sensor.rat_trap_tof_distance
name: Distance Sensor
hours_to_show: 24
points_per_hour: 4
line_width: 2
show:
  labels: true
  points: false
```

### Button Card

```yaml
type: custom:button-card
entity: switch.rat_trap_manual_trigger
name: Test Vacuum
icon: mdi:play-circle
tap_action:
  action: toggle
styles:
  card:
    - font-size: 16px
    - height: 100px
  icon:
    - width: 50px
```

## Node-RED Integration

Example flow for advanced automations:

```json
[
  {
    "id": "capture_flow",
    "type": "server-state-changed",
    "name": "Rodent Detected",
    "server": "home_assistant",
    "entityid": "binary_sensor.rat_trap_rodent_detected",
    "to": "on"
  }
]
```

## Troubleshooting

### Device Not Discovered

1. Check same network/VLAN
2. Verify mDNS enabled
3. Manually add integration with IP

### Entities Not Updating

1. Check ESPHome logs
2. Verify API connection
3. Restart Home Assistant integration

### Automations Not Triggering

1. Check automation conditions
2. Verify entity IDs are correct
3. Test in Developer Tools

## Related Documentation

- [ESPHome Configuration](esphome-config.md)
- [Installation Guide](installation.md)
- [Troubleshooting](../reference/troubleshooting.md)

---

**Need Help?** Join the [Home Assistant Community](https://community.home-assistant.io)
