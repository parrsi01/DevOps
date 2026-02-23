# DevOps Project Runbooks (Detailed, Beginner + Research Format)

Author: Simon Parris + Codex companion notes  
Date: 2026-02-23

This document is a slow-learning project guide for the entire `DevOps` repository.

It is written for:

- beginner-friendly reading
- deeper context (what/why/how/evidence)
- split workflow (read on GitHub/iPhone, run commands in another terminal)

## What DevOps Is (Beginner Definition)

`DevOps` is the practice of building, running, and improving software systems using shared workflows between development and operations.

In beginner terms:

- `Dev` = writing and changing software
- `Ops` = running software reliably and safely
- `DevOps` = making those two parts work together with repeatable tools, automation, and evidence

## What This Repo Teaches (Simple Version)

This repo teaches you how to:

- run systems locally
- debug failures using logs/metrics/commands
- automate checks and deployments
- document fixes and incident evidence
- think in system layers (app, container, infra, network, CI/CD)

## How to Read These Runbooks (Research-Style, Beginner Pace)

For each project:

1. Read `Objective`
2. Read `Why this matters`
3. Read `Key terms`
4. Run the `Procedure` exactly
5. Capture `Evidence`
6. Read `Interpretation`
7. If broken, use `Failure signatures`

## Shared Verification Pattern (Use in Every Project)

Before saying “it works,” confirm:

1. Process/service started
2. Network/port reachable
3. Health or expected output returned
4. Logs do not show fatal errors
5. You can explain why it works

## Project 1: Docker Production Lab (`projects/docker-production-lab/`)

### Objective

Learn the Docker operations loop: build, run, verify, break, debug, fix, reset.

### Why this matters

Many production incidents begin at the container/runtime layer. This project teaches how to separate image problems, host Docker problems, and app problems.

### Key terms (beginner definitions)

- `Docker image`: packaged app snapshot used to start a container
- `Container`: running instance of an image
- `Compose`: Docker tool for running app resources together
- `Health endpoint`: URL that returns app status (for example `/health`)
- `Entrypoint`: startup command/script inside a container

### Procedure (baseline)

```bash
cd /home/sp/cyber-course/projects/DevOps/projects/docker-production-lab
docker compose up -d --build
docker ps
curl http://127.0.0.1:8080/health
```

### What each step is doing (why)

- `docker compose up -d --build`: builds image and starts project resources
- `docker ps`: confirms the container is actually running
- `curl .../health`: verifies app reachability and application health

### Evidence to collect

- Image built successfully (`Built`)
- Network created successfully
- Container status is `Up`
- Port `8080` reachable
- Health response content

### Interpretation

If build succeeds but health fails, the issue is not automatically “app code”; it may be Docker networking, port binding, entrypoint, or runtime permissions.

### Failure signatures (common)

- `failed to create network ... iptables`: host Docker/firewall issue
- `port is already allocated`: port conflict on host
- container exits immediately: startup/entrypoint/runtime error
- `curl: (7)`: service not listening/reachable yet

### Failure simulations (intentional practice)

```bash
./scripts/simulate_crash_loop.sh
./scripts/simulate_port_conflict.sh
./scripts/simulate_volume_permission_error.sh
./scripts/simulate_broken_entrypoint.sh
./scripts/simulate_oom.sh
```

### Reset

```bash
docker compose down -v --remove-orphans
docker rm -f port-holder crash-loop volume-perm broken-entry oom-lab 2>/dev/null || true
```

## Project 2: Monitoring Stack Lab (`projects/monitoring-stack-lab/`)

### Objective

Run a local observability stack (Prometheus + Grafana + Loki) and learn to read metrics/logs as operational evidence.

### Why this matters

Debugging without observability is guesswork. This project teaches how system behavior becomes measurable signals.

### Key terms

- `Prometheus`: collects and stores metrics over time
- `Grafana`: dashboard UI for graphs and operational views
- `Loki`: log aggregation/search system
- `Metric`: numeric signal over time (CPU, memory, error rate)
- `Dashboard`: visual group of charts for system status

### Procedure (baseline)

```bash
cd /home/sp/cyber-course/projects/DevOps/projects/monitoring-stack-lab
./scripts/start.sh
```

Open:

- Grafana: `http://127.0.0.1:3000`
- Default credentials (from repo README): `admin` / `admin`

### Evidence to collect

- Stack containers/services are running
- Grafana login works
- At least one dashboard panel loads data
- A metric changes after you generate activity/load

### Interpretation

Your goal is not just “the dashboard opened.” Your goal is to map a real action to a real metric change.

### Failure signatures (common)

- dashboard loads but no data: scrape/source misconfig or stack startup delay
- service starts but UI unreachable: port binding/startup issue
- logs missing in Loki: pipeline/agent configuration issue

## Project 3: Terraform Local Infrastructure Lab (`projects/terraform-local-infra-lab/`)

### Objective

Practice infrastructure-as-code workflow with safe local Terraform runs: `init`, `plan`, `apply`, `destroy`, and drift reasoning.

### Why this matters

Terraform is a controlled change system. The most important skill is understanding what it will do before applying.

### Key terms

- `Terraform`: tool for declarative infrastructure management
- `Plan`: preview of changes Terraform wants to make
- `Apply`: execute those changes
- `State`: Terraform’s record of managed resources
- `Drift`: real infrastructure changed outside Terraform

### Procedure (baseline)

```bash
cd /home/sp/cyber-course/projects/DevOps/projects/terraform-local-infra-lab
cp terraform.tfvars.example terraform.tfvars
./scripts/init.sh
./scripts/plan.sh
```

Then (when plan looks correct):

```bash
./scripts/apply.sh
./scripts/plan.sh
```

### Evidence to collect

- `init` success
- `plan` summary (adds/changes/destroys)
- `apply` completion
- second `plan` shows no unexpected changes (idempotency)

### Interpretation

The second `plan` is a key learning step. A stable system should converge to no-op after apply unless drift or configuration changes exist.

### Failure signatures (common)

- init/provider errors: local tooling/provider setup issue
- plan surprises: variable/config mismatch or stale state
- repeated changes after apply: drift, non-idempotent config, or state mismatch

## Project 4: Kubernetes Local Platform Lab (`projects/kubernetes-local-lab/`)

### Objective

Run and inspect Kubernetes workloads locally, then practice troubleshooting across pods, services, ingress, and scaling.

### Why this matters

Kubernetes adds a control plane and resource abstractions; debugging requires checking desired state vs actual state.

### Key terms

- `Cluster`: Kubernetes environment running workloads
- `Pod`: smallest deployable workload unit
- `Deployment`: manages pod replicas and rollout
- `Service`: stable network access to pods
- `Ingress`: HTTP/HTTPS entry routing to services

### Procedure (baseline)

```bash
cd /home/sp/cyber-course/projects/DevOps/projects/kubernetes-local-lab
./scripts/start_minikube.sh
./scripts/apply_base.sh
kubectl get ns
kubectl get pods -A
kubectl get svc -A
```

### Evidence to collect

- cluster starts successfully
- namespaces/resources created
- pods become `Running`/`Ready`
- services reachable through documented access path

### Interpretation

A manifest can apply successfully while pods still fail later. Always verify runtime status and events, not just apply output.

### Failure signatures (common)

- `ImagePullBackOff`: image access/tag issue
- `CrashLoopBackOff`: container start/runtime config error
- service exists but no response: selector mismatch or pod readiness issue

## Project 5: GitOps Workflow Lab (`projects/gitops-workflow-lab/`)

### Objective

Practice Git-as-source-of-truth deployment workflows and observe reconciliation, drift, and rollback behavior.

### Why this matters

GitOps changes operational habits: the real fix is usually a Git change, not a manual cluster patch.

### Key terms

- `GitOps`: managing deployment state through Git
- `Reconciler`: tool that syncs live state to desired Git state
- `Drift`: live changes differ from Git
- `Rollback`: return to prior known-good config

### Procedure (baseline)

```bash
cd /home/sp/cyber-course/projects/DevOps/projects/gitops-workflow-lab
./scripts/install_argocd_minikube.sh
./scripts/bootstrap_argocd_apps.sh
```

### Evidence to collect

- ArgoCD installed/reachable
- applications show sync/health status
- one controlled Git change reconciles as expected

### Interpretation

If a manual cluster change “fixes” something but ArgoCD later reverts it, that is expected GitOps behavior, not a tool bug.

### Failure signatures (common)

- app out-of-sync: desired vs live config mismatch
- healthy sync but app broken: app/runtime issue, not GitOps control issue
- repeated drift: undocumented manual changes or generated state

## Project 6: SRE Simulation Lab (`projects/sre-simulation-lab/`)

### Objective

Practice reliability engineering decisions using metrics, alerts, SLIs/SLOs, incidents, and postmortems.

### Why this matters

SRE teaches how to move from “technical error happened” to “user impact, mitigation, and reliability policy decision.”

### Key terms

- `SLI`: measured service behavior (latency, error rate, availability)
- `SLO`: target level for an SLI
- `Error budget`: allowed unreliability before stricter controls
- `Incident`: user-impacting degradation/outage event

### Procedure (baseline)

```bash
cd /home/sp/cyber-course/projects/DevOps/projects/monitoring-stack-lab && ./scripts/start.sh
cd /home/sp/cyber-course/projects/DevOps/projects/sre-simulation-lab && ./scripts/preflight.sh
```

### Evidence to collect

- monitoring stack is running (metrics available)
- SRE preflight passes
- one simulation scenario selected and documented
- incident note/postmortem fields filled (impact, timeline, mitigation)

### Interpretation

The key output is decision quality: can you justify mitigation and recovery steps using metrics and user impact?

### Failure signatures (common)

- no metrics available: monitoring dependency not running
- unclear incident diagnosis: missing baseline metrics/log correlation

## Project 7: Blue/Green Deployment Lab (`projects/blue-green-deployment-lab/`)

### Objective

Learn safe release techniques using traffic routing, canary percentages, health-based promotion, and rollback.

### Why this matters

A deployment is “code became available”; a release is “users received traffic safely.” This project teaches the difference.

### Key terms

- `Blue/green`: two versions/environments, switch traffic between them
- `Canary`: route small percentage of traffic to new version first
- `Promotion`: increase traffic to the new version after validation
- `Rollback`: route traffic back to stable version

### Procedure (baseline)

```bash
cd /home/sp/cyber-course/projects/DevOps/projects/blue-green-deployment-lab
./scripts/start.sh
./scripts/set_canary.sh 10
./scripts/sample_traffic.sh 50
```

### Evidence to collect

- which version(s) received traffic
- canary percentage configured
- sampled responses and health status
- promotion/rollback decision with reason

### Interpretation

Canary rollout is an experiment under control. The goal is to limit blast radius while collecting release evidence.

### Failure signatures (common)

- traffic split not reflected: routing config not applied
- canary unhealthy: new version issue, rollback candidate
- partial success: data compatibility or state/version mismatch risk

## Project 8: Enterprise Networking Lab (`projects/enterprise-networking-lab/`)

### Objective

Practice layered network debugging using DNS/TLS capture helpers and evidence-first troubleshooting.

### Why this matters

Many “application” incidents are actually DNS, TCP, TLS, or timeout path problems.

### Key terms

- `DNS`: name-to-IP lookup system
- `TCP`: reliable transport connection protocol
- `TLS`: encryption/identity layer for secure connections
- `Packet capture`: recording network traffic for analysis

### Procedure (baseline)

```bash
cd /home/sp/cyber-course/projects/DevOps/projects/enterprise-networking-lab
./scripts/preflight.sh
./scripts/capture_dns_path.sh api.company.aero eth0
./scripts/capture_tls_handshake.sh api.company.aero 443 eth0
```

### Evidence to collect

- DNS lookup path/result
- TCP connect behavior (if shown by scripts/tools)
- TLS handshake success/failure
- timestamps and interface used

### Interpretation

Always locate the first failing layer. If DNS fails, TLS debugging is downstream noise.

### Failure signatures (common)

- DNS timeout/incorrect IP: resolver/network path issue
- TCP connection failure: routing/firewall/listener issue
- TLS handshake failure: certificate/protocol/cipher mismatch

## Project 9: GitHub Actions CI/CD Demo (`projects/github-actions-ci-demo/`)

### Objective

Study CI/CD workflow design, job sequencing, security controls, and failure diagnosis without requiring every step to run locally.

### Why this matters

Pipelines are production systems for delivery. Broken CI/CD blocks releases and can bypass quality/security controls.

### Key terms

- `Workflow`: CI/CD pipeline definition file
- `Job`: group of steps in a pipeline run
- `Artifact`: output file produced by a job
- `Permission`: access rights used by the pipeline token/actions

### Procedure (study baseline)

```bash
cd /home/sp/cyber-course/projects/DevOps/projects/github-actions-ci-demo
ls .github/workflows
ls examples/secure-nginx
```

Then read:

- workflow job order
- permissions blocks
- security scans (Trivy, gitleaks, CodeQL)
- Docker publish/release logic

### Evidence to collect

- workflow names and purpose
- job dependencies
- required secrets/permissions
- failure signatures in ticket scenarios

### Interpretation

CI/CD debugging is staged diagnosis: identify first failing job/step, then determine whether the cause is code, config, environment, or permissions.

## Project 10: Ticket Practice Library (`tickets/`)

### Objective

Build debugging muscle memory by repeating realistic incidents with reproduce/debug/fix/reset workflow.

### Why this matters

Repetition converts command familiarity into diagnostic pattern recognition.

### Key terms

- `Reproduce`: intentionally trigger the issue
- `Debug`: collect evidence and test hypotheses
- `Verify`: prove the fix works
- `Reset`: restore clean practice state

### Procedure

```bash
cd /home/sp/cyber-course/projects/DevOps/tickets
sed -n '1,200p' README.md
```

Pick one ticket and follow its `README.md`:

1. reproduce
2. debug
3. fix
4. verify
5. reset

### Evidence to collect

- reproduction proof
- command/log evidence
- root cause statement
- fix verification
- reset confirmation

### Interpretation

The educational value is highest when you delay the fix until you have evidence.

## Beginner Study Plan (If You Still Feel “I Don’t Know DevOps Yet”)

Use this exact order:

1. Linux lesson + definitions (`docs/linux-mastery-lab.md` + companion notes)
2. Docker baseline only (no failure simulation yet)
3. Docker tickets one by one
4. Monitoring stack (learn what metrics/logs mean)
5. Terraform basics (`init`/`plan` only at first)
6. Kubernetes basics (start cluster + inspect objects)
7. GitOps concepts (read before changing)
8. CI/CD + ticket practice

Repeat the Docker and ticket modules until the commands feel familiar. That is normal and expected.
