./scripts/generate_traffic.sh http://127.0.0.1:8000 60 12 20
curl -s http://127.0.0.1:8000/health
docker compose logs app --tail=50
