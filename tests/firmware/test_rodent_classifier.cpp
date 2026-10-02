// Host-side interface pin for the RodentClassifier seam.
//
// The classifier is an explicitly-declared placeholder (hypothetical seam):
// one implementation, no real model. This test pins the interface/contract so
// it already exists when a real model is wired up, and documents that the
// current result is a known placeholder, not a real detection.
//
// Build & run (stubs out the ESPHome logging/Component headers):
//   g++ -std=c++17 -I tests/firmware/stubs \
//       -I esphome/components/rodent_classifier \
//       tests/firmware/test_rodent_classifier.cpp -o /tmp/test_rc && /tmp/test_rc

#include <cassert>
#include <iostream>

#include "rodent_classifier.h"

using namespace esphome::rodent_classifier;

static int failures = 0;
#define CHECK(cond)                                                       \
  do {                                                                    \
    if (!(cond)) {                                                        \
      std::cerr << "FAIL: " << #cond << " (line " << __LINE__ << ")\n";   \
      ++failures;                                                         \
    }                                                                     \
  } while (0)

int main() {
  RodentClassifier clf;

  // Fresh instance (setup() not called) has no model -> placeholder.
  CHECK(clf.is_placeholder());

  // After setup(), the placeholder still has no model loaded.
  clf.setup();
  CHECK(clf.is_placeholder());

  // The contract: confidence in [0,1]. The placeholder returns the clearly
  // named placeholder constant.
  float c = clf.classify_current_frame();
  CHECK(c >= 0.0f && c <= 1.0f);
  CHECK(c == PLACEHOLDER_CONFIDENCE);

  if (failures == 0) {
    std::cout << "All rodent_classifier interface tests passed.\n";
    return 0;
  }
  std::cerr << failures << " test(s) failed.\n";
  return 1;
}
