#!/usr/bin/env bash
# Author: Simon Parris
# Date: 2026-02-22
set -euo pipefail

req=(ip ss tcpdump dig openssl curl tracepath)
missing=0
for cmd in "${req[@]}"; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "MISSING: $cmd"
    missing=1
  else
    printf 'OK: %-10s -> %s\n' "$cmd" "$(command -v "$cmd")"
  fi
done

if command -v mtr >/dev/null 2>&1; then
  echo "OK: mtr        -> $(command -v mtr)"
else
  echo "OPTIONAL: mtr"
fi

if [[ "$missing" -eq 1 ]]; then
  echo "Install missing tools before running capture exercises."
  exit 1
fi

echo "Preflight passed."
