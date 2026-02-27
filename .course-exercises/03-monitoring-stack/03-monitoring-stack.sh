#!/usr/bin/env bash
set -euo pipefail


# Block 1 from 03-monitoring-stack
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,180p' projects/monitoring-stack-lab/README.md


# Block 2 from 03-monitoring-stack
cd /home/sp/cyber-course/projects/DevOps/projects/monitoring-stack-lab
./scripts/start.sh
./scripts/smoke_test.sh
docker compose ps


# Block 3 from 03-monitoring-stack
./scripts/generate_traffic.sh http://127.0.0.1:8000 60 12 20
curl -s http://127.0.0.1:8000/health
docker compose logs app --tail=50


# Block 4 from 03-monitoring-stack
./scripts/simulate_cpu_spike.sh http://127.0.0.1:8000 20 2
./scripts/generate_traffic.sh http://127.0.0.1:8000 30 0 25
docker compose logs app --tail=80


# Block 5 from 03-monitoring-stack
./scripts/stop.sh
./scripts/reset.sh

