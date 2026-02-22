#!/usr/bin/env bash
# Author: Simon Parris
# Date: 2026-02-22
set -euo pipefail

slo="${1:-99.9}"
period_days="${2:-30}"

python3 - <<PY
slo=float("$slo")
days=float("$period_days")
budget_pct=100.0-slo
seconds=days*24*3600*(budget_pct/100.0)
mins=int(seconds//60)
secs=int(round(seconds%60))
print(f"SLO: {slo}% over {days:g}d")
print(f"Error budget: {budget_pct:.4f}%")
print(f"Downtime budget: {mins}m {secs}s")
PY
