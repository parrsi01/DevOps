#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
docker rm -f crash-loop >/dev/null 2>&1 || true
docker run -d --name crash-loop --restart always -e CRASH_ON_START=1 docker-prod-lab:prod
printf 'Debug with: docker ps -a --filter name=crash-loop && docker logs crash-loop\n'
