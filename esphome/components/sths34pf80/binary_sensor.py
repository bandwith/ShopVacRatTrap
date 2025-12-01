import esphome.codegen as cg
import esphome.config_validation as cv
from esphome.components import binary_sensor

sths34pf80_ns = cg.esphome_ns.namespace("sths34pf80")
STHS34PF80Component = sths34pf80_ns.class_(
    "STHS34PF80Component", cg.PollingComponent, binary_sensor.BinarySensor
)

CONFIG_SCHEMA = binary_sensor.binary_sensor_schema(
    STHS34PF80Component,
).extend(cv.polling_component_schema("200ms"))


async def to_code(config):
    var = await binary_sensor.new_binary_sensor(config)
    await cg.register_component(var, config)

    cg.add_library("https://github.com/adafruit/Adafruit_STHS34PF80.git", None)
    cg.add_library("Wire", None)
    cg.add_library("SPI", None)
