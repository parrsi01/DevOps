# TKT-001: Container Crash Loop

## Scenario
Service keeps restarting and never becomes healthy.

## Reproduce
```bash
cd projects/docker-production-lab
docker build -t docker-prod-lab:prod .
./scripts/simulate_crash_loop.sh
```

## Debug
```bash
docker ps -a --filter name=crash-loop
docker inspect -f 'status={{.State.Status}} exit={{.State.ExitCode}} restarts={{.RestartCount}}' crash-loop
docker logs crash-loop --tail 50
```

## Root cause
`CRASH_ON_START=1` makes the entrypoint exit immediately.

## Fix
Recreate container without bad env var.

## Reset
```bash
docker rm -f crash-loop
```
