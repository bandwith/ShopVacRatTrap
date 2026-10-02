#pragma once

#include "esphome/core/component.h"
#include "esphome/core/log.h"

namespace esphome {
namespace rodent_classifier {

static const char *const TAG = "rodent_classifier";

// Confidence returned by the placeholder implementation. Named and public so
// it is obvious -- in code and in tests -- that this is a stub, not a real
// inference result. When a model is wired up, classify_current_frame() should
// stop returning this value.
static const float PLACEHOLDER_CONFIDENCE = 0.85f;

// RodentClassifier is an explicitly-declared *hypothetical seam*: the interface
// (classify_current_frame() -> confidence in [0,1]) is the contract a future
// TFLite Micro / Grove Vision AI implementation will satisfy, but there is only
// one implementation today and it does no real inference. It is kept (rather
// than deleted) because the camera build variant is built around CV being on
// the roadmap; keeping the seam named and tested means the call sites and the
// interface already exist when a model lands.
//
// Until then this is a placeholder, and is_placeholder() says so. Nothing in
// the firmware should treat its result as a real detection: the one call site
// in cv.yaml's run_classification script is intentionally not wired into the
// trap sequence yet.
class RodentClassifier : public Component {
 public:
  void setup() override {
    ESP_LOGI(TAG, "Setting up Rodent Classifier (placeholder, no model)...");
    // A real implementation loads a TFLite Micro model from flash/SD here and
    // sets model_loaded_ accordingly. The placeholder has no model.
    this->model_loaded_ = false;
  }

  void loop() override {
    // No continuous classification in the placeholder.
  }

  void dump_config() override {
    ESP_LOGCONFIG(TAG, "Rodent Classifier (PLACEHOLDER - no model loaded):");
    ESP_LOGCONFIG(TAG, "  Model Loaded: %s", this->model_loaded_ ? "YES" : "NO");
    ESP_LOGCONFIG(TAG, "  Returns fixed placeholder confidence: %.2f",
                  PLACEHOLDER_CONFIDENCE);
  }

  // True while this is still the stub implementation (no model loaded). Lets
  // callers and tests assert they are not relying on a real result yet.
  bool is_placeholder() const { return !this->model_loaded_; }

  // Classify the current camera frame and return a rodent-confidence in [0,1].
  //
  // Placeholder behaviour: returns PLACEHOLDER_CONFIDENCE. The real pipeline
  // (grab framebuffer -> preprocess -> TFLite invoke -> read output) is the
  // work this seam is waiting for; see the roadmap notes above.
  float classify_current_frame() {
    if (this->is_placeholder()) {
      ESP_LOGW(TAG,
               "classify_current_frame() called on placeholder; returning "
               "fixed confidence %.2f (NOT a real detection)",
               PLACEHOLDER_CONFIDENCE);
      return PLACEHOLDER_CONFIDENCE;
    }

    // --- Real implementation goes here once a model is wired up ---
    // camera_fb_t *fb = esp_camera_fb_get();
    // ... preprocess, interpreter->Invoke(), read output tensor ...
    // esp_camera_fb_return(fb);
    return PLACEHOLDER_CONFIDENCE;
  }

 protected:
  // Flipped to true only by a real model-loading setup(). The placeholder
  // leaves it false so is_placeholder() is honest.
  bool model_loaded_{false};
};

}  // namespace rodent_classifier
}  // namespace esphome
