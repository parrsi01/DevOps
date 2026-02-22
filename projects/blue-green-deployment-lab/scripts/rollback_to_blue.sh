#!/usr/bin/env bash
# Author: Simon Parris
# Date: 2026-02-22
set -euo pipefail
source "$(dirname "$0")/common.sh"
log "Rollback plan: switch traffic back to blue and verify health"
set_routing 0
check_backend_health blue >/dev/null
log "Blue rollback complete"
