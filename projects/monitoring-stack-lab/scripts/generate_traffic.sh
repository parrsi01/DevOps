#!/usr/bin/env bash
set -euo pipefail
BASE_URL="${1:-http://127.0.0.1:8000}"
DURATION_SEC="${2:-60}"
ERROR_EVERY="${3:-10}"
DB_MS="${4:-25}"

end=$((SECONDS + DURATION_SEC))
i=0
while [ "$SECONDS" -lt "$end" ]; do
  i=$((i + 1))
  curl -sS "$BASE_URL/work?db_ms=$DB_MS" >/dev/null || true
  if [ "$ERROR_EVERY" -gt 0 ] && [ $((i % ERROR_EVERY)) -eq 0 ]; then
    curl -sS "$BASE_URL/error?code=500&msg=traffic_injected" >/dev/null || true
  fi
done
printf 'Generated traffic for %ss (error_every=%s, db_ms=%s).\n' "$DURATION_SEC" "$ERROR_EVERY" "$DB_MS"
