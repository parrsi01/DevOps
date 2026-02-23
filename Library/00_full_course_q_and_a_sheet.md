# DevOps Full Course Q and A Sheet (Master)

Author: Simon Parris + additive Codex library extension
Date: 2026-02-23
Mode: GitHub mobile / CLI study companion

This is a single, full question-and-answer sheet for the DevOps repository.

It does not replace the lesson notes. It explains how the whole course fits together, what each lesson is training, and how to think while working in the CLI.

## How To Use This Sheet

1. Read the course-level Q and A first.
2. Use the lesson Q and A for the section you are on.
3. Run commands from `projects/section-walkthroughs/` in another terminal.
4. Use the ticket Q and A before and after each incident drill.

## Course-Level Q and A

### Q1. What type of software engineering is DevOps in this repo?

DevOps here is software engineering for delivery and operations systems.

It combines:

- software engineering (automation, CI/CD, release discipline)
- systems engineering (Linux, processes, networking, logging)
- platform engineering (containers, Kubernetes, GitOps)
- reliability engineering (monitoring, SLOs, incidents)
- security engineering in delivery pipelines (DevSecOps)

You are not only building app code. You are building and operating the system that builds, ships, runs, and recovers app code.

### Q2. Why does the course start with Linux instead of Kubernetes or CI/CD?

Because every later tool depends on Linux behavior.

If you do not understand:

- processes
- services
- ports
- permissions
- logs
- memory/disk pressure

then Docker and Kubernetes failures feel random. Linux gives you the base debugging vocabulary.

### Q3. What is the main learning pattern used across this DevOps repo?

The repeating pattern is:

1. Build or start a system.
2. Verify expected behavior.
3. Introduce a controlled failure.
4. Collect evidence before changing anything.
5. Apply the smallest fix.
6. Verify the fix.
7. Reset and repeat.

This is real operations behavior, not only tutorial behavior.

### Q4. How should I think when a lab fails?

Classify the failure layer first.

Use this order:

1. Environment / prerequisites missing?
2. Build/config generation failed?
3. Runtime process/container/pod failed to start?
4. Network/routing/port problem?
5. Application logic/runtime problem?
6. Monitoring/visibility gap making diagnosis harder?

This prevents random trial-and-error fixes.

### Q5. What does "evidence" mean in this course?

Evidence means commands and outputs that prove a claim.

Examples:

- `docker ps` proves container state.
- `kubectl describe pod` proves scheduling/probe/image events.
- `ss -tulpn` proves port listeners.
- `journalctl` proves host/service logs.
- Grafana/Prometheus metrics prove latency, errors, or saturation.
- ArgoCD status proves GitOps sync/drift state.

Evidence is not "I think this is the issue."

### Q6. Why are there both lesson notes and ticket demos?

They train different skills.

- Lesson notes teach concepts and normal workflows.
- Ticket demos train incident handling and pattern recognition.

If you skip tickets, you may understand the tools but still struggle in real debugging situations.

### Q7. What is the difference between DevOps, SRE, and Platform Engineering in this repo?

They overlap but focus on different questions.

- DevOps: how code moves safely from commit to runtime.
- Platform Engineering: how the runtime/deployment platform is built and maintained.
- SRE: how reliability targets are defined, monitored, and defended during incidents.

This repo intentionally includes all three because real teams mix them.

### Q8. What does "GitHub/iPhone readable" mean in practice?

It means the notes are designed so you can read them on a phone while running commands on another screen.

Practical rules used:

- short sections
- no wide tables
- explicit numbered steps
- direct command blocks
- plain-language definitions

### Q9. How do I know I am actually learning and not just copying commands?

You can answer three things after each lab:

1. What failed (or what could fail)?
2. What command proved it?
3. Why did the fix work?

If you can answer those without guessing, the learning is real.

### Q10. What should my default CLI study workflow be?

Use this pattern:

```bash
# terminal A (doing)
cd /home/sp/cyber-course/projects/DevOps

# terminal B (reading)
less docs/LESSON_EXECUTION_COMPANION.md
# or open the matching file in GitHub mobile
```

Then run the section's `Step 1-5` from `projects/section-walkthroughs/`.

## Lesson-by-Lesson Q and A (Sections 1-16)

### Lesson 1 (Linux Mastery)

Q: What is the core skill?
A: Host-level debugging fluency: permissions, processes, services, logs, ports, disk, memory, networking.

Q: What is the main question to ask?
A: Is this a process issue, service issue, permission issue, or port issue?

Q: What proves progress?
A: You can use `ps`, `systemctl`, `journalctl`, `ss`, `df`, and `free` to explain a system symptom.

### Lesson 2 (Docker Production Lab)

Q: What is the core skill?
A: Container incident classification across image build, container startup, networking/ports, and app runtime.

Q: Why this matters?
A: Docker is the first place multiple layers meet (build, OS, networking, app process).

Q: What proves progress?
A: You can diagnose a crash loop or port conflict using `docker compose ps`, `docker logs`, and `docker inspect`.

### Lesson 3 (Monitoring Stack)

Q: What is the core skill?
A: Observability reasoning: turning symptoms into metrics and logs.

Q: What is the key concept?
A: Metrics and logs answer different questions. Use both.

Q: What proves progress?
A: You can point to a graph/log signal and explain what system behavior caused it.

### Lesson 4 (Terraform Local Infrastructure)

Q: What is the core skill?
A: Predictable infrastructure change using `plan`, `apply`, `state`, and drift detection.

Q: Why local files instead of cloud first?
A: You can practice the logic of Terraform without cloud cost/risk.

Q: What proves progress?
A: You can explain the plan, apply once, then show idempotency with a second plan.

### Lesson 5 (Kubernetes Local Platform)

Q: What is the core skill?
A: Debugging desired state vs actual cluster state using `kubectl`.

Q: What is the main habit?
A: Inspect resources and events before patching manifests.

Q: What proves progress?
A: You can localize failure to pods, services, ingress, config, or resource limits.

### Lesson 6 (GitOps Workflow)

Q: What is the core skill?
A: Operating Kubernetes deployments through Git and a reconciler (ArgoCD).

Q: What is the key lesson?
A: Manual cluster changes are temporary unless committed to Git.

Q: What proves progress?
A: You can create/observe drift and explain how reconciliation restores desired state.

### Lesson 7 (DevSecOps CI/CD)

Q: What is the core skill?
A: Understanding what each CI security control protects against.

Q: What common mistake does this lesson prevent?
A: Treating security checks as random noise instead of risk controls.

Q: What proves progress?
A: You can map scanner/tool -> risk type -> limitation.

### Lesson 8 (SRE Simulation)

Q: What is the core skill?
A: Converting monitoring data into reliability decisions using SLIs, SLOs, and error budgets.

Q: What is the key concept?
A: Incidents must be described in both user impact language and metric language.

Q: What proves progress?
A: You can explain why a mitigation was justified based on SLI/SLO impact.

### Lesson 9 (Blue/Green Deployment)

Q: What is the core skill?
A: Safe release execution using traffic routing, canary percentages, and rollback.

Q: What important distinction is taught?
A: Deployment success (new version started) is not release success (safe traffic + healthy behavior).

Q: What proves progress?
A: You can run a canary, interpret health, and rollback correctly.

### Lesson 10 (Aviation-Scale DevOps Incidents)

Q: What is the core skill?
A: Cross-layer reasoning under complex incident conditions.

Q: Why "aviation-scale" framing?
A: It forces you to think about blast radius, dependencies, and operational discipline.

Q: What proves progress?
A: You can separate root cause from downstream symptoms across layers.

### Lesson 11 (Aviation Platform Architecture)

Q: What is the core skill?
A: Reading architecture as operational decisions (security, failure domains, DR, scalability, cost).

Q: Why is architecture in a hands-on repo?
A: Better debugging comes from understanding how systems should be designed to fail safely.

Q: What proves progress?
A: You can explain request path, deployment path, failure boundaries, and recovery strategy.

### Lesson 12 (Enterprise Networking)

Q: What is the core skill?
A: Layer-by-layer network troubleshooting (DNS -> TCP -> TLS -> HTTP) using evidence.

Q: What is the main habit?
A: Find the first failing protocol layer before changing configs.

Q: What proves progress?
A: You can state which layer failed and what command or capture proves it.

### Lesson 13 (Enterprise Audit and Refactor Program)

Q: What is the core skill?
A: Reviewing modules against production-grade standards and producing a remediation sequence.

Q: What is different from a normal code review?
A: This is a program-level hardening plan, not just file-by-file cleanup.

Q: What proves progress?
A: You can produce a prioritized audit checklist with acceptance criteria.

### Lesson 14 (Enterprise DevOps Incidents)

Q: What is the core skill?
A: Incident triage and RCA using hypotheses, evidence, mitigation, and prevention.

Q: What common mistake does it prevent?
A: Confusing mitigation (reduce impact now) with permanent fix (remove root cause).

Q: What proves progress?
A: Your incident write-up clearly separates symptoms, root cause, mitigation, and prevention.

### Lesson 15 (GitHub Actions CI/CD Lab)

Q: What is the core skill?
A: Reading and troubleshooting CI/CD workflows as production systems.

Q: What do you need to classify quickly?
A: Code issue, config issue, permissions issue, environment issue, or tooling issue.

Q: What proves progress?
A: You can map failed job/step to the smallest viable fix.

### Lesson 16 (Ticket Demo Library)

Q: What is the core skill?
A: Repeatable incident practice using reproduce -> debug -> fix -> verify -> reset.

Q: Why is reset required?
A: Repeatability is the training mechanism. No reset means less practice value.

Q: What proves progress?
A: You can complete tickets without skipping evidence or reset.

## Ticket Styles Q and A (All Ticket Types in This Repo)

### Docker Ticket Styles (`tickets/docker/`)

Q: What Docker ticket styles are included?
A: Crash loop, port conflict, volume permission error, broken entrypoint, and OOM.

Q: What do these teach together?
A: Startup failures, runtime failures, host/container interface problems, and resource exhaustion.

Q: What is the correct workflow?
A: Reproduce -> inspect status -> inspect logs -> identify root cause -> fix -> reset.

### CI/CD Ticket Styles (`tickets/cicd/`)

Q: What CI/CD ticket styles are included?
A: Lint failure, test matrix failure, Docker build failure, semantic-release permission failure, GHCR publish permission failure.

Q: What do these teach together?
A: Pipeline stage classification, matrix compatibility, build context errors, and GitHub token permission scoping.

Q: What is the correct workflow?
A: Classify failed job -> inspect job logs -> reproduce locally if possible -> apply minimal workflow/code fix -> rerun.

## Most Important DevOps Q and A (Keep This Handy)

### Q: What command should I run first during an incident?

A: Run the smallest command that gives state, not a change.

Examples:

- `docker compose ps`
- `kubectl get pods -A`
- `ss -tulpn`
- `journalctl -n 50 --no-pager`
- `terraform plan`

### Q: What should I avoid doing first?

A: Avoid blind restarts, random config edits, and changing multiple things at once.

### Q: What is the fastest way to improve in this repo?

A: Repeat the same ticket/lab after reset and compare your evidence collection speed and accuracy.

## Cross-References (Use With This Sheet)

- `projects/section-walkthroughs/README.md`
- `docs/LESSON_EXECUTION_COMPANION.md`
- `docs/LESSON_RESEARCH_ANALYSIS_COMPANION.md`
- `tickets/README.md`
