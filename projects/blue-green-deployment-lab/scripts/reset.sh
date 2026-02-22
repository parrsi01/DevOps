#!/usr/bin/env bash
# Author: Simon Parris
# Date: 2026-02-22
set -euo pipefail
source "$(dirname "$0")/common.sh"
log "Resetting stack and shared state"
dc down --remove-orphans || true
rm -f "$DATA_DIR/state.json"
set_routing 0
log "Reset complete (run ./scripts/start.sh)"
