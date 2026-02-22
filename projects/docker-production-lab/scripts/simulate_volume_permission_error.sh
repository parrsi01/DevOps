#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p hostdata-bad
sudo chown root:root hostdata-bad
sudo chmod 700 hostdata-bad
docker rm -f volume-perm >/dev/null 2>&1 || true
docker run -d --name volume-perm -e WRITE_PROBE_FILE=1 -v "$(pwd)/hostdata-bad:/data" docker-prod-lab:prod
printf 'Debug with: docker logs volume-perm && ls -ld hostdata-bad\n'
