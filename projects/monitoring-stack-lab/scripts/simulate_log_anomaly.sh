#!/usr/bin/env bash
set -euo pipefail
BASE_URL="${1:-http://127.0.0.1:8000}"
COUNT="${2:-20}"
PATTERN="${3:-AUTH_FAILURE_BURST}"
curl -sS -X POST "$BASE_URL/simulate/log-anomaly?count=$COUNT&pattern=$PATTERN" | jq .
