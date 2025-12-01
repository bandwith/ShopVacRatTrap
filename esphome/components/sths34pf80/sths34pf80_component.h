#pragma once

#include "esphome.h"
#include <Wire.h>
#include <Adafruit_STHS34PF80.h>

namespace esphome {
namespace sths34pf80 {

class STHS34PF80Component : public PollingComponent, public binary_sensor::BinarySensor {
 public:
  Adafruit_STHS34PF80 sths;

  STHS34PF80Component() : PollingComponent(200) {}

  void setup() override {
    if (!sths.begin()) {
      ESP_LOGE("sths34pf80", "Failed to find STHS34PF80 chip");
      mark_failed();
      return;
    }
    sths.setMode(STHS34PF80_MODE_CONTINUOUS);
  }

  void update() override {
    // Placeholder: In real usage, read data and publish state
    // publish_state(true);
  }
};

} // namespace sths34pf80
} // namespace esphome
