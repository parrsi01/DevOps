# Docker Production Lab Notes

## Enterprise Program Standard

This module is part of a professional infrastructure training program (not a hobby lab).

Training expectations for this module:
- production-grade design and operational assumptions (multi-AZ/region, identity, logging, recovery)
- security controls and least-privilege decisions are part of the exercise, not optional add-ons
- audit awareness: change traceability, approvals, evidence, and rollback records should be captured
- failure domain analysis must be included (process, host/node, AZ/region, dependency, control plane)
- examples are learning-safe but mapped to enterprise patterns; avoid localhost-only reasoning during analysis
- exercises are repeatable without AI by following the documented commands, checklists, and runbooks

Live project: `projects/docker-production-lab/`

Practice areas:

- Dockerfile best practices / multi-stage builds
- Non-root containers
- Image size optimization
- Volumes vs bind mounts
- Container networking / health checks / restart policies
- Logging drivers
- Failure simulations (crash loop, port conflict, permission, entrypoint, OOM)

Start baseline:

```bash
cd projects/docker-production-lab
docker compose up -d --build
curl http://127.0.0.1:8080/health
```
