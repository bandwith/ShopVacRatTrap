#ifndef ESPHOME_DISPLAY_HELPERS_H
#define ESPHOME_DISPLAY_HELPERS_H

#include "esphome/core/component.h"
#include "esphome/components/display/display_buffer.h"
#include "esphome/components/wifi/wifi_component.h"
#include "esphome/components/text_sensor/text_sensor.h"
#include "esphome/components/binary_sensor/binary_sensor.h"
#include "esphome/components/number/number.h"
#include "esphome/components/sensor/sensor.h"

namespace esphome {
namespace display {

// Forward declarations for IDs
extern display::DisplayBuffer *display_buffer_ptr;
extern wifi::WiFiComponent *wifi_component_ptr;
extern binary_sensor::BinarySensor *trap_triggered_ptr;
extern binary_sensor::BinarySensor *emergency_stop_ptr;
extern binary_sensor::BinarySensor *system_armed_ptr;
extern number::Number *capture_count_ptr;

// Helper function to draw the common header
void draw_common_header(display::DisplayBuffer &it, int x, int y, Font *font, const char *device_name, const char *line_voltage, const char *safety_standard) {
  it.printf(x, y, font, TextAlign::TOP_LEFT, "%s %s %s", device_name, line_voltage, safety_standard);
}

// Helper function to draw WiFi status
void draw_wifi_status(display::DisplayBuffer &it, int x_connected, int x_disconnected, int y, Font *font) {
  if (wifi_component_ptr->is_connected()) {
    it.printf(x_connected, y, font, TextAlign::TOP_LEFT, "WiFi");
  } else {
    it.printf(x_disconnected, y, font, TextAlign::TOP_LEFT, "No Net");
  }
}

// Helper function to draw master trigger status
void draw_master_trigger_status(display::DisplayBuffer &it, int x, int y, Font *font, Color on_color, Color off_color) {
  if (emergency_stop_ptr->state) {
    it.filled_rectangle(x, y, 128, 12, on_color);
    it.print(2, y + 2, font, off_color, ">> EMERGENCY STOP <<");
  } else if (trap_triggered_ptr->state) {
    it.filled_rectangle(x, y, 128, 12, on_color);
    it.print(2, y + 2, font, off_color, ">> VACUUM ACTIVE <<");
  } else if (system_armed_ptr->state) {
    it.print(x, y + 2, font, TextAlign::TOP_LEFT, "Armed & Monitoring");
    it.print(120, y + 2, font, TextAlign::TOP_LEFT, "●");
  } else {
    it.print(x, y + 2, font, TextAlign::TOP_LEFT, "System Disarmed");
  }
}

// Helper function to draw capture count
void draw_capture_count(display::DisplayBuffer &it, int x, int y, Font *font) {
  it.printf(x, y, font, TextAlign::TOP_LEFT, "Captures: %.0f", capture_count_ptr->state);
}

} // namespace display
} // namespace esphome

#endif // ESPHOME_DISPLAY_HELPERS_H
