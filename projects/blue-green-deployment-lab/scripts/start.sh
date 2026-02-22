#!/usr/bin/env bash
# Author: Simon Parris
# Date: 2026-02-22
set -euo pipefail
source "$(dirname "$0")/common.sh"

ensure_dirs
if [[ ! -f "$DATA_DIR/state.json" ]]; then
  cat > "$DATA_DIR/state.json" <<'JSON'
{"schema_version":1,"request_count":0,"last_writer":"bootstrap"}
JSON
fi

set_routing 0
log "Starting blue/green lab stack"
dc up -d --build
sleep 2
"$PROJECT_DIR/scripts/status.sh"
