import esphome.codegen as cg
import esphome.config_validation as cv
from esphome.components import binary_sensor, i2c

DEPENDENCIES = ["i2c"]

sths34pf80_ns = cg.esphome_ns.namespace("sths34pf80")
STHS34PF80Component = sths34pf80_ns.class_(
    "STHS34PF80Component",
    cg.PollingComponent,
    binary_sensor.BinarySensor,
    i2c.I2CDevice,
)

CONFIG_SCHEMA = (
    binary_sensor.binary_sensor_schema(STHS34PF80Component)
    .extend(cv.polling_component_schema("200ms"))
    .extend(i2c.i2c_device_schema(0x5A))
)


async def to_code(config):
    var = await binary_sensor.new_binary_sensor(config)
    await cg.register_component(var, config)
    await i2c.register_i2c_device(var, config)
