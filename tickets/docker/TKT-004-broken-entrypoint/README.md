# TKT-004: Broken Entrypoint

## Scenario
Container exits immediately with an entrypoint error.

## Reproduce
```bash
cd projects/docker-production-lab
docker build -t docker-prod-lab:prod .
./scripts/simulate_broken_entrypoint.sh
```

## Debug
```bash
docker image inspect docker-prod-lab:prod --format '{{json .Config.Entrypoint}} {{json .Config.Cmd}}'
docker run --rm --entrypoint sh docker-prod-lab:prod -c 'ls -l /app && head -n 3 /app/entrypoint.sh'
```

## Root cause
Invalid entrypoint path (or missing execute bit / bad line endings in real incidents).

## Fix
Run with the correct entrypoint or rebuild image with a valid script.

## Reset
No long-running container is left behind if simulation script is used.
