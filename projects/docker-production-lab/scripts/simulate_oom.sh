#!/usr/bin/env bash
set -euo pipefail
docker rm -f oom-lab >/dev/null 2>&1 || true
docker run -d --name oom-lab --memory 64m --memory-swap 64m python:3.12-slim \
  python -c "x=[]; [x.append('X'*1024*1024) for _ in range(200)]"
printf 'Debug with: docker inspect -f "exit={{.State.ExitCode}} oom={{.State.OOMKilled}}" oom-lab\n'
