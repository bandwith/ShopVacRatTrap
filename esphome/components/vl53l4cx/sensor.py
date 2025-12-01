import esphome.codegen as cg
import esphome.config_validation as cv
from esphome.components import sensor

vl53l4cx_ns = cg.esphome_ns.namespace("vl53l4cx")
VL53L4CXComponent = vl53l4cx_ns.class_(
    "VL53L4CXComponent", cg.PollingComponent, sensor.Sensor
)

CONFIG_SCHEMA = sensor.sensor_schema(
    VL53L4CXComponent,
    unit_of_measurement="mm",
    accuracy_decimals=0,
).extend(cv.polling_component_schema("100ms"))


async def to_code(config):
    var = await sensor.new_sensor(config)
    await cg.register_component(var, config)

    cg.add_library("https://github.com/stm32duino/VL53L4CX.git", None)
    cg.add_library("Wire", None)
