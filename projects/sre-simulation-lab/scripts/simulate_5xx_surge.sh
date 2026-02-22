#!/usr/bin/env bash
# Author: Simon Parris
# Date: 2026-02-22
set -euo pipefail

count="${1:-60}"
for _ in $(seq 1 "$count"); do
  curl -sS "http://127.0.0.1:8000/error?code=500&msg=sre_5xx_surge" >/dev/null || true
done
printf 'Generated %s synthetic 5xx responses.\n' "$count"
