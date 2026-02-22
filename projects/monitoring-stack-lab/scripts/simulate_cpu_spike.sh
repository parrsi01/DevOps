#!/usr/bin/env bash
set -euo pipefail
BASE_URL="${1:-http://127.0.0.1:8000}"
SECONDS_ARG="${2:-20}"
WORKERS="${3:-2}"
curl -sS -X POST "$BASE_URL/simulate/cpu?seconds=$SECONDS_ARG&workers=$WORKERS" | jq .
