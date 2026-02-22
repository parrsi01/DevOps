#!/usr/bin/env bash
# Author: Simon Parris
# Date: 2026-02-22
set -euo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"

# Combined degradation: CPU spike + DB latency + mixed traffic errors.
"$root/projects/monitoring-stack-lab/scripts/simulate_cpu_spike.sh" http://127.0.0.1:8000 30 2 >/dev/null
"$root/projects/monitoring-stack-lab/scripts/simulate_db_latency.sh" http://127.0.0.1:8000 700 10 >/dev/null
"$root/projects/monitoring-stack-lab/scripts/generate_traffic.sh" http://127.0.0.1:8000 45 5 250 >/dev/null
printf 'Service degradation simulation triggered (CPU + DB latency + intermittent errors).\n'
