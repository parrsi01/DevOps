#!/usr/bin/env bash
# Author: Simon Parris
# Date: 2026-02-22
set -euo pipefail

echo "== Time =="
date -u

echo "== App Health =="
curl -sS http://127.0.0.1:8000/health || true

echo "\n== App Metrics (selected) =="
curl -sS http://127.0.0.1:8000/metrics | rg 'app_http_requests_total|app_errors_total|app_memory_spike_active|app_cpu_spike_active' || true

echo "\n== Docker Containers =="
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | rg 'mon-|NAMES' || true

echo "\n== Recent App Logs =="
docker logs mon-app --tail 40 2>&1 || true
