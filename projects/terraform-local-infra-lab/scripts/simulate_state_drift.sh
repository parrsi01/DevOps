#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

target="runtime/dev-app-config.yaml"
if [ ! -f "$target" ]; then
  echo "Missing $target. Run init/apply first."
  exit 1
fi

echo "Simulating drift by editing Terraform-managed file: $target"
printf '\n# MANUAL_DRIFT %s\n' "$(date -u +%FT%TZ)" >> "$target"
echo "Now run: ./scripts/plan.sh"
