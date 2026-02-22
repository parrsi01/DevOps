# Docker Production Lab Notes

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
