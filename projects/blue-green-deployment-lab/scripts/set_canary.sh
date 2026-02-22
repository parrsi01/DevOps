#!/usr/bin/env bash
# Author: Simon Parris
# Date: 2026-02-22
set -euo pipefail
source "$(dirname "$0")/common.sh"
if [[ $# -ne 1 ]]; then
  echo "usage: $0 <green_percentage 0..100>" >&2
  exit 1
fi
set_routing "$1"
curl -sS http://127.0.0.1:8088/router-status || true
echo
