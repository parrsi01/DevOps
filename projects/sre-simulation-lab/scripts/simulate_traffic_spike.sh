#!/usr/bin/env bash
# Author: Simon Parris
# Date: 2026-02-22
set -euo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"
duration="${1:-90}"
error_every="${2:-0}"
db_ms="${3:-20}"

"$root/projects/monitoring-stack-lab/scripts/generate_traffic.sh" http://127.0.0.1:8000 "$duration" "$error_every" "$db_ms"
