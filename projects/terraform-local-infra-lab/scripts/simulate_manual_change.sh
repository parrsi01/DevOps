#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

mkdir -p runtime
manual_file="runtime/manual-hotfix.txt"
cat > "$manual_file" <<MSG
This file simulates a manual out-of-band infrastructure change.
Terraform does not manage this file, so plan may show no changes.
Created at: $(date -u +%FT%TZ)
MSG

echo "Created unmanaged file: $manual_file"
echo "Now run: ./scripts/plan.sh"
echo "Expected: often no Terraform diff (manual change not tracked in state)."
