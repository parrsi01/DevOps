# TKT-005: Out Of Memory (OOMKilled)

## Scenario
Container exits with code `137` due to memory limit.

## Reproduce
```bash
cd projects/docker-production-lab
./scripts/simulate_oom.sh
```

## Debug
```bash
docker ps -a --filter name=oom-lab
docker inspect -f 'exit={{.State.ExitCode}} oom={{.State.OOMKilled}}' oom-lab
docker logs oom-lab --tail 50
docker stats --no-stream
```

## Root cause
Container cgroup memory limit is lower than process demand.

## Fix
Increase `--memory` or reduce application memory usage.

## Reset
```bash
docker rm -f oom-lab
```
