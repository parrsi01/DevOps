#!/usr/bin/env bash
# Author: Simon Parris
# Date: 2026-02-22
set -euo pipefail

# Partial outage model: healthy root/health traffic remains, one critical path fails (5xx) and logs spike.
loops="${1:-40}"
for i in $(seq 1 "$loops"); do
  curl -sS http://127.0.0.1:8000/ >/dev/null || true
  curl -sS http://127.0.0.1:8000/health >/dev/null || true
  curl -sS "http://127.0.0.1:8000/error?code=503&msg=checkout_dependency_failure" >/dev/null || true
  if [ $((i % 5)) -eq 0 ]; then
    curl -sS -X POST "http://127.0.0.1:8000/simulate/log-anomaly?count=3&pattern=PARTIAL_OUTAGE" >/dev/null || true
  fi
done
printf 'Partial outage simulation complete (%s loops: health mostly OK, critical path failing).\n' "$loops"
