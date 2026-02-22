#!/usr/bin/env bash
# Author: Simon Parris
# Date: 2026-02-22
set -euo pipefail
source "$(dirname "$0")/common.sh"
log "Stopping blue/green lab stack"
dc down --remove-orphans
