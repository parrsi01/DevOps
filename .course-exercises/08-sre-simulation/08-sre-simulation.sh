#!/usr/bin/env bash
set -euo pipefail


# Block 1 from 08-sre-simulation
cd /home/sp/cyber-course/projects/DevOps/projects/monitoring-stack-lab
./scripts/start.sh
./scripts/smoke_test.sh
cd ../sre-simulation-lab
./scripts/preflight.sh


# Block 2 from 08-sre-simulation
sed -n '1,260p' README.md
./scripts/error_budget_calc.sh 99.9 30
./scripts/error_budget_calc.sh 99.95 30


# Block 3 from 08-sre-simulation
./scripts/simulate_traffic_spike.sh 60 0 20
./scripts/incident_snapshot.sh


# Block 4 from 08-sre-simulation
./scripts/simulate_5xx_surge.sh 80
./scripts/incident_snapshot.sh


# Block 5 from 08-sre-simulation
cd ../monitoring-stack-lab
./scripts/stop.sh

