#pragma once

#include "esphome.h"
#include <Wire.h>
#include <Adafruit_LSM6DSOX.h>

namespace esphome {
namespace lsm6dsox {

class LSM6DSOXComponent : public PollingComponent {
 public:
  Adafruit_LSM6DSOX lsm6ds;
  sensor::Sensor *accel_x{nullptr};
  sensor::Sensor *accel_y{nullptr};
  sensor::Sensor *accel_z{nullptr};
  sensor::Sensor *gyro_x{nullptr};
  sensor::Sensor *gyro_y{nullptr};
  sensor::Sensor *gyro_z{nullptr};

  LSM6DSOXComponent() : PollingComponent(50) {}

  void set_accel_x(sensor::Sensor *s) { accel_x = s; }
  void set_accel_y(sensor::Sensor *s) { accel_y = s; }
  void set_accel_z(sensor::Sensor *s) { accel_z = s; }
  void set_gyro_x(sensor::Sensor *s) { gyro_x = s; }
  void set_gyro_y(sensor::Sensor *s) { gyro_y = s; }
  void set_gyro_z(sensor::Sensor *s) { gyro_z = s; }

  void setup() override {
    if (!lsm6ds.begin_I2C()) {
      ESP_LOGE("lsm6dsox", "Failed to find LSM6DSOX chip");
      mark_failed();
      return;
    }

    lsm6ds.setAccelRange(LSM6DS_ACCEL_RANGE_4_G);
    lsm6ds.setGyroRange(LSM6DS_GYRO_RANGE_500_DPS);
    lsm6ds.setAccelDataRate(LSM6DS_RATE_104_HZ);
    lsm6ds.setGyroDataRate(LSM6DS_RATE_104_HZ);
  }

  void update() override {
    sensors_event_t accel, gyro, temp;
    lsm6ds.getEvent(&accel, &gyro, &temp);

    if (accel_x != nullptr) accel_x->publish_state(accel.acceleration.x);
    if (accel_y != nullptr) accel_y->publish_state(accel.acceleration.y);
    if (accel_z != nullptr) accel_z->publish_state(accel.acceleration.z);

    if (gyro_x != nullptr) gyro_x->publish_state(gyro.gyro.x);
    if (gyro_y != nullptr) gyro_y->publish_state(gyro.gyro.y);
    if (gyro_z != nullptr) gyro_z->publish_state(gyro.gyro.z);
  }
};

} // namespace lsm6dsox
} // namespace esphome
