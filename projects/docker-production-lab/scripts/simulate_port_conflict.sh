#!/usr/bin/env bash
set -euo pipefail
docker rm -f port-holder app-port-conflict >/dev/null 2>&1 || true
docker run -d --name port-holder -p 8080:80 nginx:alpine >/dev/null
echo 'Now run:'
echo '  docker run --name app-port-conflict -p 8080:8080 docker-prod-lab:prod'
echo 'Then debug with: docker ps --format "table {{.Names}}\\t{{.Ports}}" && ss -tulpn | grep :8080'
