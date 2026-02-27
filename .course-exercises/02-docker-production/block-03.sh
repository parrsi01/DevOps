curl http://127.0.0.1:8080/health
docker compose logs --tail=100
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
