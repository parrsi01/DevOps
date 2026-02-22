#!/usr/bin/env bash
# Author: Simon Parris
# Date: 2026-02-22
set -euo pipefail
source "$(dirname "$0")/common.sh"

dc ps
printf '\nRouter: '
curl -sS http://127.0.0.1:8088/router-status || true
printf '\nBlue health: '
check_backend_health blue || true
printf '\nGreen health: '
check_backend_health green || true
printf '\nShared state:\n'
curl -sS http://127.0.0.1:18081/state || true
printf '\n'
