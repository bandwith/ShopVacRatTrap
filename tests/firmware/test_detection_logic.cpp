// Host-side unit tests for the Detection module (no ESPHome needed).
//
// Build & run:
//   g++ -std=c++17 -I esphome/packages \
//       tests/firmware/test_detection_logic.cpp -o /tmp/test_detection && /tmp/test_detection
//
// The point of this test is that the 4-of-5 rule, which used to be an
// untestable YAML lambda string, now has a real test surface.

#include <cassert>
#include <cmath>
#include <iostream>

#include "detection_logic.h"

using namespace rat_trap;

static int failures = 0;
#define CHECK(cond)                                                       \
  do {                                                                    \
    if (!(cond)) {                                                        \
      std::cerr << "FAIL: " << #cond << " (line " << __LINE__ << ")\n";   \
      ++failures;                                                         \
    }                                                                     \
  } while (0)

int main() {
  // distance_in_range: exclusive window.
  CHECK(distance_in_range(150, 50, 500));
  CHECK(!distance_in_range(50, 50, 500));    // on near bound -> excluded
  CHECK(!distance_in_range(500, 50, 500));   // on far bound  -> excluded
  CHECK(!distance_in_range(40, 50, 500));
  CHECK(!distance_in_range(600, 50, 500));

  // accel_magnitude.
  CHECK(std::fabs(accel_magnitude(3, 4, 0) - 5.0f) < 1e-5);
  CHECK(std::fabs(accel_magnitude(0, 0, 12) - 12.0f) < 1e-5);

  // Scoring: 2 signals (distance + IR) -> below default quorum of 4.
  CHECK(rodent_detection_score(/*camera=*/false, /*dist=*/150, 50, 500,
                               /*ir=*/true, /*ax=*/0, /*ay=*/0, /*az=*/0,
                               /*vib=*/12.0f) == 2);

  // Scoring: distance + IR + vibration -> 3.
  CHECK(rodent_detection_score(false, 150, 50, 500, true, 0, 0, 20, 12.0f) == 3);

  // Scoring: camera + distance + IR + vibration -> 4 == quorum.
  CHECK(rodent_detection_score(true, 150, 50, 500, true, 0, 0, 20, 12.0f) == 4);
  CHECK(is_rodent_detected(true, 150, 50, 500, true, 0, 0, 20, 12.0f));

  // Just below the quorum is not a detection.
  CHECK(!is_rodent_detected(false, 150, 50, 500, true, 0, 0, 20, 12.0f));

  // Vibration threshold is honoured: magnitude exactly at threshold does not
  // count (strictly greater-than).
  CHECK(rodent_detection_score(false, 0, 50, 500, false, 0, 0, 12, 12.0f) == 0);
  CHECK(rodent_detection_score(false, 0, 50, 500, false, 0, 0, 13, 12.0f) == 1);

  // Lower quorum makes detection easier.
  CHECK(is_rodent_detected(false, 150, 50, 500, true, 0, 0, 0, 12.0f,
                           /*quorum=*/2));

  if (failures == 0) {
    std::cout << "All detection_logic tests passed.\n";
    return 0;
  }
  std::cerr << failures << " test(s) failed.\n";
  return 1;
}
