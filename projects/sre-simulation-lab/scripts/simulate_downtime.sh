#!/usr/bin/env bash
# Author: Simon Parris
# Date: 2026-02-22
set -euo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"
duration="${1:-20}"

cd "$root/projects/monitoring-stack-lab"

echo "Stopping mon-app for ${duration}s (downtime simulation)..."
docker compose stop app
sleep "$duration"
docker compose start app
printf 'App restarted. Verify recovery with: %s\n' "curl http://127.0.0.1:8000/health"
