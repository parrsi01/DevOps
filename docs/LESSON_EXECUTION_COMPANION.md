# DevOps Lesson Execution Companion (Slow-Learning Edition)

Author: Simon Parris + Codex companion notes  
Date: 2026-02-23

This companion is written for split-focus study: one CLI for doing, one screen (or iPhone GitHub) for reading.

Use this note for each lesson when the pace feels too fast.

## How to Use This Companion

For every lesson, read in this order:

1. `What this lesson is`
2. `Why this matters`
3. `Companion prompt`
4. `Do this now`
5. `Evidence to collect`
6. `Stop condition`

## Reading Mode Rule (Important)

Do not try to understand everything while typing.

- First pass: run the commands exactly.
- Second pass: read the `Why this matters` block.
- Third pass: write a 4-line incident/learning note in your own words.

## Lesson 1: Linux Mastery (`docs/linux-mastery-lab.md`)

### What this lesson is

Operational command fluency for debugging real systems: permissions, processes, services, logs, networking, disk, memory, and ports.

### Why this matters

Docker, Kubernetes, CI, and monitoring all sit on top of Linux behavior. If Linux basics are weak, later incidents feel random instead of diagnosable.

### Companion prompt

`Explain what system symptom I am creating, what evidence command proves it, and what single command likely fixes it. Use beginner definitions for every Linux term.`

### Do this now

- Run baseline host evidence (`whoami`, `uname -a`, `ip a`, `ss -tulpn`, `df -h`, `free -h`)
- Create one small permission change and verify with `ls -l`
- Start and stop one harmless process (`sleep 600`)
- Check one service with `systemctl status`
- Read recent logs with `journalctl -n 50 --no-pager`

### Evidence to collect

- Command used
- Output summary (not full dump)
- What changed after the fix

### Stop condition

You can explain the difference between a process problem, a service problem, and a port problem without guessing.

## Lesson 2: Docker Production Lab (`docs/docker-production-lab.md`, `projects/docker-production-lab/`)

### What this lesson is

A baseline web app running in Docker with production-style patterns (multi-stage build, non-root user, health endpoint), plus intentional failure scenarios.

### Why this matters

This is your first full-stack operations loop: build -> run -> verify -> break -> debug -> fix -> reset.

### Companion prompt

`Walk me through this Docker lab as an incident analyst: what layer failed (build, network, container runtime, app, health check), what command proves it, and why the next command is justified. Define each Docker term simply.`

### Do this now

- Build and start the baseline with `docker compose up -d --build`
- Verify app health with `curl http://127.0.0.1:8080/health`
- If it fails, classify the failure layer before changing anything
- Capture logs (`docker compose logs`, `docker ps`, `docker inspect` as needed)
- Reset cleanly with `docker compose down -v --remove-orphans`

### Evidence to collect

- Whether image build succeeded
- Whether network creation succeeded
- Whether container is running
- Whether port is bound
- Health endpoint result

### Stop condition

You can say exactly whether a failure is in Docker build, Docker networking, container startup, or application runtime.

## Lesson 3: Monitoring Stack Lab (`docs/monitoring-stack-lab.md`, `projects/monitoring-stack-lab/`)

### What this lesson is

Prometheus, Grafana, and Loki practice for metrics, dashboards, and logs in one local observability stack.

### Why this matters

Without observability, debugging becomes guesswork. This lesson teaches how to convert symptoms into measurable signals.

### Companion prompt

`Explain this monitoring stack like a production observer: what each tool collects, what question it answers, and what signal would show latency, errors, or resource pressure. Define metrics/logs/dashboard/alert in beginner terms.`

### Do this now

- Start the stack using the project `start.sh`
- Open Grafana and confirm login
- Identify one dashboard panel for CPU, one for memory, one for request/error behavior
- Generate a small workload and watch metric changes

### Evidence to collect

- Stack services running
- Grafana accessible
- One metric that moved because of your action

### Stop condition

You can point to a graph and explain what real system behavior it represents.

## Lesson 4: Terraform Local Infrastructure Lab (`docs/terraform-local-infra-lab.md`, `projects/terraform-local-infra-lab/`)

### What this lesson is

Infrastructure-as-code practice using local-safe Terraform workflows for plan/apply/destroy, state, and drift.

### Why this matters

Terraform teaches controlled change management. The key skill is predicting impact before applying changes.

### Companion prompt

`Explain what Terraform is about to change, how state affects that decision, and what drift means in simple language before I run apply.`

### Do this now

- Copy example variables file
- Run init, then plan
- Read the plan before applying
- Apply once, re-run plan (idempotency check)
- Simulate/inspect drift if the lab provides it

### Evidence to collect

- Plan summary (+/-/~ resources)
- Apply result
- Second plan result (should be no-op when stable)

### Stop condition

You can explain “state”, “plan”, “apply”, and “drift” without mixing them up.

## Lesson 5: Kubernetes Local Platform Lab (`docs/kubernetes-local-lab.md`, `projects/kubernetes-local-lab/`)

### What this lesson is

Local Kubernetes platform practice (cluster startup, workloads, services, ingress, scaling, rollout behavior).

### Why this matters

Kubernetes adds another control plane layer. You need a habit of checking desired state vs actual state.

### Companion prompt

`Explain this Kubernetes issue by separating control plane intent from pod/runtime reality. Define cluster, namespace, deployment, pod, service, ingress, and HPA simply.`

### Do this now

- Start local cluster
- Apply base manifests
- Verify namespaces, pods, services
- Test access path (service/ingress)
- Trigger a small rollout or scaling change and observe status

### Evidence to collect

- `kubectl get` summaries
- Pod status and events
- Reachability test result

### Stop condition

You can locate where a failure lives: manifest config, scheduler/pod, service routing, or ingress path.

## Lesson 6: GitOps Workflow Lab (`docs/gitops-workflow-lab.md`, `projects/gitops-workflow-lab/`)

### What this lesson is

Declarative deployment workflow with Git as the source of truth and a reconciler (ArgoCD in this lab).

### Why this matters

GitOps changes how deployments are debugged: you inspect desired config, sync status, and drift rather than manually patching systems.

### Companion prompt

`Explain this GitOps workflow as a change-control system: what is the desired state, what reconciles it, how drift happens, and why manual fixes are temporary unless committed to Git.`

### Do this now

- Install/bootstrap ArgoCD per project scripts
- Inspect app sync/health status
- Make one small config change in Git and observe reconciliation
- Practice rollback/drift scenario

### Evidence to collect

- Git commit/change made
- Sync status before/after
- Drift or rollback observation

### Stop condition

You can explain why “kubectl edit” may work temporarily but still be the wrong GitOps fix.

## Lesson 7: DevSecOps CI/CD Lab (`docs/devsecops-cicd-lab.md`)

### What this lesson is

Security controls embedded into CI/CD: image scanning, secret scanning, SAST, hardening checks, and policy thinking.

### Why this matters

Pipelines that only build/test are incomplete for production. Security gates reduce risk before deployment.

### Companion prompt

`Explain each CI security check in plain language: what risk it catches, what it cannot catch, and what a failed check means operationally.`

### Do this now

- Read the workflow files in `projects/github-actions-ci-demo/.github/workflows`
- Identify each security control and its purpose
- Trace one example app (`examples/secure-nginx`) through checks

### Evidence to collect

- List of pipeline stages
- Security control -> risk mapping
- One false-positive/false-negative risk example

### Stop condition

You can justify why a pipeline check exists instead of treating it as “extra noise”.

## Lesson 8: SRE Simulation Lab (`docs/sre-simulation-lab.md`, `projects/sre-simulation-lab/`)

### What this lesson is

Operations decision-making using SLIs, SLOs, error budgets, alerts, incidents, and postmortem workflow.

### Why this matters

This lesson connects raw monitoring signals to business/service reliability decisions.

### Companion prompt

`Explain this SRE incident in business terms and technical terms: what user impact occurred, which SLI degraded, how the SLO/error budget changes decisions, and what immediate mitigation is justified.`

### Do this now

- Run monitoring stack + SRE preflight
- Read SLO/incident templates
- Trigger or review one simulation
- Write a short incident response note

### Evidence to collect

- Impact statement
- Metric/SLI evidence
- Timeline of actions

### Stop condition

You can describe an outage as both a user-impact story and a metric story.

## Lesson 9: Blue/Green Deployment Lab (`docs/blue-green-deployment-lab.md`, `projects/blue-green-deployment-lab/`)

### What this lesson is

Deployment routing simulation using blue/green and canary release strategies with health-based cutover and rollback.

### Why this matters

Deployment safety depends on controlled traffic shifting, not just “new version is up”.

### Companion prompt

`Explain this rollout as a risk-managed experiment: what version gets traffic, what percentage, what health signals gate promotion, and what conditions trigger rollback.`

### Do this now

- Start the lab
- Route small canary traffic percentage
- Sample traffic/results
- Increase or rollback based on health

### Evidence to collect

- Active version + canary percentage
- Health results by version
- Promotion/rollback decision reason

### Stop condition

You can explain the difference between deployment success and release success.

## Lesson 10: Aviation-Scale DevOps Incidents (`docs/aviation-scale-devops-incidents-lab.md`)

### What this lesson is

Cross-layer incident simulations designed to train systems thinking across app, infra, network, and operations constraints.

### Why this matters

Real incidents rarely stay inside one tool boundary. This module trains failure-domain reasoning.

### Companion prompt

`Analyze this incident by failure domain (app, container, orchestration, network, infra, control plane). What evidence separates correlation from cause?`

### Do this now

- Read one incident fully
- Map dependencies and blast radius
- List evidence you would collect before fixing

### Evidence to collect

- Failure domain map
- Dependency chain
- Primary vs secondary symptoms

### Stop condition

You can separate root cause from downstream noise.

## Lesson 11: Aviation Platform Architecture (`docs/aviation-platform-architecture.md`)

### What this lesson is

Architecture design thinking for secure, scalable, multi-region systems with resilience and operational controls.

### Why this matters

Hands-on debugging is stronger when you understand how systems should be designed to fail safely.

### Companion prompt

`Explain this architecture as an operations design: where are the failure boundaries, how is recovery handled, and what controls support auditability and security?`

### Do this now

- Read one architecture section
- Draw the data/request path on paper
- Mark failure domains and recovery actions

### Evidence to collect

- Component list
- Trust boundaries
- Failure domain notes

### Stop condition

You can explain the architecture as a set of operational decisions, not just boxes and arrows.

## Lesson 12: Enterprise Networking (`docs/enterprise-networking-lab.md`, `projects/enterprise-networking-lab/`)

### What this lesson is

Networking fundamentals and packet-capture-based debugging for DNS, TLS, NAT, load balancing, and timeouts.

### Why this matters

Many “app issues” are actually network path issues. This module trains evidence-based network debugging.

### Companion prompt

`Explain this network symptom layer-by-layer (DNS, TCP, TLS, HTTP). What command or capture proves where the failure starts? Define each protocol simply.`

### Do this now

- Run preflight
- Capture a DNS path and a TLS handshake (lab scripts)
- Compare expected vs observed behavior

### Evidence to collect

- DNS resolution result
- TCP connect result
- TLS handshake status
- HTTP response behavior

### Stop condition

You can say which protocol layer failed first and what proves it.

## Lesson 13: Enterprise Infrastructure Audit & Refactor Program (`docs/enterprise-infrastructure-audit-refactor-program.md`)

### What this lesson is

A structured review of modules 1-14 to raise them to enterprise-grade operational, security, and documentation standards.

### Why this matters

Engineering maturity is not only building labs; it is improving controls, evidence, repeatability, and change discipline.

### Companion prompt

`Review this module like an auditor-engineer: what is missing in logging, rollback, security, documentation, or evidence capture, and why does that matter in production?`

### Do this now

- Choose one earlier module
- Audit for reproducibility, rollback, logging, and security controls
- Write concrete improvements

### Evidence to collect

- Gaps found
- Risk impact
- Proposed remediation sequence

### Stop condition

You can produce an improvement plan, not just a critique.

## Lesson 14: Enterprise DevOps Incidents (`docs/enterprise-devops-incidents-lab.md`)

### What this lesson is

Realistic incident scenarios that combine operations evidence, root cause analysis, and corrective actions.

### Why this matters

This is where technical skill becomes operational judgment under uncertainty.

### Companion prompt

`Write a short incident analysis from this scenario: user impact, timeline, evidence, root cause, mitigation, permanent fix, and preventive actions. Define every key term for a beginner.`

### Do this now

- Pick one incident
- Write the analysis before reading the official resolution
- Compare your reasoning to the provided approach

### Evidence to collect

- Your hypothesis list
- Evidence supporting/refuting each hypothesis
- Final root cause and prevention

### Stop condition

You can justify your diagnosis using evidence, not intuition only.

## Lesson 15: GitHub Actions CI/CD Lab (`docs/github-actions-cicd-lab.md`, `projects/github-actions-ci-demo/`)

### What this lesson is

CI/CD pipeline design and troubleshooting for lint, test, build, release, and container publishing workflows.

### Why this matters

Pipelines are production systems. Broken CI/CD blocks delivery and can hide quality/security regressions.

### Companion prompt

`Explain this pipeline run as a staged system: what each job validates, what artifact moves between jobs, and how to localize a failure quickly from logs.`

### Do this now

- Review workflow files and job order
- Map secrets/permissions used by each job
- Practice one ticket from `tickets/cicd/`

### Evidence to collect

- Failed job and step
- Error signature
- Minimal fix and why it works

### Stop condition

You can read a pipeline failure and classify it (code issue, config issue, permissions, environment, tooling).

## Lesson 16: Ticket Demo Index (`docs/ticket-demo-index.md`, `tickets/README.md`)

### What this lesson is

Repeatable incident practice library for Docker and CI/CD, designed as “debug like work” drills.

### Why this matters

Repetition builds pattern recognition. Tickets convert theory into operational muscle memory.

### Companion prompt

`Coach me through this ticket without solving too fast: first reproduce, then collect evidence, then rank hypotheses, then apply the smallest fix, then verify and reset.`

### Do this now

- Pick one ticket
- Follow reproduce/debug/fix/reset exactly
- Write a short note in your own words after completion

### Evidence to collect

- Reproduction proof
- Debug evidence
- Fix verification
- Reset confirmation

### Stop condition

You can repeat the same ticket later and solve it faster with better evidence hygiene.

## Personal Memorization Method (Recommended)

After each lesson, write these 5 lines in a note:

1. `What broke / what was the focus`
2. `What proved it`
3. `What fixed it`
4. `Why the fix worked`
5. `What I will check first next time`

This converts “I followed steps” into “I can retrieve the pattern from memory.”
