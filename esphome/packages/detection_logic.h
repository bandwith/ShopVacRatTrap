#ifndef ESPHOME_RAT_TRAP_DETECTION_LOGIC_H
#define ESPHOME_RAT_TRAP_DETECTION_LOGIC_H

#include <cmath>

// Detection module for the ShopVac Rat Trap.
//
// This header is the single home for the "4-of-5" rodent detection rule that
// previously lived as an inline C++ lambda inside sensors.yaml. Keeping the
// scoring here gives the rule a narrow, named interface and a real test
// surface: the pure functions below depend only on their arguments, so they
// can be reasoned about (and unit tested on the host) without ESPHome, the
// sensors, or the network.
//
// Thresholds are passed in as parameters rather than hard-coded as magic
// numbers, so the firmware can drive them from runtime `number:` entities.

namespace rat_trap {

// A rodent is considered "detected" when at least this many independent
// signals agree. Historically 4 of the 5 possible signals.
inline constexpr int kDefaultDetectionQuorum = 4;

// Returns true when the measured distance places an object inside the trap
// mouth, i.e. between the near and far bounds (exclusive), in millimetres.
inline bool distance_in_range(float distance_mm, float near_mm, float far_mm) {
  return distance_mm > near_mm && distance_mm < far_mm;
}

// Magnitude of the acceleration vector in m/s^2. Pulled out so the vibration
// test is explicit and testable.
inline float accel_magnitude(float ax, float ay, float az) {
  return std::sqrt(ax * ax + ay * ay + az * az);
}

// Counts how many of the independent detection signals currently agree.
//
//   camera_detected    - CV/AI result (currently a placeholder; pass false
//                         when no classifier is wired up).
//   distance_mm        - ToF distance reading, millimetres.
//   near_mm / far_mm   - inclusive window the object must fall within.
//   ir_present         - IR presence sensor (STHS34PF80) state.
//   ax, ay, az         - accelerometer axes, m/s^2.
//   vibration_threshold- accel magnitude above which vibration counts, m/s^2.
//
// Each independent signal contributes at most one to the score.
inline int rodent_detection_score(bool camera_detected, float distance_mm,
                                   float near_mm, float far_mm, bool ir_present,
                                   float ax, float ay, float az,
                                   float vibration_threshold) {
  int score = 0;

  // 1. Camera AI (placeholder until a real classifier is wired up).
  if (camera_detected) score++;

  // 2. Distance: object within the configured window.
  if (distance_in_range(distance_mm, near_mm, far_mm)) score++;

  // 3. IR presence.
  if (ir_present) score++;

  // 4. Vibration pattern (accelerometer magnitude over threshold).
  if (accel_magnitude(ax, ay, az) > vibration_threshold) score++;

  // 5. Reserved for environmental/fault corroboration (not yet counted).

  return score;
}

// Convenience predicate: true when the score meets the quorum.
inline bool is_rodent_detected(bool camera_detected, float distance_mm,
                               float near_mm, float far_mm, bool ir_present,
                               float ax, float ay, float az,
                               float vibration_threshold,
                               int quorum = kDefaultDetectionQuorum) {
  return rodent_detection_score(camera_detected, distance_mm, near_mm, far_mm,
                                ir_present, ax, ay, az, vibration_threshold) >=
         quorum;
}

}  // namespace rat_trap

#endif  // ESPHOME_RAT_TRAP_DETECTION_LOGIC_H
