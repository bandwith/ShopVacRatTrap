import esphome.codegen as cg
import esphome.config_validation as cv
from esphome.components import sensor
from esphome.const import CONF_ID

lsm6dsox_ns = cg.esphome_ns.namespace("lsm6dsox")
LSM6DSOXComponent = lsm6dsox_ns.class_("LSM6DSOXComponent", cg.PollingComponent)

CONF_ACCEL_X = "accel_x"
CONF_ACCEL_Y = "accel_y"
CONF_ACCEL_Z = "accel_z"
CONF_GYRO_X = "gyro_x"
CONF_GYRO_Y = "gyro_y"
CONF_GYRO_Z = "gyro_z"

CONFIG_SCHEMA = cv.Schema(
    {
        cv.GenerateID(): cv.declare_id(LSM6DSOXComponent),
        cv.Optional(CONF_ACCEL_X): sensor.sensor_schema(
            unit_of_measurement="m/s²", accuracy_decimals=2
        ),
        cv.Optional(CONF_ACCEL_Y): sensor.sensor_schema(
            unit_of_measurement="m/s²", accuracy_decimals=2
        ),
        cv.Optional(CONF_ACCEL_Z): sensor.sensor_schema(
            unit_of_measurement="m/s²", accuracy_decimals=2
        ),
        cv.Optional(CONF_GYRO_X): sensor.sensor_schema(
            unit_of_measurement="°/s", accuracy_decimals=2
        ),
        cv.Optional(CONF_GYRO_Y): sensor.sensor_schema(
            unit_of_measurement="°/s", accuracy_decimals=2
        ),
        cv.Optional(CONF_GYRO_Z): sensor.sensor_schema(
            unit_of_measurement="°/s", accuracy_decimals=2
        ),
    }
).extend(cv.polling_component_schema("50ms"))


async def to_code(config):
    var = cg.new_Pvariable(config[CONF_ID])
    await cg.register_component(var, config)

    # Add libraries
    cg.add_library("adafruit/Adafruit LSM6DS", "4.7.0")
    cg.add_library("adafruit/Adafruit BusIO", "1.14.1")
    cg.add_library("adafruit/Adafruit Unified Sensor", "1.1.9")
    cg.add_library("Wire", None)
    cg.add_library("SPI", None)

    if CONF_ACCEL_X in config:
        sens = await sensor.new_sensor(config[CONF_ACCEL_X])
        cg.add(var.set_accel_x(sens))
    if CONF_ACCEL_Y in config:
        sens = await sensor.new_sensor(config[CONF_ACCEL_Y])
        cg.add(var.set_accel_y(sens))
    if CONF_ACCEL_Z in config:
        sens = await sensor.new_sensor(config[CONF_ACCEL_Z])
        cg.add(var.set_accel_z(sens))

    if CONF_GYRO_X in config:
        sens = await sensor.new_sensor(config[CONF_GYRO_X])
        cg.add(var.set_gyro_x(sens))
    if CONF_GYRO_Y in config:
        sens = await sensor.new_sensor(config[CONF_GYRO_Y])
        cg.add(var.set_gyro_y(sens))
    if CONF_GYRO_Z in config:
        sens = await sensor.new_sensor(config[CONF_GYRO_Z])
        cg.add(var.set_gyro_z(sens))
