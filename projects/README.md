# Projects Index

![Linux](https://img.shields.io/badge/Linux-Operations-FCC624?logo=linux&logoColor=black)
![Docker](https://img.shields.io/badge/Docker-Labs-2496ED?logo=docker&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Platform-326CE5?logo=kubernetes&logoColor=white)
![GitHub%20iPhone](https://img.shields.io/badge/GitHub%20iPhone-Readable-2EA043)

Runnable labs and templates.

## Section Walkthroughs (Mobile-Friendly, Ordered)

- `section-walkthroughs/README.md`
  - Plain-language DevOps definition (what type of software engineering this is)
  - Sections `1` through `16` in order
  - Full terminal commands + explanations
  - Definitions, concepts, themes, and step `1-5` process per section
  - Written for GitHub mobile / iPhone readability

## Full Section Order (1-16)

1. `section-walkthroughs/01-linux-mastery.md`
2. `section-walkthroughs/02-docker-production.md`
3. `section-walkthroughs/03-monitoring-stack.md`
4. `section-walkthroughs/04-terraform-local-infra.md`
5. `section-walkthroughs/05-kubernetes-local-platform.md`
6. `section-walkthroughs/06-gitops-workflow.md`
7. `section-walkthroughs/07-devsecops-cicd.md`
8. `section-walkthroughs/08-sre-simulation.md`
9. `section-walkthroughs/09-blue-green-deployment.md`
10. `section-walkthroughs/10-aviation-scale-incidents.md`
11. `section-walkthroughs/11-aviation-platform-architecture.md`
12. `section-walkthroughs/12-enterprise-networking.md`
13. `section-walkthroughs/13-enterprise-audit-refactor.md`
14. `section-walkthroughs/14-enterprise-devops-incidents.md`
15. `section-walkthroughs/15-github-actions-cicd.md`
16. `section-walkthroughs/16-ticket-demo-library.md`

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
- `enterprise-networking-lab/`
  - Enterprise networking capture/debug exercises
  - DNS/TLS/HTTP timeout packet capture wrappers
  - Incident evidence template and audit-oriented practice workflow

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
8. Run the enterprise networking lab and practice packet-capture-based debugging.
9. Review CI/CD + DevSecOps workflows and simulate failures in `../tickets/cicd/`.
