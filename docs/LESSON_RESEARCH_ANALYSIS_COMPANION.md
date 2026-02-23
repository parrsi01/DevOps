# DevOps Lesson Research Analysis Companion (Beginner Definitions)

Author: Simon Parris + Codex companion notes  
Date: 2026-02-23

This note is for reading lessons slowly and deeply, like a research analyst, while still using beginner-friendly language.

## Why This Companion Exists

When a course moves fast, learners often memorize commands without understanding:

- what system layer is involved
- what evidence is meaningful
- what terms actually mean
- why a fix works

This companion closes that gap.

## How to Read a Lesson Like a Research Analyst (Beginner Version)

For each lesson, ask:

1. `What system are we studying?`
2. `What problem can happen in that system?`
3. `What evidence would prove the problem?`
4. `What evidence would disprove it?`
5. `What fix changes the cause (not only the symptom)?`
6. `What preventive control would reduce repeat incidents?`

## Universal Definitions (Used Across DevOps Lessons)

- `System`: A set of parts working together (app, container, network, pipeline, etc.).
- `Layer`: One level in the stack (for example: app layer, container layer, network layer).
- `Symptom`: What you observe (error, timeout, failed health check).
- `Root cause`: The actual reason the symptom happened.
- `Evidence`: Output/logs/metrics that support or reject a hypothesis.
- `Hypothesis`: A possible explanation you test with evidence.
- `Mitigation`: A fast action that reduces impact now.
- `Permanent fix`: A change that removes the cause.
- `Prevention`: A control that lowers the chance of repeat failure.
- `Blast radius`: How many users/systems are affected.
- `Runbook`: Step-by-step operational instructions.
- `Auditability`: Ability to prove what changed, when, and why.

## Lesson-by-Lesson Analysis Lens

## Lesson 1: Linux Mastery

### Research lens

Treat Linux as the substrate layer. The main question is: is the failure caused by identity/permissions, process state, service state, resource exhaustion, or network reachability?

### Beginner definitions

- `Permission`: A rule that says who can read/write/execute a file.
- `Process`: A running program instance.
- `Service`: A managed long-running program (often started by systemd).
- `Port`: A numbered network endpoint used by a program.
- `Journal`: System log storage used by `journalctl`.

### What to analyze

- Which command shows the symptom?
- Which command shows the cause?
- What changed after the fix?

## Lesson 2: Docker Production Lab

### Research lens

Separate Docker problems into four layers:

1. `Build layer` (image creation)
2. `Docker host/runtime layer` (daemon, network, volumes, permissions)
3. `Container startup layer` (entrypoint/cmd/env)
4. `Application layer` (app logic/health endpoint)

### Beginner definitions

- `Docker image`: A packaged app snapshot used to start containers.
- `Container`: A running instance of an image.
- `Entrypoint`: The startup command/script for a container.
- `Health check`: A test used to confirm the app is functioning.
- `Volume`: Persistent storage mounted into a container.
- `Bridge network`: Docker’s local network for containers on one host.
- `Compose`: A tool to define/run multi-container setups.

### What to analyze

- Did the image build?
- Did the network create?
- Did the container start?
- Is the port open?
- Does the app return healthy output?

### Example (your current error)

The image built, but network creation failed due to missing `iptables` Docker isolation chain. Therefore the container never started. This is a host networking/firewall state issue, not an app bug.

## Lesson 3: Monitoring Stack Lab

### Research lens

Observability is evidence generation. Ask which tool answers which question:

- Metrics: “How much / how often?”
- Logs: “What exactly happened?”
- Dashboards: “What is changing over time?”

### Beginner definitions

- `Metric`: A numeric measurement (CPU %, requests/sec, error rate).
- `Log`: A timestamped text record of events.
- `Dashboard`: A visual page of graphs/panels.
- `Alert`: A rule that notifies when a condition is abnormal.
- `Time series`: Data points collected over time.

### What to analyze

- Which signal changed first?
- Which signal confirms user impact vs background noise?

## Lesson 4: Terraform Local Infrastructure Lab

### Research lens

Terraform is change prediction plus change execution. The key analytical question: what does Terraform believe exists, and is that belief correct?

### Beginner definitions

- `Plan`: A preview of intended changes.
- `Apply`: Execute the planned changes.
- `State`: Terraform’s record of managed infrastructure.
- `Drift`: Real infrastructure changed outside Terraform.
- `Idempotent`: Re-running produces no additional change when already correct.

### What to analyze

- Is the plan logical?
- Is state accurate?
- Did a manual change create drift?

## Lesson 5: Kubernetes Local Platform Lab

### Research lens

Kubernetes incidents often come from a mismatch between desired state and actual cluster state. Separate config intent from runtime reality.

### Beginner definitions

- `Cluster`: A group of machines running Kubernetes workloads.
- `Namespace`: A logical partition for resources.
- `Deployment`: A controller that manages pods/replicas.
- `Pod`: The smallest deployable unit (one or more containers).
- `Service`: Stable network access to pods.
- `Ingress`: HTTP/HTTPS routing into services.
- `HPA`: Horizontal Pod Autoscaler (auto-scales replicas based on metrics).

### What to analyze

- Is the manifest correct?
- Did the controller accept it?
- Are pods healthy?
- Does service routing reach the pods?

## Lesson 6: GitOps Workflow Lab

### Research lens

GitOps is a control model, not just a tool. Analyze differences between:

- desired state in Git
- observed state in cluster
- reconciliation status

### Beginner definitions

- `GitOps`: Operating systems/apps by changing Git-managed config.
- `Reconciler`: A tool that compares desired vs actual state and syncs them.
- `Drift`: Live state changed away from Git.
- `Sync`: Process of applying Git state to the cluster.
- `Rollback`: Reverting to a known good config/version.

### What to analyze

- Is the fix in Git?
- Is the cluster out of sync?
- Is a manual cluster change being overwritten?

## Lesson 7: DevSecOps CI/CD Lab

### Research lens

Treat each security control as a risk filter. Ask what risk it detects, what evidence it emits, and what blind spots remain.

### Beginner definitions

- `SAST`: Static analysis of source code for security issues.
- `Secret scan`: Detection of exposed tokens/keys in code/history.
- `Vulnerability scan`: Detection of known insecure packages/images.
- `Hardening`: Reducing attack surface by safer defaults/config.
- `Policy gate`: A check that can block pipeline progress.

### What to analyze

- Which risk is being controlled?
- What happens if this check is skipped?
- What false positives/negatives are possible?

## Lesson 8: SRE Simulation Lab

### Research lens

Convert technical noise into service reliability decisions. Analyze impact, not only error messages.

### Beginner definitions

- `SLI`: Service Level Indicator (measured behavior, like latency or error rate).
- `SLO`: Service Level Objective (target for an SLI).
- `Error budget`: Allowed amount of unreliability before stricter changes/controls apply.
- `Incident`: An event causing or risking user-facing service degradation.
- `Postmortem`: Structured review after an incident.

### What to analyze

- Which SLI degraded?
- Is the SLO threatened or breached?
- What mitigation best protects users right now?

## Lesson 9: Blue/Green Deployment Lab

### Research lens

Analyze deployment as controlled exposure to risk. Focus on traffic routing, health signals, and decision thresholds.

### Beginner definitions

- `Blue/green`: Two environments/versions; switch traffic from one to the other.
- `Canary`: Send a small percentage of traffic to a new version first.
- `Cutover`: Moving traffic to the new version.
- `Rollback`: Sending traffic back to the prior stable version.
- `Promotion`: Increasing trust and traffic to the new version.

### What to analyze

- What percentage of users are exposed?
- What signal determines promotion vs rollback?
- Is impact isolated or growing?

## Lesson 10: Aviation-Scale DevOps Incidents

### Research lens

Use cross-layer reasoning. Build a failure map before touching fixes.

### Beginner definitions

- `Dependency`: Something another system needs to function.
- `Failure domain`: A boundary where failures are contained (or not).
- `Correlation`: Two things happen together.
- `Causation`: One thing actually causes the other.
- `Degradation`: Service still works but with reduced quality/performance.

### What to analyze

- Which symptom is primary?
- Which systems are downstream effects?
- Where does evidence first diverge from normal?

## Lesson 11: Aviation Platform Architecture

### Research lens

Study architecture as a set of decisions under constraints: availability, security, cost, auditability, and recovery.

### Beginner definitions

- `Architecture`: High-level design of system components and interactions.
- `Multi-region`: Running in more than one geographic region for resilience.
- `DR` (Disaster Recovery): How service is restored after major failure.
- `Trust boundary`: Where access/security assumptions change.
- `Control plane`: Management layer that configures or orchestrates systems.

### What to analyze

- What fails together?
- What can recover independently?
- Where are audit and security controls enforced?

## Lesson 12: Enterprise Networking

### Research lens

Network debugging is layered evidence collection. Start from name resolution and move toward application response.

### Beginner definitions

- `DNS`: Converts names (like `api.example.com`) into IP addresses.
- `TCP`: Reliable connection protocol used by many services.
- `TLS`: Encryption layer used for secure connections (HTTPS).
- `HTTP`: Web request/response protocol.
- `NAT`: Network Address Translation (rewrites addresses between networks).
- `Load balancer`: Distributes traffic across multiple backends.

### What to analyze

- Did DNS resolve?
- Did TCP connect?
- Did TLS handshake succeed?
- Did HTTP respond correctly?

## Lesson 13: Enterprise Infrastructure Audit & Refactor Program

### Research lens

Audit for operational quality, not just functionality. Ask what evidence would be needed in a real production review.

### Beginner definitions

- `Audit`: Structured review to verify controls and evidence.
- `Traceability`: Ability to follow a change from request to result.
- `Rollback plan`: Steps to safely reverse a change.
- `Control`: A practice/check that reduces risk.
- `Refactor`: Improve structure/design without changing intended behavior.

### What to analyze

- What controls are missing?
- Which gaps increase operational risk?
- Which improvements give highest risk reduction first?

## Lesson 14: Enterprise DevOps Incidents

### Research lens

Practice writing evidence-based incident narratives that link user impact, system behavior, and corrective action.

### Beginner definitions

- `Timeline`: Ordered record of incident events.
- `Mitigation`: Short-term action that reduces impact.
- `Remediation`: Permanent corrective change.
- `RCA` (Root Cause Analysis): Method to identify why the incident happened.
- `Preventive action`: Change intended to stop recurrence.

### What to analyze

- Is the timeline complete?
- Is root cause supported by evidence?
- Are preventive actions specific and testable?

## Lesson 15: GitHub Actions CI/CD Lab

### Research lens

Treat the pipeline as a distributed system with jobs, permissions, artifacts, and environment assumptions.

### Beginner definitions

- `Workflow`: Pipeline definition file.
- `Job`: A set of steps running in one execution environment.
- `Step`: One command/action inside a job.
- `Artifact`: File/output passed between jobs or stored after a run.
- `Permission`: Access rights for GitHub token/actions to read/write resources.

### What to analyze

- Which job failed first?
- Was it code, config, environment, or permissions?
- What is the smallest change that fixes the real cause?

## Lesson 16: Ticket Demo Index

### Research lens

Use tickets to build pattern memory. The goal is not only a fix, but faster and cleaner diagnosis each repetition.

### Beginner definitions

- `Reproduce`: Trigger the same issue on purpose.
- `Debug`: Collect evidence and test hypotheses.
- `Verify`: Prove the fix works.
- `Reset`: Return lab to clean state.
- `Runbook note`: Short repeatable record of what to do next time.

### What to analyze

- Did you reproduce the intended issue exactly?
- Did your evidence precede your fix?
- Can someone else repeat your steps from your note?

## Study Prompt Template (Reusable for Any DevOps Lesson)

Use this whenever you feel overloaded:

`Explain this lesson like a research analyst teaching a beginner. First define every important term simply. Then explain what system we are operating, what can fail, what evidence proves each failure mode, what command/action we are doing now and why, and how I should verify the result before moving on.`
