#!/usr/bin/env bash
set -euo pipefail
BASE_URL="${1:-http://127.0.0.1:8000}"
DELAY_MS="${2:-750}"
REPEATS="${3:-20}"

curl -sS -X POST "$BASE_URL/simulate/db-latency?delay_ms=$DELAY_MS&repeats=$REPEATS" | jq .
for _ in $(seq 1 20); do
  curl -sS "$BASE_URL/work?db_ms=$DELAY_MS" >/dev/null || true
done
printf 'DB latency simulation complete (%sms x %s).\n' "$DELAY_MS" "$REPEATS"
