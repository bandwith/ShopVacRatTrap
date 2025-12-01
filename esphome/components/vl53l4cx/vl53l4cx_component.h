#pragma once

#include "esphome.h"
#include <Wire.h>
#include <vl53l4cx_class.h>

namespace esphome {
namespace vl53l4cx {

class VL53L4CXComponent : public PollingComponent, public sensor::Sensor {
 public:
  VL53L4CX sensor_vl53l4cx = VL53L4CX(&Wire, XSHUT_PIN);
  const int XSHUT_PIN = -1;

  VL53L4CXComponent() : PollingComponent(100) {}

  void setup() override {
    sensor_vl53l4cx.begin();

    sensor_vl53l4cx.InitSensor(0x12);
    sensor_vl53l4cx.VL53L4CX_StartMeasurement();
  }

  void update() override {
    VL53L4CX_MultiRangingData_t results;
    uint8_t NewDataReady = 0;

    sensor_vl53l4cx.VL53L4CX_GetMeasurementDataReady(&NewDataReady);
    if (NewDataReady) {
      sensor_vl53l4cx.VL53L4CX_GetMultiRangingData(&results);
      if (results.NumberOfObjectsFound > 0) {
        if (results.RangeData[0].RangeStatus == 0) {
           publish_state(results.RangeData[0].RangeMilliMeter);
        }
      }
      sensor_vl53l4cx.VL53L4CX_ClearInterruptAndStartMeasurement();
    }
  }
};

} // namespace vl53l4cx
} // namespace esphome
