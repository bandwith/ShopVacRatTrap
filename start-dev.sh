#!/usr/bin/env bash
# Simple dev bootstrapper for ShopVacRatTrap
# - Ensures a local Python venv at .venv (prefers uv if available)
# - Activates the venv (when sourced)
# - Installs requirements (fast with uv if available)
# - Installs pre-commit hooks
#
# Usage (recommended):
#   source ./start-dev.sh
#
# If you run it without "source", it will set up the venv and deps
# but activation will only apply to the subshell. Prefer sourcing.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
cd "$REPO_ROOT"

PY_VERSION="${PY_VERSION:-3.12}"
VENV_DIR="${VENV_DIR:-.venv}"
REQUIREMENTS_FILE="${REQUIREMENTS_FILE:-requirements.txt}"

have_cmd() { command -v "$1" >/dev/null 2>&1; }

log() { printf "[start-dev] %s\n" "$*"; }
warn() { printf "[start-dev][warn] %s\n" "$*" >&2; }

# 0) If venv exists but is on Python 3.14, recreate (known build issues for some deps)
if [[ -d "$VENV_DIR" ]]; then
  EXISTING_PY_VER="$({ test -x "$VENV_DIR/bin/python" && "$VENV_DIR/bin/python" -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")' ; } 2>/dev/null || echo)"
  if [[ "$EXISTING_PY_VER" == "3.14" && "${ALLOW_PY314:-0}" != "1" ]]; then
    warn "Detected existing venv with Python 3.14; recreating with Python ${PY_VERSION} to avoid build failures (e.g., ruamel-yaml-clib)."
    rm -rf "$VENV_DIR"
  fi
fi

# 1) Create venv if missing (prefer uv)
if [[ ! -d "$VENV_DIR" ]]; then
  if have_cmd uv; then
    log "Creating venv with uv (python ${PY_VERSION})..."
    if ! uv venv --python "${PY_VERSION}" "$VENV_DIR" 2>/dev/null; then
      log "Fallback: uv venv (default python)"
      uv venv "$VENV_DIR"
    fi
  else
    warn "uv not found; falling back to python -m venv"
    if have_cmd "python${PY_VERSION}"; then
      "python${PY_VERSION}" -m venv "$VENV_DIR"
    else
      python3 -m venv "$VENV_DIR"
    fi
  fi
  log "Created venv at $VENV_DIR"
else
  log "Found existing venv at $VENV_DIR"
fi

# 2) Activate venv (only persists if this script is sourced)
# shellcheck disable=SC1090
source "$VENV_DIR/bin/activate"
log "Activated venv: ${VIRTUAL_ENV:-unknown}"

# 3) Install dependencies
if [[ -f "$REQUIREMENTS_FILE" ]]; then
  if have_cmd uv; then
    log "Installing dependencies via uv pip (from $REQUIREMENTS_FILE)..."
    uv pip install -r "$REQUIREMENTS_FILE"
  else
    log "Installing dependencies via pip (from $REQUIREMENTS_FILE)..."
    python -m pip install --upgrade pip
    pip install -r "$REQUIREMENTS_FILE"
  fi
else
  warn "No $REQUIREMENTS_FILE found; skipping dependency install"
fi

# 4) Install pre-commit hooks if available
if have_cmd pre-commit; then
  log "Installing pre-commit hooks..."
  pre-commit install || warn "pre-commit install failed (continuing)"
else
  warn "pre-commit not available; hooks not installed"
fi

# Helpful next steps
cat <<EOF

[start-dev] Ready.
- Venv: $VIRTUAL_ENV
- Python: $(python -c 'import sys; print(sys.version.split()[0])')
- uv: $(have_cmd uv && echo present || echo missing)

Tips:
- To (re)activate later: source $VENV_DIR/bin/activate
- To update deps quickly: uv pip install -r $REQUIREMENTS_FILE
- To run hooks now: pre-commit run -a

EOF

# If not sourced, warn that activation won't persist in parent shell
if [[ "${BASH_SOURCE[0]:-"$0"}" == "$0" ]]; then
  warn "You ran this script without 'source'. Venv activation won't persist."
  warn "Use: source ./start-dev.sh"
fi
