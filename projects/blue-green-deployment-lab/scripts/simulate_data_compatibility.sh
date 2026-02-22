#!/usr/bin/env bash
# Author: Simon Parris
# Date: 2026-02-22
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Reset to blue and verify baseline"
"$SCRIPT_DIR/switch_blue.sh"
curl -sS http://127.0.0.1:18081/state

echo
echo "Cut over to green and migrate schema to v2"
"$SCRIPT_DIR/switch_green.sh"
curl -sS "http://127.0.0.1:18082/control/migrate?schema=2"
echo
curl -sS http://127.0.0.1:18082/state

echo
echo "Attempt rollback to blue (expected schema incompatibility)"
if "$SCRIPT_DIR/rollback_to_blue.sh"; then
  :
fi

echo "Blue health after rollback attempt:"
curl -sS -i http://127.0.0.1:18081/health || true
echo
echo "Proxy responses after rollback (expect 500s from blue):"
"$SCRIPT_DIR/sample_traffic.sh" 10 || true

echo "Recovery option A: forward-fix by switching back to green"
"$SCRIPT_DIR/switch_green.sh"
