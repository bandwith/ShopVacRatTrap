# Glossary

Technical terms and abbreviations used throughout the documentation.

## A

**AC (Alternating Current)** - Electrical current that periodically reverses direction. Used for mains power (120V/230V).

**APDS9960** - Proximity, ambient light, RGB, and gesture sensor used for primary detection.

**API** - Application Programming Interface. ESPHome uses an API for communication with Home Assistant.

**ASA** - Acrylonitrile Styrene Acrylate. UV-resistant 3D printing filament recommended for outdoor components.

## B

**BME280** - Environmental sensor measuring temperature, humidity, and barometric pressure.

**BOM** - Bill of Materials. Complete list of components needed for the project.

## C

**CE (Conformité Européenne)** - European safety certification marking.

**CT (Current Transformer)** - Sensor that measures AC current flow for motor protection.

## D

**DC (Direct Current)** - Electrical current flowing in one direction. Used for electronics (5V, 3.3V).

## E

**ESP32-S3** - Microcontroller from Espressif with WiFi, Bluetooth, and multiple peripherals.

**ESPHome** - Firmware platform for ESP32/ESP8266 that uses YAML configuration.

## F

**Feather** - Form factor for microcontroller boards from Adafruit with standardized pinout.

**FOV (Field of View)** - The area a sensor can detect.

## G

** GFCI (Ground Fault Circuit Interrupter)** - Safety device that cuts power when ground fault detected. Required for wet locations.

**GPIO (General Purpose Input/Output)** - Configurable pins on microcontroller for sensors and controls.

## H

**HA** - Home Assistant. Open-source home automation platform.

**Hot Swap** - Ability to connect/disconnect while powered (STEMMA QT supports this).

## I

**I2C (Inter-Integrated Circuit)** - Serial communication protocol used by sensors. Uses SDA and SCL lines.

**IEC (International Electrotechnical Commission)** - International electrical standards organization.

**IR (Infrared)** - Light beyond visible spectrum used for night vision and proximity sensing.

## J

**JST** - Japanese Solderless Terminal. Connector standard used for cables and headers.

## L

**LED (Light Emitting Diode)** - Semiconductor light source used for indicators and illumination.

## M

**MCB (Miniature Circuit Breaker)** - European term for circuit breaker.

**mDNS (Multicast DNS)** - Network protocol allowing discovery of devices by name (rat-trap.local).

**MQTT** - Message Queuing Telemetry Transport. Optional communication protocol for IoT.

## N

**NEC (National Electrical Code)** - North American electrical safety code.

**NPN** - Type of transistor configuration, commonly used in optocouplers.

## O

**OLED (Organic Light Emitting Diode)** - Display technology used for status screen.

**Optocoupler** - Electrical isolator using light to separate circuits (4N35 model used).

**OTA (Over-The-Air)** - Wireless firmware updates without USB connection.

**OV5640** - 5 megapixel camera sensor with autofocus capability.

## P

**PCB (Printed Circuit Board)** - Board supporting electronic components with conductive traces.

**PETG** - Polyethylene Terephthalate Glycol. Strong, durable 3D printing filament.

**PIR (Passive Infrared)** - Motion sensor detecting infrared radiation from warm objects.

**PLA** - Polylactic Acid. Common but not recommended 3D printing filament (not durable enough).

**PSU (Power Supply Unit)** - Converts AC mains to DC voltage for electronics.

**PWM (Pulse Width Modulation)** - Technique for varying power by rapidly switching on/off.

## Q

**Qwiic** - SparkFun's version of STEMMA QT (compatible).

## R

**RCD (Residual Current Device)** - European term for GFCI.

**RGB** - Red, Green, Blue. Color sensing capability of APDS9960.

## S

**SCL (Serial Clock)** - Clock line for I2C communication.

**SDA (Serial  Data)** - Data line for I2C communication.

**SSR (Solid State Relay)** - Electronic switch for AC loads with no moving parts.

**STEMMA** - Adafruit's solderless connector system. QT variant uses JST SH 4-pin for I2C.

**STL** - Standard Tessellation Language. 3D model file format for printing.

## T

**ToF (Time of Flight)** - Distance measurement technique using light pulse timing (VL53L0X).

**TTL (Transistor-Transistor Logic)** - Standard for digital signals (0V = low, 3.3V/5V = high).

## U

**UART (Universal Asynchronous Receiver-Transmitter)** - Serial communication protocol.

**UL (Underwriters Laboratories)** - North American product safety certification.

**USB (Universal Serial Bus)** - Standard for connecting peripherals and programming.

## V

**VL53L0X** - Time-of-Flight distance sensor with ~2m range.

**VLAN (Virtual Local Area Network)** - Network segmentation (can affect mDNS discovery).

## W

**WiFi** - Wireless networking standard (IEEE 802.11). ESP32 supports 2.4GHz only.

## Y

**YAML (YAML Ain't Markup Language)** - Human-readable data serialization format used by ESPHome.

---

## Common Abbreviations

| Abbr | Full Term |
|------|-----------|
| CB | Circuit Breaker |
| CT | Current Transformer |
| E-stop | Emergency Stop |
| GND | Ground |
| HOT | Live/Line (AC power) |
| NC | Normally Closed |
| NEC | National Electrical Code |
| NEU | Neutral (AC power) |
| NO | Normally Open |
| OTA | Over-The-Air |
| PPE | Personal Protective Equipment |
| PSU | Power Supply Unit |
| RTD | Read the Docs |
| SSH | Secure Shell |
| SSR | Solid State Relay |
| ToF | Time of Flight |
| UL | Underwriters Laboratories |
| USB | Universal Serial Bus |

## Electrical Terms

**Ampere (A)** - Unit of electrical current

**Ground/Earth** - Safety connection to prevent shock

**Hot/Live/Line** - AC power conductor

**Isolation** - Electrical separation between circuits

**Neutral** - AC return path conductor

**Ohm (Ω)** - Unit of electrical resistance

**Volt (V)** - Unit of electrical potential

**Watt (W)** - Unit of electrical power

## Sensor Terms

**Active** - Sensor emitting energy (ToF, proximity)

**Ambient** - Background condition measurement

**Calibration** - Adjustment for accurate readings

**Dead Zone** - Minimum detection distance

**Gesture** - Motion pattern recognition (APDS9960)

**Passive** - Sensor detecting existing energy (PIR)

**Proximity** - Close-range detection

**Range** - Maximum detection distance

**Sensitivity** - Minimum detectable change

**Threshold** - Trigger point for detection

---

**Note**: This glossary focuses on terms specific to this project. For general electronics terms, see online resources like [SparkFun](https://learn.sparkfun.com) or [Adafruit](https://learn.adafruit.com).
