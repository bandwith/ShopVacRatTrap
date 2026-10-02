#pragma once

#include "esphome/core/component.h"
#include "esphome/core/log.h"
#include "esphome/components/binary_sensor/binary_sensor.h"
#include "esphome/components/i2c/i2c.h"

namespace esphome {
namespace sths34pf80 {

static const char *const TAG = "sths34pf80";

// STHS34PF80 TMOS IR presence sensor, native I2C driver (no Adafruit library).
// Register map per ST sths34pf80-pid (sths34pf80_reg.h) and AN5867.
static const uint8_t STHS34PF80_WHO_AM_I = 0x0F;
static const uint8_t STHS34PF80_CTRL1 = 0x20;
static const uint8_t STHS34PF80_FUNC_STATUS = 0x25;

static const uint8_t STHS34PF80_ID = 0xD3;  // Expected WHO_AM_I value.

// CTRL1: low nibble = ODR, bit4 = BDU (block data update).
// 0x7 = 15 Hz output data rate; BDU keeps presence output coherent.
static const uint8_t STHS34PF80_ODR_15HZ = 0x07;
static const uint8_t STHS34PF80_CTRL1_BDU = 0x10;

// FUNC_STATUS bit 2 = pres_flag (presence detected by the embedded algorithm).
static const uint8_t STHS34PF80_FUNC_STATUS_PRES_FLAG = 0x04;

class STHS34PF80Component : public PollingComponent,
                           public binary_sensor::BinarySensor,
                           public i2c::I2CDevice {
 public:
  void setup() override {
    uint8_t who = 0;
    if (!this->read_byte(STHS34PF80_WHO_AM_I, &who) || who != STHS34PF80_ID) {
      ESP_LOGE(TAG, "STHS34PF80 not found (WHO_AM_I=0x%02X, expected 0x%02X)",
               who, STHS34PF80_ID);
      this->mark_failed();
      return;
    }

    // Enable the device at 15 Hz with block data update.
    if (!this->write_byte(STHS34PF80_CTRL1,
                          STHS34PF80_CTRL1_BDU | STHS34PF80_ODR_15HZ)) {
      ESP_LOGE(TAG, "Failed to configure CTRL1");
      this->mark_failed();
      return;
    }

    ESP_LOGCONFIG(TAG, "STHS34PF80 initialised (ODR 15 Hz)");
  }

  void update() override {
    uint8_t status = 0;
    if (!this->read_byte(STHS34PF80_FUNC_STATUS, &status)) {
      ESP_LOGW(TAG, "Failed to read FUNC_STATUS");
      this->status_set_warning();
      return;
    }
    this->status_clear_warning();
    this->publish_state((status & STHS34PF80_FUNC_STATUS_PRES_FLAG) != 0);
  }

  void dump_config() override {
    ESP_LOGCONFIG(TAG, "STHS34PF80 IR Presence Sensor:");
    LOG_I2C_DEVICE(this);
    if (this->is_failed()) {
      ESP_LOGE(TAG, "  Communication failed");
    }
    LOG_UPDATE_INTERVAL(this);
  }

  float get_setup_priority() const override { return setup_priority::DATA; }
};

}  // namespace sths34pf80
}  // namespace esphome
