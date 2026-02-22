#!/usr/bin/env bash
# Author: Simon Parris
# Date: 2026-02-22
set -euo pipefail

count="${1:-30}"
if [[ ! "$count" =~ ^[0-9]+$ ]] || (( count < 1 )); then
  echo "usage: $0 [request_count]" >&2
  exit 1
fi

declare -A seen
errors=0
for _ in $(seq 1 "$count"); do
  resp="$(curl -sS -m 2 -w '\n%{http_code}' http://127.0.0.1:8088/)" || { ((errors++)); continue; }
  code="${resp##*$'\n'}"
  body="${resp%$'\n'*}"
  if [[ "$code" != "200" ]]; then
    ((errors++))
    key="http_${code}"
    seen[$key]=$(( ${seen[$key]:-0} + 1 ))
    continue
  fi
  version="$(printf '%s' "$body" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("version","unknown"))')"
  seen[$version]=$(( ${seen[$version]:-0} + 1 ))
done

echo "Requests: $count"
for key in "${!seen[@]}"; do
  printf '%s=%s\n' "$key" "${seen[$key]}"
done | sort
printf 'transport_errors=%s\n' "$errors"
