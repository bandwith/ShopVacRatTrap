#include "rodent_classifier.h"
#include "esphome/core/log.h"

namespace esphome {
namespace rodent_classifier {

static const char *const TAG = "rodent_classifier";

void RodentClassifier::setup() {
  ESP_LOGI(TAG, "Setting up Rodent Classifier...");
  // Initialize TFLite Micro interpreter here
  // Load model from flash or SD card
  this->model_loaded_ = true; // Simulating successful load
}

void RodentClassifier::loop() {
  // Optional: Continuous classification if needed
}

void RodentClassifier::dump_config() {
  ESP_LOGCONFIG(TAG, "Rodent Classifier:");
  ESP_LOGCONFIG(TAG, "  Model Loaded: %s", this->model_loaded_ ? "YES" : "NO");
}

float RodentClassifier::classify_current_frame() {
  if (!this->model_loaded_) {
    ESP_LOGW(TAG, "Model not loaded, cannot classify");
    return 0.0f;
  }

  ESP_LOGI(TAG, "Running inference on current frame...");

  // 1. Get framebuffer from esp32_camera
  // camera_fb_t *fb = esp_camera_fb_get();
  // if (!fb) { ESP_LOGE(TAG, "Camera capture failed"); return 0.0f; }

  // 2. Preprocess image (resize, normalize)

  // 3. Run interpreter invoke

  // 4. Get results
  float confidence = 0.85f; // Dummy result

  // esp_camera_fb_return(fb);

  ESP_LOGI(TAG, "Classification result: Rodent (Confidence: %.2f)", confidence);
  return confidence;
}

}  // namespace rodent_classifier
}  // namespace esphome
