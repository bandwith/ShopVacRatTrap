# Reference Documentation

Quick reference, troubleshooting guides, frequently asked questions, and technical specifications.

## Quick Links

<div class="grid cards" markdown>

-   :material-lifebuoy:{ .lg .middle } __Troubleshooting__

    ---

    Common issues and solutions for hardware and software problems

    [:octicons-arrow-right-24: Troubleshooting](troubleshooting.md)

-   :material-frequently-asked-questions:{ .lg .middle } __FAQ__

    ---

    Frequently asked questions about the project

    [:octicons-arrow-right-24: FAQ](faq.md)

-   :material-book-alphabet:{ .lg .middle } __Glossary__

    ---

    Technical terms and abbreviations used in documentation

    [:octicons-arrow-right-24: Glossary](glossary.md)

</div>

## Quick Reference

### GPIO Pin Assignments

| GPIO | Function | Component | Safety Level |
|------|----------|-----------|--------------|
| GPIO5 | SSR Control | 4N35 Optocoupler | **CRITICAL** |
| GPIO18 | Emergency Stop | Arcade Button | **CRITICAL** |
| GPIO3 | I2C SDA | STEMMA QT Bus | Standard |
| GPIO4 | I2C SCL | STEMMA QT Bus | Standard |
| GPIO13 | PIR Motion | PIR Sensor | Standard |
| GPIO10 | Reset Button | Push Button | Standard |

### I2C Addresses

| Device | Address | Bus |
|--------|---------|-----|
| APDS9960 | 0x39 | Primary |
| VL53L0X | 0x29 | Primary |
| BME280 | 0x77 | Primary |
| OLED Display | 0x3C | Primary |
| OV5640 Camera | 0x3C | Secondary (if equipped) |

### Default Thresholds

| Parameter | Default | Range | Unit |
|-----------|---------|-------|------|
| Detection Distance | 150 | 50-500 | mm |
| APDS Proximity | 50 | 10-255 | units |
| Vacuum Runtime | 8 | 1-30 | seconds |
| Cooldown Period | 30 | 10-300 | seconds |
| Critical Temp | 85 | 70-95 | °C |
| Warning Temp | 75 | 60-85 | °C |

### Power Specifications

**AC Input:**
- North America: 120V, 60Hz, 15A circuit
- Europe: 230V, 50Hz, 10A circuit

**DC Output:**
- 5V @ 7A (Mean Well LRS-35-5)
- 3.3V @ 600mA (ESP32-S3 regulator)

**Load Calculations:**
- Standard: 99mA @ 3.3V (84% margin)
- Camera: 249mA @ 3.3V (58% margin)

### ESPHome Entities

**Sensors:**
```
sensor.rat_trap_tof_distance
sensor.rat_trap_apds_proximity
sensor.rat_trap_environmental_temperature
sensor.rat_trap_environmental_humidity
sensor.rat_trap_esp32_temperature
sensor.rat_trap_capture_count
sensor.rat_trap_wifi_signal
```

**Binary Sensors:**
```
binary_sensor.rat_trap_rodent_detected
binary_sensor.rat_trap_trap_triggered
binary_sensor.rat_trap_pir_motion
binary_sensor.rat_trap_emergency_stop
```

**Switches:**
```
switch.rat_trap_system_armed
switch.rat_trap_vacuum_relay
switch.rat_trap_manual_trigger
```

**Numbers:**
```
number.rat_trap_detection_threshold
number.rat_trap_vacuum_runtime
number.rat_trap_cooldown_period
```

### Component Vendors

| Vendor | Primary Use | Link |
|--------|-------------|------|
| Adafruit | Sensors, ESP32, cables | [adafruit.com](https://adafruit.com) |
| Mouser | Power supply, SSR, safety | [mouser.com](https://mouser.com) |
| SparkFun | Alternative sensors | [sparkfun.com](https://sparkfun.com) |
| Amazon | Generic components | [amazon.com](https://amazon.com) |

### Safety Standards

| Region | Standards | Key Requirements |
|--------|-----------|------------------|
| North America | NEC, UL | 15A breaker, 12AWG wire, GFCI |
| Europe | IEC, CE | 10A MCB, 1.5mm² wire, RCD |
| UK | BS 1363 | Part P compliance, RCD |
| Australia | AS/NZS 3112 | RCD protection mandatory |

### Support Resources

**Documentation:**
- [ESPHome](https://esphome.io) - Platform documentation
- [Home Assistant](https://home-assistant.io) - Integration guides
- [GitHub](https://github.com/bandwith/ShopVacRatTrap) - Project repository

**Community:**
- [ESPHome Discord](https://discord.gg/KhAMKrd)
- [HA Community](https://community.home-assistant.io)
- [GitHub Discussions](https://github.com/bandwith/ShopVacRatTrap/discussions)

**Professional:**
- Licensed electricians for AC work
- Local electrical inspectors for codes
- Professional installers for automation

### Error Codes

| Code | Meaning | Action |
|------|---------|--------|
| THERMAL_CRITICAL | ESP32 >85°C | Auto-shutdown, check cooling |
| SENSOR_TIMEOUT | I2C communication lost | Check cables, restart |
| SAFETY_FAULT | Emergency stop active | Clear fault, reset system |
| NETWORK_ERROR | WiFi disconnected | Check credentials, signal |

### Maintenance Schedule

**Monthly:**
- Clean sensor lenses
- Check electrical connections
- Test emergency stop
- Verify vacuum connection

**Quarterly:**
- Test circuit breaker operation
- Inspect fuse condition
- Update firmware
- Calibrate sensors

**Annually:**
- Replace fuses preventively
- Professional electrical inspection
- Deep clean all components
- Inspect 3D printed parts

### Version Command History

```bash
# Check ESPHome version
esphome version

# Update ESPHome
pip install --upgrade esphome

# Check firmware version via HA
# Look for sensor.rat_trap_esphome_version

# Git repository version
git describe --tags
```

---

## Need More Help?

- **Can't find what you're looking for?** Check the [FAQ](faq.md)
- **Having issues?** See [Troubleshooting](troubleshooting.md)
- **Want to contribute?** Visit [Contributing](../contributing/index.md)
