#!/usr/bin/env bash
# Author: Simon Parris
# Date: 2026-02-22
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Sending 100% traffic to green for cutover simulation"
"$SCRIPT_DIR/switch_green.sh"
"$SCRIPT_DIR/sample_traffic.sh" 20

echo "Introducing green failure"
curl -sS "http://127.0.0.1:18082/control/bad?enabled=1" >/dev/null

echo "Partial rollback: reduce green to 20% while investigating"
"$SCRIPT_DIR/set_canary.sh" 20
"$SCRIPT_DIR/sample_traffic.sh" 50 || true

echo "Full rollback to blue after confirmation"
"$SCRIPT_DIR/rollback_to_blue.sh"
curl -sS "http://127.0.0.1:18082/control/bad?enabled=0" >/dev/null || true
