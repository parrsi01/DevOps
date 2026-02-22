#!/usr/bin/env bash
# Author: Simon Parris
# Date: 2026-02-22
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

"$SCRIPT_DIR/set_canary.sh" 10
curl -sS "http://127.0.0.1:18082/control/bad?enabled=1" >/dev/null

echo "Green forced into bad mode. Sampling traffic (expect some 5xx due to canary)."
"$SCRIPT_DIR/sample_traffic.sh" 40 || true

echo "Rolling back to blue (100%)."
"$SCRIPT_DIR/rollback_to_blue.sh"
curl -sS "http://127.0.0.1:18082/control/bad?enabled=0" >/dev/null || true
