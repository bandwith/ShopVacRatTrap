# Troubleshooting

Common issues and solutions for the ShopVac Rat Trap.

## Power Issues

### No Power to System

**Symptoms:**
- No OLED display
- ESP32 not responsive
- No LEDs illuminated

**Checks:**
1. Circuit breaker status
2. Fuse condition
3. Power supply LED indicator
4. AC input voltage

**Solutions:**
- Reset tripped circuit breaker
- Replace blown fuse
- Verify AC power at inlet
- Check power supply connections

### Intermittent Power Loss

**Symptoms:**
- Random reboots
- Display flickering
- Inconsistent behavior

**Checks:**
1. Loose AC connections
2. Undersized wire gauge
3. Poor terminal block connections
4. PSU overload

**Solutions:**
- Tighten all AC connections
- Verify 12 AWG wire used
- Clean and retighten terminals
- Check 3.3V load (should be < 250mA)

## Network Issues

### WiFi Won't Connect

**Symptoms:**
- "WiFi Disconnected" on display
- Can't ping device
- Not in Home Assistant

**Checks:**
1. SSID and password in `secrets.yaml`
2. Signal strength at location
3. 2.4GHz network (ESP32 doesn't support 5GHz)
4. Router MAC filtering

**Solutions:**
```yaml
# Verify secrets.yaml
wifi_ssid: "YourNetwork"  # Check spelling
wifi_password: "YourPassword"  # Case sensitive
```
- Move closer to router or add extender
- Disable MAC filtering or add ESP32 MAC
- Check router supports 2.4GHz

### Home Assistant Not Discovering

**Symptoms:**
- WiFi connected but no HA integration
- Can ping but not auto-discovered

**Checks:**
1. mDNS enabled on network
2. Same VLAN/subnet
3. API encryption key
4. Firewall rules

**Solutions:**
- Manually add integration with IP address
- Settings → Integrations → Add Integration → ESPHome
- Enter IP address and API key
- Check firewall allows port 6053

## Sensor Issues

### I2C Sensors Not Detected

**Symptoms:**
- "Sensor timeout" in logs
- Missing sensor readings
- I2C scan shows no devices

**Checks:**
1. STEMMA QT cable connections
2. Cable damage or pinching
3. I2C address conflicts
4. Power to sensors

**Solutions:**
```bash
# Check I2C scan in logs
esphome logs rat-trap.yaml
# Should show: 0x29, 0x39, 0x3C, 0x77
```
- Reseat all STEMMA QT connections
- Replace suspect cables
- Verify 3.3V at sensor boards
- Try sensors individually

### Erratic Distance Readings

**Symptoms:**
- VL53L0X jumps between values
- "Out of range" errors
- Readings don't match reality

**Checks:**
1. Sensor lens cleanliness
2. Mounting stability
3. Electrical interference
4. Reflective surface in view

**Solutions:**
- Clean lens with microfiber cloth
- Secure sensor mount (no vibration)
- Route I2C cables away from AC wiring
- Avoid shiny/reflective surfaces in FOV

### PIR False Triggers

**Symptoms:**
- Motion detected with no activity
- Constant triggering
- No motion when expected

**Checks:**
1. Sensitivity pot setting
2. Air currents from HVAC
3. Direct sunlight
4. Mounting location

**Solutions:**
- Adjust sensitivity potentiometer
- Shield from air vents
- Avoid windows/direct sun
- Reposition away from heat sources

## Vacuum Control Issues

### Relay Won't Trigger

**Symptoms:**
- Detection works but no vacuum
- Manual trigger doesn't activate
- SSR LED doesn't light

**Checks:**
1. Emergency stop status
2. SSR control signal (GPIO5)
3. SSR power connections
4. Optocoupler 4N35

**Solutions:**
```yaml
# Check emergency stop
binary_sensor.rat_trap_emergency_stop: should be "off"
```
- Release emergency stop button
- Verify GPIO5 shows 3.3V when triggered
- Check SSR input terminals
- Test optocoupler with multimeter

### Vacuum Runs Continuously

**Symptoms:**
- Vacuum won't turn off
- SSR stuck on
- Can't disable

**Checks:**
1. SSR failure (stuck closed)
2. Control logic error
3. Emergency stop not working

**Solutions:**
- **Immediate**: Cut power at breaker
- Replace SSR (likely failed)
- Verify firmware logic
- Test emergency stop button

## Detection Issues

### False Positives

**Symptoms:**
- Triggers with no rodent
- Environmental triggers
- Shadow/light triggers

**Checks:**
1. Detection thresholds too sensitive
2. Sensor placement
3. External interference
4. Time of day patterns

**Solutions:**
```yaml
# Adjust in Home Assistant:
number.rat_trap_detect ion_threshold: 150 → 200mm
number.rat_trap_apds_proximity_threshold: 50 → 70
```
- Increase thresholds gradually
- Shield sensors from environmental changes
- Analyze trigger patterns in HA history

### No Detection (False Negatives)

**Symptoms:**
- Rodent visible but no trigger
- Sensors work but logic doesn't fire
- "2 of 3" never satisfied

**Checks:**
1. System armed status
2. Cooldown period not expired
3. Thresholds too strict
4. Sensor alignment

**Solutions:**
- Verify `switch.rat_trap_system_armed` is "on"
- Wait for cooldown (default 30s)
- Lower detection thresholds
- Realign sensors for better coverage

## Temperature Issues

### ESP32 Overheating

**Symptoms:**
- Temperature warnings in HA
- Thermal shutdown triggered
- Hot to touch

**Checks:**
1. Enclosure ventilation
2. SSR heat dissipation
3. Ambient temperature
4. CPU load

**Solutions:**
- Add ventilation holes to enclosure
- Ensure thermal pad on SSR
- Move from direct sunlight
- Check for software loops in logs

## Software Issues

### OTA Update Fails

**Symptoms:**
- Upload times out
- "Connection refused"
- Partial upload then fail

**Checks:**
1. WiFi stability
2. Network congestion
3. Firewall/VPN
4. Insufficient memory

**Solutions:**
- Use USB fallback
```bash
esphome upload rat-trap.yaml --device /dev/ttyUSB0
```
- Temporarily disable VPN
- Compile with optimizations
- Restart ESP32 before OTA

### Logs Not Accessible

**Symptoms:**
- Can't view logs
- ESPHome dashboard can't connect
- Logs show "???" characters

**Checks:**
1. Baud rate mismatch
2. USB cable quality
3. Serial port permissions

**Solutions:**
```bash
# Linux: Add user to dialout group
sudo usermod -a -G dialout $USER
# Logout/login required

# Verify device
ls -l /dev/ttyUSB*
```

## Safety System Issues

### Emergency Stop Not Working

**Symptoms:**
- E-stop pressed but vacuum stays on
- LED doesn't change
- No response

**Checks:**
1. Button wiring
2. GPIO18 input
3. Pull-up resistor
4. Software configuration

**Solutions:**
- **Critical**: Disconnect AC power immediately
- Check button continuity
- Verify GPIO18 connection
- Test with multimeter (should show 0V when pressed)

### Current Monitoring Errors

**Symptoms:**
- "Motor overload" false alarms
- No current readings
- Erratic current values

**Checks:**
1. CT clamp orientation
2. Calibration values
3. AC wire routing
4. CT secondary connections

**Solutions:**
- Arrow on CT should point to load
- Recalibrate with known load
- Only one wire through CT opening
- Check CT output voltage (should be <1VAC)

## Getting More Help

### Log Collection

```bash
# Capture full logs
esphome logs rat-trap.yaml > debug.log 2>&1

# Check ESPHome version
esphome version

# System info
cat /etc/os-release
```

### Create GitHub Issue

Include:
1. ESPHome version
2. Hardware variant (standard/camera)
3. symptom description
4. Relevant logs
5. Configuration changes made

[:material-github: Open Issue](https://github.com/bandwith/ShopVacRatTrap/issues/new)

### Community Support

- [GitHub Discussions](https://github.com/bandwith/ShopVacRatTrap/discussions)
- [ESPHome Discord](https://discord.gg/KhAMKrd)
- [Home Assistant Community](https://community.home-assistant.io)

## Advanced Diagnostics

### Run System Diagnostics

Via Home Assistant:
```yaml
service: button.press
target:
  entity_id: button.rat_trap_run_diagnostics
```

Or ESPHome:
```bash
esphome logs rat-trap.yaml
# Watch for diagnostic output
```

### I2C Test Scan

Add temporarily to config:
```yaml
i2c:
  - id: bus_a
    sda: 3
    scl: 4
    scan: true  # Enable scanning
```

Flash and check logs for detected addresses.

---

**Still having issues?** Don't hesitate to ask for help in the community!
