#!/usr/bin/env bash
# Author: Simon Parris
# Date: 2026-02-22
set -euo pipefail

curl -fsS http://127.0.0.1:8000/health >/dev/null
curl -fsS http://127.0.0.1:8000/metrics | grep -q 'app_http_requests_total'
curl -fsS http://127.0.0.1:9090/-/ready >/dev/null
curl -fsS http://127.0.0.1:3000/api/health >/dev/null
curl -fsS http://127.0.0.1:3100/ready >/dev/null
printf 'SRE lab preflight passed (monitoring stack reachable).\n'
