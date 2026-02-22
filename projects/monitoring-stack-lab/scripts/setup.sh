#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p runtime-logs/app
chmod 777 runtime-logs/app
printf 'Prepared runtime-logs/app with write permissions for non-root app container.\n'
