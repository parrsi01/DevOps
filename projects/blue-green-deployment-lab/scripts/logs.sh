#!/usr/bin/env bash
# Author: Simon Parris
# Date: 2026-02-22
set -euo pipefail
source "$(dirname "$0")/common.sh"
service="${1:-}"
if [[ -n "$service" ]]; then
  dc logs --tail=80 "$service"
else
  dc logs --tail=80
fi
