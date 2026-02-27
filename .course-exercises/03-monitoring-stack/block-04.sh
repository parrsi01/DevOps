./scripts/simulate_cpu_spike.sh http://127.0.0.1:8000 20 2
./scripts/generate_traffic.sh http://127.0.0.1:8000 30 0 25
docker compose logs app --tail=80
