#!/usr/bin/env bash
set -euo pipefail

required=(git docker code gh)
missing=()
for cmd in "${required[@]}"; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    missing+=("$cmd")
  fi
done

if [ ${#missing[@]} -gt 0 ]; then
  echo "Missing commands: ${missing[*]}"
  exit 1
fi

echo "Workspace checks passed"
docker --version
gh --version | head -n 1
code --version | head -n 1
