./scripts/set_canary.sh 10
./scripts/sample_traffic.sh 50
curl -s http://127.0.0.1:8088/router-status
