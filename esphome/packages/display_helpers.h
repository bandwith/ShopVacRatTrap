#ifndef ESPHOME_RAT_TRAP_DISPLAY_HELPERS_H
#define ESPHOME_RAT_TRAP_DISPLAY_HELPERS_H

#include "esphome/components/display/display.h"
#include "esphome/core/color.h"

// Shared OLED drawing for the ShopVac Rat Trap.
//
// Both display variants (display-base.yaml, display-camera.yaml) previously
// inlined ~45 near-identical lines of render logic each: the header, the WiFi
// badge, the emergency/vacuum/armed/disarmed status band, and the captures/
// temperature footer were duplicated line-for-line. This header is the single
// home for those shared blocks.
//
// Design note: unlike the previous (dead) version of this file, these helpers
// take everything they need as arguments instead of reaching through global
// `extern` pointers. That keeps them pure with respect to linkage -- each
// display lambda passes its own `it`, fonts, and the resolved id() states in,
// so there is nothing to wire up and nothing to keep in sync. Only the parts
// that genuinely differ between variants (the sensor rows) stay in the lambdas.

namespace esphome {
namespace rat_trap_display {

using display::BaseFont;
using display::Display;

// Top-left title plus a right-aligned WiFi/No-Net badge.
inline void draw_header(Display &it, BaseFont *font, const char *title,
                        bool wifi_connected) {
  it.printf(0, 0, font, "%s", title);
  if (wifi_connected) {
    it.printf(105, 0, font, "WiFi");
  } else {
    it.printf(100, 0, font, "No Net");
  }
}

// The master status band at y=38: the single source of truth for how the trap
// reports emergency / vacuum-active / armed / disarmed. This is the one block
// with real branching logic, so centralising it is the main win.
inline void draw_trap_status(Display &it, BaseFont *font, bool emergency_stop,
                             bool trap_triggered, bool system_armed) {
  if (emergency_stop) {
    it.filled_rectangle(0, 38, 128, 12, COLOR_ON);
    it.print(2, 40, font, COLOR_OFF, ">> EMERGENCY STOP <<");
  } else if (trap_triggered) {
    it.filled_rectangle(0, 38, 128, 12, COLOR_ON);
    it.print(2, 40, font, COLOR_OFF, ">> VACUUM ACTIVE <<");
  } else if (system_armed) {
    it.print(0, 40, font, "Armed & Monitoring");
    it.print(120, 40, font, "●");
  } else {
    it.print(0, 40, font, "System Disarmed");
  }
}

// Footer: capture count on the left, a temperature readout on the right with
// an optional over-temperature "!" marker. The temperature source differs
// between variants (ESP32 die temp vs environmental), so the caller passes the
// value and whether it is over the warning threshold.
inline void draw_stats_footer(Display &it, BaseFont *font, float capture_count,
                              float temperature_c, bool temp_over_warning) {
  it.printf(0, 54, font, "Captures: %.0f", capture_count);
  it.printf(70, 54, font, "Temp: %.1f°C", temperature_c);
  if (temp_over_warning) {
    it.print(120, 56, font, "!");
  }
}

}  // namespace rat_trap_display
}  // namespace esphome

#endif  // ESPHOME_RAT_TRAP_DISPLAY_HELPERS_H
