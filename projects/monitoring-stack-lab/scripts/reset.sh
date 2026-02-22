#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
docker compose down -v --remove-orphans
rm -f runtime-logs/app/*.log || true
