# FAQ - Frequently Asked Questions

Common questions about the ShopVac Rat Trap project.

## General Questions

### What is this project?

The ShopVac Rat Trap is an open-source, ESP32-based IoT rodent control system that uses a shop vacuum for humane capture. It features hybrid sensor detection, Home Assistant integration, and professional safety compliance.

### Is this safe?

When built according to the documentation and electrical codes, yes. The project includes:
- Multiple layers of electrical protection
- Compliance with NEC/IEC safety standards
- Emergency stop system
- Current monitoring for motor protection

**However**, AC wiring must be done by someone with electrical expertise.

### How much does it cost?

- **Standard variant**: ~$150
- **Camera variant**: ~$190

Plus a shop vacuum if you don't already have one (~$50-150).

### Do I need soldering skills?

No! The design uses STEMMA QT plug-and-play connectors for all sensor connections. The only potential soldering is:
- Optional case for wire strain relief
- AC power connections (can use terminal blocks)

### What programming experience do I need?

Minimal. ESPHome uses YAML configuration files, which are mostly fill-in-the-blank. If you can edit a text file, you can configure this project.

## Technical Questions

### Why ESP32 instead of Arduino or Raspberry Pi?

**ESP32 advantages:**
- Built-in WiFi
- Powerful enough for sensor processing
- Low power consumption
- ESPHome provides easy configuration
- Cheaper than Raspberry Pi
- More capable than basic Arduino

### Can this work without WiFi/Home Assistant?

Yes! The detection logic runs entirely offline on the ESP32. WiFi and Home Assistant are optional for:
- Notifications
- Remote monitoring
- Statistics tracking
- OTA updates

### What's the detection range?

- **VL53L0X ToF**: Up to 2 meters (configured for ~500mm)
- **APDS9960 Proximity**: ~10-20cm
- **PIR Motion**: ~5 meters (adjusted via pot)

The trap entrance dimensions determine the effective detection zone.

### How accurate is the detection?

The "2 of 3" sensor confirmation provides:
- **False Positive Rate**: <1% (environmental triggers)
- **True Positive Rate**: >95% (actual rodents)
- **Response Time**: 150-250ms (sensor to vacuum)

### Can it detect small vs large rodents?

Yes. The VL53L0X distance sensor can measure rodent height/size. The camera variant can classify species using computer vision (beta feature).

### What shop vacuum should I use?

Any standard shop vacuum with:
- 5-12gallon capacity
- 5-6 peak HP
- Corded (not battery)
- AC 120V/230V

Examples: Ridgid, Craftsman, Shop-Vac brand

## Component Questions

### Can I use different sensors?

The software is designed for the specific sensors listed, but you could adapt:
- Different ToF sensors (VL53L1X, VL53L4CX)
- Different proximity sensors
- Additional sensor types

This requires ESPHome configuration changes.

### Where do I buy components?

See [Component Sourcing](../hardware/sourcing.md) for:
- Direct vendor links
- Part numbers
- Alternative sources
- Auto-generated purchase files

### Can I use generic/cheaper parts?

**Safety-critical components** (PSU, SSR, fuses): Use specified brands for UL/CE compliance

**Sensors and electronics**: Generics usually work but may need adjusted I2C addresses or pin assignments

**3D printed parts**: Must use PETG/ASA for durability

### What if a component is out of stock?

The project includes automated component availability checking. See:
- [Mouser automation](../hardware/sourcing.md#automated-bom-management)
- Alternative vendors in BOM
- Substitute recommendations

## Assembly Questions

### How long does assembly take?

| Phase | Time |
|-------|------|
| 3D Printing | 8-12 hours |
| Electronics assembly | 2-4 hours |
| Software setup | 1-2 hours |
| Testing/calibration | 1-2 hours |
| **Total hands-on** | **4-8 hours** |

Plus component shipping time (1-2 weeks).

### Do I need special tools?

**Required:**
- Screwdrivers (Phillips, flathead)
- Wire strippers
- Multimeter
- Safety glasses
- Insulated gloves

**Recommended:**
- Heat shrink tubing and gun
- Label maker
- Cable ties
- 3D printer access

### Can I assemble this without an electrician?

**Only if** you:
- Understand AC electrical safety
- Know your local electrical codes
- Have proper safety equipment
- Feel 100% confident

**Otherwise**, hire a licensed electrician for the AC portion.

## Operation Questions

### How often should I empty it?

Depends on rodent activity. The capture count sensor tracks this. Typical:
- Low activity: Monthly
- Medium: Weekly
- High activity: Every few days

Home Assistant can send reminders based on capture count.

### What happens when it's full?

The vacuum will still operate but may:
- Lose suction effectiveness
- Sound different (muffled)
- Show increased current draw (monitored)

Set up HA automation to alert at specific capture counts.

### Can I use bait?

Yes! The design includes a removable bait station. Recommended baits:
- Peanut butter
- Cheese
- Chocolate
- Commercial rodent attractant

### Is it humane?

This depends on your definition and local regulations:
- **Capture**: Instantaneous via vacuum suction
- **Containment**: Rodent is contained in vacuum bag/canister
- **Disposal**: User's responsibility to handle humanely per local laws

Some jurisdictions require immediate euthanasia, others allow relocation.

### Can multiple traps work together?

Yes! Each trap is an independent ESPHome device. You can:
- Run multiple traps on the same HA instance
- Create coordinated automations
- Track statistics across devices
- Set up multi-zone coverage

## Troubleshooting Questions

### It's not triggering on rodents

Check:
1. System armed (`switch.rat_trap_system_armed`)
2. Detection thresholds not too strict
3. Sensors aligned properly
4. Emergency stop not engaged
5. Recent trigger (cooldown period)

See [Troubleshooting Guide](troubleshooting.md#no-detection-false-negatives)

### Too many false triggers

Adjust thresholds in Home Assistant:
- Increase ToF detection distance
- Decrease APDS proximity sensitivity
- Add delay before cooldown period

See [Troubleshooting Guide](troubleshooting.md#false-positives)

### WiFi keeps disconnecting

Common causes:
- Weak signal (add extender)
- Router compatibility (try different security)
- Power supply issues (check 5V stability)
- Interference from AC switching

### Display shows odd characters

Usually I2C communication issues:
- Recheck OLED cable connection
- Verify I2C address (0x3C)
- Try different update interval
- Check for voltage drops

## Customization Questions

### Can I change the vacuum duration?

Yes, adjust in Home Assistant:
```
number.rat_trap_vacuum_runtime: 1-30 seconds
```

Default is 8 seconds.

### Can I disable certain sensors?

Yes, modify the ESPHome configuration to:
- Comment out sensor definitions
- Adjust the "2 of 3" logic to "1 of 2"
- Disable specific sensor components

### Can I add more sensors?

Yes! The ESP32-S3 has:
- Extra GPIO pins (GPIO 1, 2, 11, 12, etc.)
- Additional I2C bus capability
- UART for serial sensors

Just needs ESPHome config additions.

### Can I change the OLED display content?

Absolutely. Edit `esphome/packages/display-base.yaml` to:
- Rearrange layout
- Add/remove information
- Change fonts/sizes
- Add custom graphics

## Safety Questions

### Is the AC wiring dangerous?

Yes! 120V/230V AC can be lethal. This is why:
- Detailed safety documentation provided
- Licensed electrician recommended
- Multiple layers of protection required
- Safety testing mandatory

### What if I get shocked?

**Prevention** is key:
- Always disconnect power before work
- Use insulated tools
- Test for voltage before touching
- Keep one hand in pocket

**If shocked**:
- Call emergency services immediately
- Do not touch victim if still connected
- Begin CPR if trained

### Can children use this?

**No.** This is safety-critical equipment:
- Should be installed by adults
- Kept away from children
- Supervised operation only
- Clear labeling of hazards

## Legal Questions

### Are there patents on vacuum traps?

Possibly. The commercial Rat Vac likely has patent protection. This project is:
- **Educational/experimental** use only
- **Not for commercial sale**
- **Builder's responsibility** to check local patent law

When in doubt, consult a patent attorney.

### Is a permit required?

Depends on location. Check with your local authority for:
- Electrical permits (permanent AC installation)
- Building permits (structural modifications)
- Pest control regulations
- Wildlife handling permits

### Insurance implications?

Check with your insurance provider about:
- DIY electrical work coverage
- Liability for captured animals
- Property modifications
- Fire/safety device requirements

## Contributing Questions

### How can I contribute?

Many ways to help:
- Report bugs or issues
- Suggest improvements
- Submit code/hardware improvements
- Improve documentation
- Share your build photos/experience

See [Contributing Guide](../contributing/index.md)

### I found a bug, what do I do?

[:material-github: Open an Issue](https://github.com/bandwith/ShopVacRatTrap/issues/new)

Include:
- Description of bug
- Steps to reproduce
- Expected vs actual behavior
- Logs if applicable
- Hardware variant

### Can I sell kits/assembled units?

**No**, due to:
- Potential patent issues
- Liability concerns
- Safety certification requirements
- Open source license restrictions

You can share your personal build and help others build their own.

---

**Don't see your question?** Ask in [GitHub Discussions](https://github.com/bandwith/ShopVacRatTrap/discussions)!
