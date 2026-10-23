#!/usr/bin/env bash
# Simple dev bootstrapper for ShopVacRatTrap
# - Syncs the uv-managed venv at .venv from pyproject.toml/uv.lock
#   (Python version comes from .python-version; uv downloads it if needed)
# - Activates the venv (when sourced)
# - Installs prek hooks
#
# Usage (recommended):
#   source ./start-dev.sh
#
# Set SKIP_FIRMWARE=1 to skip the ESPHome toolchain (much smaller install).
#
# If you run it without "source", it will set up the venv and deps
# but activation will only apply to the subshell. Prefer sourcing.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
cd "$REPO_ROOT"

log() { printf "[start-dev] %s\n" "$*"; }
warn() { printf "[start-dev][warn] %s\n" "$*" >&2; }

if ! command -v uv >/dev/null 2>&1; then
  warn "uv is required: https://docs.astral.sh/uv/getting-started/installation/"
  return 1 2>/dev/null || exit 1
fi

# 1) Sync dependencies (creates .venv if missing)
SYNC_ARGS=(--locked)
if [[ "${SKIP_FIRMWARE:-0}" != "1" ]]; then
  SYNC_ARGS+=(--group firmware)
fi
log "Syncing dependencies: uv sync ${SYNC_ARGS[*]}"
uv sync "${SYNC_ARGS[@]}"

# 2) Activate venv (only persists if this script is sourced)
# shellcheck disable=SC1091
source .venv/bin/activate
log "Activated venv: ${VIRTUAL_ENV:-unknown}"

# 3) Install prek hooks
log "Installing prek hooks..."
prek install || warn "prek install failed (continuing)"

# Helpful next steps
cat <<EOF

[start-dev] Ready.
- Venv: $VIRTUAL_ENV
- Python: $(python -c 'import sys; print(sys.version.split()[0])')

Tips:
- To (re)activate later: source .venv/bin/activate
- To update deps after a pull: uv sync ${SYNC_ARGS[*]}
- To run tests: uv run pytest
- To run hooks now: prek run -a

EOF

# If not sourced, warn that activation won't persist in parent shell
if [[ "${BASH_SOURCE[0]:-"$0"}" == "$0" ]]; then
  warn "You ran this script without 'source'. Venv activation won't persist."
  warn "Use: source ./start-dev.sh"
fi
