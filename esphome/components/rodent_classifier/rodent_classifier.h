#pragma once

#include "esphome/core/component.h"
#include "esphome/components/esp32_camera/esp32_camera.h"

namespace esphome {
namespace rodent_classifier {

class RodentClassifier : public Component {
 public:
  void setup() override;
  void loop() override;
  void dump_config() override;

  // Function to trigger classification
  float classify_current_frame();

 protected:
  // Placeholder for TFLite interpreter and model
  bool model_loaded_{false};
};

}  // namespace rodent_classifier
}  // namespace esphome
