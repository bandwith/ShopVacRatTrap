# Quick Start Guide

Get your ShopVac Rat Trap up and running in 5 main steps.

## Overview

This guide assumes you have:
- Read and understood the [Safety Guidelines](safety.md)
- Reviewed the [Project Overview](overview.md)
- Basic electronics and 3D printing skills

**Estimated Time**: 2-3 weeks (including component shipping)

## Step 1: Order Components

### Purchase List

1. **Visit the Sourcing Guide**
   - Review [Component Sourcing](../hardware/sourcing.md)
   - Check current component availability
   - Note vendor links and part numbers

2. **Generate Purchase Files** (Optional)
   ```bash
   cd ShopVacRatTrap
   source .venv/bin/activate
   python .github/scripts/bom_manager.py --bom-file BOM_CONSOLIDATED.csv --generate-purchase-files
   ```

3. **Order Components**
   - **Adafruit**: Sensors, ESP32, STEMMA cables (~$82)
   - **Mouser**: Power supply, SSR, safety components (~$101)

**Budget**: ~$183 (standard) or ~$204 (camera variant)

---

## Step 2: 3D Print Parts

While waiting for components, print the trap assembly.

### Print Settings

```
Material: PETG or ASA (PLA not recommended)
Layer Height: 0.2mm
Infill: 40% Gyroid
Wall Thickness: 4mm (critical for durability)
Supports: Yes, for overhangs
```

### Parts to Print

- `trap_entrance.stl` - Entrance with sensor mounts
- `trap_body_main.stl` - Main tube body
- `vacuum_funnel.stl` - Vacuum connection
- `bait_station.stl` - Removable bait holder
- `camera_mount.stl` - Optional, for camera variant

[:material-printer-3d: 3D Models Repository](https://github.com/bandwith/ShopVacRatTrap/tree/main/3d_models)

**Print Time**: ~8-12 hours total

---

## Step 3: Assemble Hardware

### Electronics Enclosure

1. **Follow the Assembly Guide**
   - Review [Assembly Guide](../hardware/assembly.md) in detail
   - Prepare your workspace and tools
   - Follow step-by-step instructions

2. **AC Wiring** (⚠️ Safety Critical)
   ```
   - Circuit breaker installation
   - Power supply mounting
   - SSR and outlet wiring
   - Ground/earth verification
   ```

   !!! danger "Hire an Electrician"
       If you're not qualified for AC work, **stop here** and hire a licensed electrician.

3. **DC Electronics**
   ```
   - ESP32-S3 mounting
   - STEMMA QT sensor connections
   - Display and button wiring
   - Test all connections
   ```

4. **Safety Verification**
   - [ ] All AC connections secure
   - [ ] Ground continuity verified
   - [ ] Isolation test passed (\u003e1MΩ)
   - [ ] Emergency stop functional

---

## Step 4: Configure Software

### Install ESPHome

```bash
# Install ESPHome
pip install esphome

# Clone repository
git clone https://github.com/bandwith/ShopVacRatTrap.git
cd ShopVacRatTrap/esphome
```

### Configure WiFi

```bash
# Create local secrets file
cp secrets.yaml.example secrets.yaml

# Edit with your credentials
nano secrets.yaml
```

Update:
```yaml
wifi_ssid: "YourNetworkName"
wifi_password: "YourPassword"
ota_password: "YourOTAPassword"
```

### Flash Firmware

```bash
# Compile and upload via USB
esphome run rat-trap.yaml --device /dev/ttyUSB0

# Monitor logs
esphome logs rat-trap.yaml
```

**Verify:**
- WiFi connected
- I2C sensors detected
- OLED display functional
- All GPIO pins responding

[:material-file-code: Full Software Guide](../software/installation.md)

---

## Step 5: Test and Deploy

### System Testing

1. **Sensor Calibration**
   ```
   - ToF distance baseline
   - PIR motion sensitivity
   - APDS proximity threshold
   - Temperature monitoring
   ```

2. **Detection Logic**
   ```
   - Test 2-of-3 sensor confirmation
   - Verify false positive rejection
   - Check cooldown timer
   - Test emergency stop
   ```

3. **Load Testing**
   ```
   - Low power test (LED)
   - High power test (vacuum)
   - Monitor SSR temperature
   - Verify current draw
   ```

[:material-test-tube: Complete Testing Guide](../software/testing.md)

### Home Assistant Integration

1. **Add Device**
   - ESPHome auto-discovery
   - Verify all entities appear
   - Create dashboard

2. **Create Automations**
   ```yaml
   automation:
     - alias: "Trap Alert"
       trigger:
         platform: state
         entity_id: binary_sensor.rat_trap_rodent_detected
         to: 'on'
       action:
         service: notify.mobile_app
         data:
           message: "Rodent captured!"
   ```

[:material-home-automation: HA Integration Guide](../software/home-assistant.md)

### Deployment

1. **Install in Location**
   - Secure trap assembly
   - Connect vacuum
   - Position for rodent activity
   - Ensure weatherproofing if outdoors

2. **Final Checks**
   - [ ] Power on sequence correct
   - [ ] Display shows status
   - [ ] Sensors reporting
   - [ ] Vacuum triggers properly
   - [ ] Notifications working

---

## Next Steps

### Ongoing Maintenance

- **Monthly**: Clean sensors, check connections
- **Quarterly**: Test safety systems, update firmware
- **Annually**: Professional inspection, replace fuses

[:material-wrench: Maintenance Schedule](../hardware/assembly.md#maintenance)

### Optimization

- Adjust detection thresholds
- Fine-tune vacuum runtime
- Customize automations
- Add additional features

### Community

Share your build and get help:

- [GitHub Discussions](https://github.com/bandwith/ShopVacRatTrap/discussions)
- [Home Assistant Community](https://community.home-assistant.io)
- [ESPHome Discord](https://discord.gg/KhAMKrd)

---

## Troubleshooting

Having issues? Check the troubleshooting guide:

[:material-help-circle: Troubleshooting Guide](../reference/troubleshooting.md)

Common quick fixes:

| Issue | Solution |
|-------|----------|
| No WiFi | Check credentials, signal strength |
| Sensors missing | Verify I2C addresses, check cables |
| Vacuum won't trigger | Check emergency stop, SSR wiring |
| False triggers | Adjust detection thresholds |

---

**Congratulations!** Your ShopVac Rat Trap is now operational. Monitor it via Home Assistant and adjust as needed.
