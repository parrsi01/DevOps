#!/usr/bin/env bash
set -euo pipefail


# Block 1 from 02-docker-production
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,160p' docs/docker-production-lab.md
sed -n '1,120p' projects/docker-production-lab/README.md


# Block 2 from 02-docker-production
cd /home/sp/cyber-course/projects/DevOps/projects/docker-production-lab
docker compose up -d --build
docker compose ps


# Block 3 from 02-docker-production
curl http://127.0.0.1:8080/health
docker compose logs --tail=100
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'


# Block 4 from 02-docker-production
./scripts/simulate_crash_loop.sh
docker ps -a --filter name=crash-loop
docker inspect -f 'status={{.State.Status}} exit={{.State.ExitCode}} restarts={{.RestartCount}}' crash-loop
docker logs crash-loop --tail 50


# Block 5 from 02-docker-production
docker rm -f crash-loop 2>/dev/null || true
docker compose down -v --remove-orphans

