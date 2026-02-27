docker rm -f crash-loop 2>/dev/null || true
docker compose down -v --remove-orphans
