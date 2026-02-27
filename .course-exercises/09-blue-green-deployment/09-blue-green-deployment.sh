#!/usr/bin/env bash
set -euo pipefail


# Block 1 from 09-blue-green-deployment
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,220p' projects/blue-green-deployment-lab/README.md


# Block 2 from 09-blue-green-deployment
cd /home/sp/cyber-course/projects/DevOps/projects/blue-green-deployment-lab
./scripts/start.sh
./scripts/status.sh
curl -s http://127.0.0.1:8088/router-status
curl -s http://127.0.0.1:8088/


# Block 3 from 09-blue-green-deployment
./scripts/set_canary.sh 10
./scripts/sample_traffic.sh 50
curl -s http://127.0.0.1:8088/router-status


# Block 4 from 09-blue-green-deployment
./scripts/simulate_bad_deployment.sh
./scripts/logs.sh app_green
./scripts/rollback_to_blue.sh
./scripts/sample_traffic.sh 30
./scripts/logs.sh nginx


# Block 5 from 09-blue-green-deployment
./scripts/stop.sh
./scripts/reset.sh

