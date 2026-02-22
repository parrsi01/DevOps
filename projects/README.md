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
- `terraform-local-infra-lab/`
  - Terraform local backend lab (safe, no cloud cost)
  - Variables, outputs, state, remote state demo
  - Plan/apply/destroy and idempotency practice
  - Drift/manual-change/backend-failure simulations
- `kubernetes-local-lab/`
  - Minikube/K3s local platform lab
  - Namespaces, deployments, services, ingress, config/secrets
  - HPA autoscaling, rolling updates
  - Kubernetes failure simulations + troubleshooting
- `gitops-workflow-lab/`
  - ArgoCD-based GitOps workflow (plus tool-agnostic model)
  - Kustomize base/overlays for dev/staging/prod
  - Rollback, drift, manual-change, version-mismatch simulations
  - GitOps troubleshooting guide
- `sre-simulation-lab/`
  - SLIs, SLOs, error budgets
  - Latency monitoring + alert rules
  - SRE incident simulations (degradation, latency, 5xx, partial outage, downtime)
  - Incident response + postmortem templates
- `blue-green-deployment-lab/`
  - Docker + Nginx deployment routing lab
  - Blue/green switching + canary percentage rollout
  - Health-based cutover and rollback workflow
  - Bad deploy / partial rollback / data compatibility simulations

## CI/CD Templates

- `github-actions-ci-demo/`
  - Lint / test / build / docker verify
  - Semantic release tagging
  - Docker publish workflow (GHCR)
  - DevSecOps integrations (Trivy, gitleaks, dependency scan, CodeQL)
  - Hardened Docker example + security headers checks

## Suggested Use

1. Run the Docker lab locally.
2. Practice tickets in `../tickets/docker/`.
3. Run the Terraform lab and practice state/drift debugging.
4. Run the Kubernetes local lab and practice cluster debugging.
5. Run the GitOps workflow lab and practice rollback/drift handling.
6. Run the SRE simulation lab on top of the monitoring stack.
7. Run the blue/green deployment lab and practice cutover/rollback decisions.
8. Review CI/CD + DevSecOps workflows and simulate failures in `../tickets/cicd/`.
