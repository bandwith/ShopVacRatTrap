#pragma once
// Minimal host stub of esphome::Component for standalone unit tests.
namespace esphome {
class Component {
 public:
  virtual ~Component() = default;
  virtual void setup() {}
  virtual void loop() {}
  virtual void dump_config() {}
};
}  // namespace esphome
