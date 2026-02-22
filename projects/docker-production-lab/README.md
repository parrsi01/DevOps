# Docker Production Lab (Live)

This project is a repeatable Docker lab for production-style debugging.

## Run baseline app

```bash
docker compose up -d --build
curl http://127.0.0.1:8080/health
```

## Run failure simulations

```bash
./scripts/simulate_crash_loop.sh
./scripts/simulate_port_conflict.sh
./scripts/simulate_volume_permission_error.sh
./scripts/simulate_broken_entrypoint.sh
./scripts/simulate_oom.sh
```

## Reset environment

```bash
docker compose down -v --remove-orphans
docker rm -f port-holder crash-loop volume-perm broken-entry oom-lab 2>/dev/null || true
```
