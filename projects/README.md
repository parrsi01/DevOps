# Projects Index

Runnable labs and templates.

## Live Labs

- `docker-production-lab/`
  - Multi-stage Docker build
  - Non-root container
  - Health checks, restart policies, logging
  - Failure simulation scripts
- `monitoring-stack-lab/`
  - Prometheus + Grafana + Loki
  - App, container, and system metrics
  - Prebuilt dashboards (CPU, memory, request rate, error rate)
  - Repeatable spike/anomaly simulations

## CI/CD Templates

- `github-actions-ci-demo/`
  - Lint / test / build / docker verify
  - Semantic release tagging
  - Docker publish workflow (GHCR)

## Suggested Use

1. Run the Docker lab locally.
2. Practice tickets in `../tickets/docker/`.
3. Review CI/CD workflows and simulate failures in `../tickets/cicd/`.
