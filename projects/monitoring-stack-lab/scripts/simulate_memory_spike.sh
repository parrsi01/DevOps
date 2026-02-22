#!/usr/bin/env bash
set -euo pipefail
BASE_URL="${1:-http://127.0.0.1:8000}"
MB="${2:-256}"
SECONDS_ARG="${3:-30}"
curl -sS -X POST "$BASE_URL/simulate/memory?mb=$MB&seconds=$SECONDS_ARG" | jq .
