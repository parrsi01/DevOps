# Docker Production Lab (Live)

## Enterprise Program Standard

This module is part of a professional infrastructure training program (not a hobby lab).

Training expectations for this module:
- production-grade design and operational assumptions (multi-AZ/region, identity, logging, recovery)
- security controls and least-privilege decisions are part of the exercise, not optional add-ons
- audit awareness: change traceability, approvals, evidence, and rollback records should be captured
- failure domain analysis must be included (process, host/node, AZ/region, dependency, control plane)
- examples are learning-safe but mapped to enterprise patterns; avoid localhost-only reasoning during analysis
- exercises are repeatable without AI by following the documented commands, checklists, and runbooks

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
