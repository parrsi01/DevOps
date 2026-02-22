#!/usr/bin/env bash
# Author: Simon Parris
# Date: 2026-02-22
set -euo pipefail
source "$(dirname "$0")/common.sh"

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <blue|green>" >&2
  exit 1
fi

case "$1" in
  blue)
    target_pct=0
    ;;
  green)
    target_pct=100
    ;;
  *)
    echo "target must be blue or green" >&2
    exit 1
    ;;
esac

log "Checking $1 health before switch"
if check_backend_health "$1" >/tmp/bg-health-check.out 2>&1; then
  cat /tmp/bg-health-check.out
  set_routing "$target_pct"
  log "Switch to $1 completed"
else
  cat /tmp/bg-health-check.out || true
  log "Switch aborted: $1 is unhealthy"
  exit 1
fi
