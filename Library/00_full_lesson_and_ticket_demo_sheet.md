# DevOps Full Lesson and Ticket Demo Sheet (Master CLI)

Author: Simon Parris + additive Codex library extension
Date: 2026-02-23
Mode: Full CLI execution + GitHub mobile reading support

This is a single, ordered demo sheet for all DevOps lessons and all ticket styles in this repo.

Use this when you want to run the course end-to-end from the CLI and still understand what each command is proving.

## Before You Start (CLI Session Setup)

```bash
cd /home/sp/cyber-course/projects/DevOps
pwd
git status --short
```

What you are doing: confirming repository context and seeing local changes before running labs.

## Global Rule For Every Demo

1. Read the target lesson/ticket first.
2. Run the smallest verify command before changing anything.
3. Capture evidence.
4. Make one change.
5. Verify and reset.

## Lesson Demo Order (1-16)

### Lesson 1 Demo - Linux Mastery

```bash
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,120p' docs/linux-mastery-lab.md
whoami
uname -a
ss -tulpn | head -30
df -h
free -h
journalctl -n 30 --no-pager
```

What this proves: you can collect baseline host evidence before touching containers or clusters.

### Lesson 2 Demo - Docker Production Lab

```bash
cd projects/docker-production-lab
docker compose up -d --build
docker compose ps
curl http://127.0.0.1:8080/health
docker compose logs --tail=100
```

What this proves: image builds, container starts, port binds, and app health works.

Reset:

```bash
docker compose down -v --remove-orphans
```

### Lesson 3 Demo - Monitoring Stack

```bash
cd ../monitoring-stack-lab
./scripts/start.sh
./scripts/smoke_test.sh
./scripts/generate_traffic.sh http://127.0.0.1:8000 60 12 20
./scripts/simulate_cpu_spike.sh http://127.0.0.1:8000 20 2
```

What this proves: observability stack is running and can show workload/signal changes.

Reset:

```bash
./scripts/stop.sh
./scripts/reset.sh
```

### Lesson 4 Demo - Terraform Local Infrastructure

```bash
cd ../terraform-local-infra-lab
cp terraform.tfvars.example terraform.tfvars
./scripts/init.sh
./scripts/plan.sh
./scripts/apply.sh -auto-approve
terraform output
./scripts/plan.sh
```

What this proves: init/plan/apply flow works and you can check idempotency.

Reset:

```bash
./scripts/destroy.sh -auto-approve
./scripts/reset.sh
```

### Lesson 5 Demo - Kubernetes Local Platform

```bash
cd ../kubernetes-local-lab
./scripts/start_minikube.sh
./scripts/apply_base.sh
kubectl -n platform-lab get deploy,rs,pods,svc,ingress,cm,secret,hpa
curl -H 'Host: podinfo.local' http://$(minikube ip)
```

What this proves: local cluster + base workloads + ingress path work.

Cleanup (keep cluster if moving to GitOps next):

```bash
./scripts/delete_base.sh
```

### Lesson 6 Demo - GitOps Workflow

```bash
cd ../gitops-workflow-lab
./scripts/install_argocd_minikube.sh
./scripts/bootstrap_argocd_apps.sh
kubectl -n argocd get applications.argoproj.io
./scripts/render_overlay.sh dev
./scripts/render_overlay.sh prod
./scripts/show_version_matrix.sh
```

What this proves: ArgoCD apps exist and overlay rendering/version mapping can be inspected before sync troubleshooting.

Drift demo:

```bash
./scripts/simulate_config_drift.sh
kubectl -n platform-prod scale deploy/podinfo --replicas=7
kubectl -n argocd get applications.argoproj.io podinfo-prod
```

What this proves: manual drift is visible to GitOps reconciliation.

### Lesson 7 Demo - DevSecOps CI/CD

```bash
cd ../github-actions-ci-demo
ls .github/workflows
rg -n 'trivy|gitleaks|codeql|audit|dependency-review' .github/workflows/*.yml
ls examples/secure-nginx
sed -n '1,160p' examples/secure-nginx/Dockerfile
sed -n '1,160p' examples/secure-nginx/Dockerfile.insecure
```

What this proves: you can map security controls to real workflows and compare hardened vs insecure examples.

### Lesson 8 Demo - SRE Simulation

```bash
cd ../monitoring-stack-lab
./scripts/start.sh
./scripts/smoke_test.sh
cd ../sre-simulation-lab
./scripts/preflight.sh
./scripts/error_budget_calc.sh 99.9 30
./scripts/simulate_5xx_surge.sh 80
./scripts/incident_snapshot.sh
```

What this proves: reliability math + incident evidence workflow are working against the monitoring dependency.

### Lesson 9 Demo - Blue/Green Deployment

```bash
cd ../blue-green-deployment-lab
./scripts/start.sh
./scripts/status.sh
./scripts/set_canary.sh 10
./scripts/sample_traffic.sh 50
./scripts/simulate_bad_deployment.sh
./scripts/rollback_to_blue.sh
```

What this proves: canary routing, bad deploy simulation, and rollback workflow all function.

Reset:

```bash
./scripts/stop.sh
./scripts/reset.sh
```

### Lesson 10 Demo - Aviation-Scale Incidents (Reading + Analysis Demo)

```bash
cd /home/sp/cyber-course/projects/DevOps
rg -n '^## Scenario ' docs/aviation-scale-devops-incidents-lab.md
sed -n '39,120p' docs/aviation-scale-devops-incidents-lab.md
sed -n '59,170p' docs/aviation-scale-devops-incidents-lab.md
```

What this proves: you can use the reusable cross-layer workflow and analyze a full scenario from the CLI.

### Lesson 11 Demo - Aviation Platform Architecture (Reading + Review Demo)

```bash
rg -n '^## ' docs/aviation-platform-architecture.md
sed -n '35,140p' docs/aviation-platform-architecture.md
sed -n '255,370p' docs/aviation-platform-architecture.md
sed -n '370,520p' docs/aviation-platform-architecture.md
```

What this proves: you can read architecture as operations design (traffic path, failure domains, security, scaling, cost).

### Lesson 12 Demo - Enterprise Networking

```bash
cd projects/enterprise-networking-lab
./scripts/preflight.sh
./scripts/capture_dns_path.sh api.company.aero eth0
./scripts/capture_tls_handshake.sh api.company.aero 443 eth0
./scripts/capture_http_timeout.sh api.company.aero 443 eth0
```

What this proves: you can generate layered troubleshooting command recipes (DNS/TLS/HTTP timeout) for real investigations.

### Lesson 13 Demo - Enterprise Audit and Refactor Program

```bash
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,120p' docs/enterprise-infrastructure-audit-refactor-program.md
sed -n '102,236p' docs/enterprise-infrastructure-audit-refactor-program.md
sed -n '640,760p' docs/enterprise-infrastructure-audit-refactor-program.md
```

What this proves: you can convert lab maturity gaps into a standards-based remediation plan.

### Lesson 14 Demo - Enterprise DevOps Incidents

```bash
sed -n '1,90p' docs/enterprise-devops-incidents-lab.md
rg -n '^## (1[0-5]|[1-9])\.' docs/enterprise-devops-incidents-lab.md
sed -n '42,104p' docs/enterprise-devops-incidents-lab.md
sed -n '506,560p' docs/enterprise-devops-incidents-lab.md
```

What this proves: you can apply a repeatable triage workflow to realistic enterprise incident scenarios.

### Lesson 15 Demo - GitHub Actions CI/CD Lab

```bash
sed -n '1,220p' docs/github-actions-cicd-lab.md
cd projects/github-actions-ci-demo
ls .github/workflows
cat package.json
npm run lint
npm run build
```

What this proves: you can map CI/CD stages and locally reproduce simple pipeline stages.

### Lesson 16 Demo - Ticket Demo Library

```bash
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,220p' tickets/README.md
ls -1 tickets/docker
ls -1 tickets/cicd
```

What this proves: you can select and sequence repeatable incident drills by category.

## Ticket Demo Coverage (All Ticket Styles)

### Docker Ticket Demos (`tickets/docker/`)

#### TKT-001 Crash Loop

```bash
cd /home/sp/cyber-course/projects/DevOps/projects/docker-production-lab
docker build -t docker-prod-lab:prod .
./scripts/simulate_crash_loop.sh
docker ps -a --filter name=crash-loop
docker inspect -f 'status={{.State.Status}} exit={{.State.ExitCode}} restarts={{.RestartCount}}' crash-loop
docker logs crash-loop --tail 50
docker rm -f crash-loop
```

What this teaches: startup exit loops and evidence collection via `inspect` + `logs`.

#### TKT-002 Port Conflict

```bash
cd /home/sp/cyber-course/projects/DevOps/projects/docker-production-lab
./scripts/simulate_port_conflict.sh
docker run --name app-port-conflict -p 8080:8080 docker-prod-lab:prod
docker ps --format 'table {{.Names}}\t{{.Ports}}'
ss -tulpn | rg ':8080|:80' || true
docker rm -f port-holder app-port-conflict
```

What this teaches: host port binding collisions and verification using container port maps plus socket state.

#### TKT-003 Volume Permission Error

```bash
cd /home/sp/cyber-course/projects/DevOps/projects/docker-production-lab
./scripts/simulate_volume_permission_error.sh
docker ps -a --filter name=volume-perm
docker logs volume-perm --tail 50
ls -ld hostdata-bad
docker rm -f volume-perm
```

What this teaches: host filesystem permissions vs container runtime user expectations.

#### TKT-004 Broken Entrypoint

```bash
cd /home/sp/cyber-course/projects/DevOps/projects/docker-production-lab
./scripts/simulate_broken_entrypoint.sh
docker image inspect docker-prod-lab:prod --format '{{json .Config.Entrypoint}} {{json .Config.Cmd}}'
docker run --rm --entrypoint sh docker-prod-lab:prod -c 'ls -l /app && head -n 3 /app/entrypoint.sh'
```

What this teaches: command/entrypoint misconfiguration and image-level startup diagnostics (no long-running container expected).

#### TKT-005 OOM

```bash
cd /home/sp/cyber-course/projects/DevOps/projects/docker-production-lab
./scripts/simulate_oom.sh
docker ps -a --filter name=oom-lab
docker inspect -f 'exit={{.State.ExitCode}} oom={{.State.OOMKilled}}' oom-lab
docker logs oom-lab --tail 50
docker stats --no-stream
docker rm -f oom-lab
```

What this teaches: resource exhaustion symptoms and OOM evidence checks.

### CI/CD Ticket Demos (`tickets/cicd/`)

These tickets are primarily GitHub workflow log analysis drills. Use the local repo to reproduce what is reproducible, then inspect GitHub Actions logs for the rest.

#### TKT-101 Lint Failure

```bash
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,120p' tickets/cicd/TKT-101-lint-failure/README.md
cd projects/github-actions-ci-demo
npm run lint
```

What this teaches: stage classification and local reproduction of lint failures.

#### TKT-102 Test Matrix Failure

```bash
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,120p' tickets/cicd/TKT-102-test-matrix-failure/README.md
cd projects/github-actions-ci-demo
cat package.json
```

What this teaches: version-specific failures and matrix reasoning (compare Node versions in CI logs).

#### TKT-103 Docker Build Failure

```bash
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,120p' tickets/cicd/TKT-103-docker-build-failure/README.md
cd projects/github-actions-ci-demo/examples/secure-nginx
docker build -t local-secure-nginx .
```

What this teaches: Docker build verify failures and local reproduction of CI build errors.

#### TKT-104 Semantic Release Permission Failure

```bash
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,120p' tickets/cicd/TKT-104-semantic-release-permission/README.md
cd projects/github-actions-ci-demo
rg -n 'permissions:|contents:|fetch-depth' .github/workflows/*.yml
```

What this teaches: GitHub Actions token scopes and release workflow requirements.

#### TKT-105 GHCR Publish Permission Failure

```bash
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,120p' tickets/cicd/TKT-105-ghcr-publish-permission/README.md
cd projects/github-actions-ci-demo
rg -n 'permissions:|packages:|ghcr' .github/workflows/*.yml
```

What this teaches: registry auth/publish permission troubleshooting.

## CLI + GitHub Combined Workflow (Recommended)

1. Read the lesson or ticket in GitHub mobile.
2. Run the demo commands in the CLI.
3. Write a 5-line note:
   - symptom or goal
   - command used
   - evidence found
   - fix or conclusion
   - reset confirmation
4. Repeat once to improve speed and accuracy.

## Cross-References

- `Library/00_full_course_q_and_a_sheet.md`
- `projects/section-walkthroughs/README.md`
- `docs/LESSON_EXECUTION_COMPANION.md`
- `tickets/README.md`
