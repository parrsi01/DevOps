# TKT-003: Volume Permission Error (Non-root Container)

## Scenario
Container starts but fails writing to `/data` bind mount.

## Reproduce
```bash
cd projects/docker-production-lab
docker build -t docker-prod-lab:prod .
./scripts/simulate_volume_permission_error.sh
```

## Debug
```bash
docker ps -a --filter name=volume-perm
docker logs volume-perm --tail 50
ls -ld hostdata-bad
```

## Root cause
Host directory is `root:root 700`, but container runs as UID/GID `10001`.

## Fix
```bash
sudo chown 10001:10001 hostdata-bad
sudo chmod 755 hostdata-bad
```
Or switch to a named volume.

## Reset
```bash
docker rm -f volume-perm
```
