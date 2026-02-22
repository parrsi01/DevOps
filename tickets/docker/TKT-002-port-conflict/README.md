# TKT-002: Host Port Conflict

## Scenario
App fails to start because `8080` is already in use.

## Reproduce
```bash
cd projects/docker-production-lab
./scripts/simulate_port_conflict.sh
docker run --name app-port-conflict -p 8080:8080 docker-prod-lab:prod
```

## Debug
```bash
docker ps --format 'table {{.Names}}\t{{.Ports}}'
ss -tulpn | grep ':8080'
```

## Root cause
Another container is bound to host port `8080`.

## Fix
Stop/remove conflict or publish app on another host port (e.g. `8081:8080`).

## Reset
```bash
docker rm -f port-holder app-port-conflict
```
