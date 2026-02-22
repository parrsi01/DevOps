#!/usr/bin/env bash
set -euo pipefail
docker rm -f broken-entry >/dev/null 2>&1 || true
docker run --name broken-entry --entrypoint /app/does-not-exist.sh docker-prod-lab:prod || true
echo 'Debug with: docker image inspect docker-prod-lab:prod --format "{{json .Config.Entrypoint}}"'
