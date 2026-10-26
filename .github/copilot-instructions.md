# GitHub Copilot Instructions

See [`AGENTS.md`](../AGENTS.md) for repository-wide commands, package management (`uv`), external documentation references, and conventions.

## Hardware & Safety Constraints
- Never bypass 15A AC circuit protection, galvanic isolation (`>1MΩ`), or emergency stop (`GPIO4`) overrides; see `docs/getting-started/safety.md` and `docs/hardware/electrical.md`.
- Keep total 3.3V sensor load within the ESP32-S3 regulator budget (`<= 400mA`).
- Primary ESPHome configurations are `esphome/rat-trap.yaml` and `esphome/rat-trap-stemma-camera.yaml` (shared packages in `esphome/packages/`).
