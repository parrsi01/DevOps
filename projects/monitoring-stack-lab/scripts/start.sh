#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
./scripts/setup.sh
docker compose up -d --build
printf '\nEndpoints:\n'
printf '  App:        http://127.0.0.1:8000\n'
printf '  Metrics:     http://127.0.0.1:8000/metrics\n'
printf '  Prometheus:  http://127.0.0.1:9090\n'
printf '  Grafana:     http://127.0.0.1:3000 (admin/admin)\n'
printf '  Loki API:    http://127.0.0.1:3100\n'
