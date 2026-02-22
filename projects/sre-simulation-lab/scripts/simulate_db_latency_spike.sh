#!/usr/bin/env bash
# Author: Simon Parris
# Date: 2026-02-22
set -euo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"
delay_ms="${1:-900}"
repeats="${2:-20}"

"$root/projects/monitoring-stack-lab/scripts/simulate_db_latency.sh" http://127.0.0.1:8000 "$delay_ms" "$repeats"
