./scripts/simulate_bad_deployment.sh
./scripts/logs.sh app_green
./scripts/rollback_to_blue.sh
./scripts/sample_traffic.sh 30
./scripts/logs.sh nginx
