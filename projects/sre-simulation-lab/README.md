# SRE Simulation Lab (SLIs, SLOs, Error Budgets, Incidents)

Author: Simon Parris  
Date: 2026-02-22

## Enterprise Program Standard

This module is part of a professional infrastructure training program (not a hobby lab).

Training expectations for this module:
- production-grade design and operational assumptions (multi-AZ/region, identity, logging, recovery)
- security controls and least-privilege decisions are part of the exercise, not optional add-ons
- audit awareness: change traceability, approvals, evidence, and rollback records should be captured
- failure domain analysis must be included (process, host/node, AZ/region, dependency, control plane)
- examples are learning-safe but mapped to enterprise patterns; avoid localhost-only reasoning during analysis
- exercises are repeatable without AI by following the documented commands, checklists, and runbooks

Senior SRE-style simulation lab built on top of the existing monitoring stack (`projects/monitoring-stack-lab`).

This lab focuses on reliability engineering workflows:

- defining SLIs
- defining SLOs
- defining error budgets
- building latency monitoring
- simulating downtime and traffic spikes
- scaling policy design
- incident response process
- blameless postmortems

## Dependency (Use Existing Monitoring Stack)

This lab assumes module 5 is running:

```bash
cd ../monitoring-stack-lab
./scripts/start.sh
./scripts/smoke_test.sh
```

Then return here:

```bash
cd ../sre-simulation-lab
./scripts/preflight.sh
```

## Lab Contents

- `slo/sli-slo-catalog.yaml` - sample SLI/SLO definitions and error budget targets
- `slo/prometheus-alert-rules.yaml` - Prometheus recording + alert examples
- `slo/error-budget-cheatsheet.md` - error budget quick math
- `slo/hpa-scaling-policy-example.yaml` - sample scaling policy (Kubernetes HPA)
- `slo/scaling-policy-guidelines.md` - scaling policy reasoning
- `runbooks/incident-response-process.md` - incident process runbook
- `templates/postmortem-template.md` - blameless postmortem template
- `scripts/` - repeatable incident simulations and snapshot helpers

## 1. Define SLIs (Service Level Indicators)

SLIs are measurable indicators of service behavior from a user-impact perspective.

This lab defines example SLIs in `slo/sli-slo-catalog.yaml`:

- `availability` (non-5xx success ratio)
- `latency_p95_ms` (HTTP p95 latency)
- `error_rate_percent` (5xx percentage)
- `db_latency_p95_ms` (simulated DB p95 latency)

Why these matter:

- Availability tells you if users are getting successful responses.
- Latency tells you if the service is usable.
- Error rate tells you how badly requests are failing.
- DB latency helps isolate dependency-driven degradations.

## 2. Define SLOs (Service Level Objectives)

SLOs set targets for SLIs over a time window.

Examples in this lab:

- Availability SLO: `>= 99.9%` over `30d`
- HTTP latency SLO: `p95 < 300ms` over `7d`
- Error rate SLO: `< 1%` over `7d`
- DB latency SLO: `p95 < 400ms` over `7d`

SLO guidance:

- SLOs should be realistic and tied to user experience.
- Start with observed baseline data, then tighten gradually.
- Track SLO compliance and error budget burn, not just raw alerts.

## 3. Define Error Budgets

Error budget = `100% - SLO target`

Example:

- Availability SLO `99.9%`
- Error budget `0.1%`

Use the helper:

```bash
./scripts/error_budget_calc.sh 99.9 30
./scripts/error_budget_calc.sh 99.95 30
```

Reference: `slo/error-budget-cheatsheet.md`

Why error budgets matter:

- They balance release speed vs reliability work.
- If you burn budget too fast, prioritize stabilization over new features.

## 4. Build Latency Monitoring

Latency monitoring in this lab uses Prometheus metrics from the monitoring-stack app.

Core PromQL queries:

HTTP p95 latency:

```promql
histogram_quantile(0.95, sum by (le) (rate(app_http_request_duration_seconds_bucket{route!="/metrics"}[5m]))) * 1000
```

DB p95 latency:

```promql
histogram_quantile(0.95, sum by (le) (rate(app_db_query_latency_seconds_bucket[5m]))) * 1000
```

Request rate:

```promql
sum(rate(app_http_requests_total{route!="/metrics"}[1m]))
```

Error rate %:

```promql
100 * sum(rate(app_http_requests_total{status=~"5..",route!="/metrics"}[5m]))
/ clamp_min(sum(rate(app_http_requests_total{route!="/metrics"}[5m])), 0.001)
```

Prometheus rules example: `slo/prometheus-alert-rules.yaml`

## 5. Simulate Downtime

This simulates full service downtime by stopping the app container temporarily (monitoring stack remains up).

```bash
./scripts/simulate_downtime.sh 20
```

What to observe:

- app scrape target goes down in Prometheus
- availability drops
- `SimulatedServiceDown` alert (if alert rules are loaded)
- logs show container stop/start

## 6. Simulate Traffic Spike

```bash
./scripts/simulate_traffic_spike.sh 90 0 20
```

Arguments:

1. duration seconds (default `90`)
2. error every N requests (default `0`)
3. db latency ms per request (default `20`)

What to observe:

- request rate increases
- CPU rises (host/app)
- latency may increase if capacity is limited

## 7. Build Scaling Policy (SRE Perspective)

This lab includes:

- `slo/hpa-scaling-policy-example.yaml`
- `slo/scaling-policy-guidelines.md`

Key design goals:

- scale up quickly under load spikes
- scale down slowly to avoid flapping
- preserve redundancy (minimum replicas)
- protect latency SLO, not just CPU

Rule of thumb:

- Start with resource metrics (CPU) if app metrics autoscaling is unavailable.
- Move toward request-latency or queue-based scaling when possible.

## 8. Incident Response Process

Runbook: `runbooks/incident-response-process.md`

Core phases:

1. Detect
2. Triage
3. Mitigate
4. Stabilize
5. Resolve
6. Recover and validate
7. Postmortem

Useful snapshot during incident:

```bash
./scripts/incident_snapshot.sh
```

## 9. Postmortem Template

Template: `templates/postmortem-template.md`

Use it after every simulation to build the habit:

- timeline
- impact
- root cause
- contributing factors
- action items with owners and due dates

## 10. Simulations (Required)

## A. Service Degradation

### Simulate

```bash
./scripts/simulate_service_degradation.sh
```

This combines:

- CPU spike
- DB latency spike
- intermittent 5xx traffic

### What to look at

- HTTP p95 latency increases
- DB p95 latency increases
- error rate rises (not full outage)
- app logs show warnings/errors

### SRE reasoning

This is degradation, not downtime. Focus on user impact (latency + errors) and fastest mitigation (reduce load, rollback, scale, disable bad feature).

## B. DB Latency Spike

### Simulate

```bash
./scripts/simulate_db_latency_spike.sh 900 20
```

### What to look at

- `db_latency_p95_ms` rises first
- HTTP latency follows
- request throughput may drop due to slow dependency

### SRE reasoning

Dependency latency often appears before app failure. Catching this early reduces error budget burn.

## C. 5xx Error Surge

### Simulate

```bash
./scripts/simulate_5xx_surge.sh 80
```

### What to look at

- error rate % spikes
- availability SLI drops
- app logs show repeated error events

### SRE reasoning

A 5xx surge can consume error budget quickly even if duration is short. Measure burn rate, not just absolute error count.

## D. Partial Outage

### Simulate

```bash
./scripts/simulate_partial_outage.sh 40
```

### What happens

- `/health` and `/` continue succeeding
- a critical path (`/error?...`) returns 503s repeatedly
- anomaly logs are generated periodically

### What to look at

- overall availability may still look “okay” if traffic mix hides impact
- route-specific error metrics/logs show true user impact
- this demonstrates why business SLIs matter (endpoint-specific or transaction success rate)

### SRE reasoning

Partial outages are easy to underestimate if you only watch global health checks.

## Key SRE Concepts (Requested Explanations)

## Blameless Postmortem

A blameless postmortem focuses on improving systems and processes, not blaming individuals.

Why it matters:

- improves reporting honesty
- surfaces real contributing factors (alerts, tooling, process gaps)
- produces better corrective actions

Blameless does **not** mean accountability is ignored. It means accountability is directed toward system improvement and clear ownership of fixes.

## MTTR (Mean Time To Recovery / Restore)

MTTR measures the average time it takes to restore service after an incident begins.

Why it matters:

- reflects operational effectiveness
- improved by better detection, runbooks, automation, and rollback capability

Formula (simple):

- `MTTR = total recovery time across incidents / number of incidents`

## MTBF (Mean Time Between Failures)

MTBF estimates average operating time between failures (typically for repairable systems/services).

Why it matters:

- helps track reliability trend over time
- useful when combined with MTTR (frequent failures + long recovery = high risk)

Caution:

- MTBF alone can hide severe but rare incidents
- use with SLO/error budget metrics, not as a replacement

## Alert Fatigue

Alert fatigue happens when teams receive too many noisy, low-value, or non-actionable alerts.

Symptoms:

- alerts muted/ignored
- slower response to real incidents
- burnout and poor on-call performance

How to reduce it:

- alert on symptoms users feel (SLIs) first
- deduplicate and route alerts
- remove flapping alerts
- add runbook links in alerts
- use severity levels and ownership clearly
- review alert quality after incidents

## Suggested Practice Sequence

1. Start monitoring stack and run `./scripts/preflight.sh`
2. Generate baseline traffic with `./scripts/simulate_traffic_spike.sh 60 0 20`
3. Simulate DB latency spike
4. Simulate 5xx surge
5. Simulate service degradation
6. Simulate partial outage
7. Simulate downtime
8. Fill postmortem template for one scenario

## Quick Cheatsheet (SRE Lab)

```bash
./scripts/preflight.sh
./scripts/error_budget_calc.sh 99.9 30
./scripts/simulate_traffic_spike.sh 90 0 20
./scripts/simulate_db_latency_spike.sh 900 20
./scripts/simulate_5xx_surge.sh 80
./scripts/simulate_service_degradation.sh
./scripts/simulate_partial_outage.sh 40
./scripts/simulate_downtime.sh 20
./scripts/incident_snapshot.sh
```

## Validation Note

This lab reuses the `monitoring-stack-lab` runtime and scripts. It was scaffolded and script-syntax checked in-repo, but simulations were not executed on this VM during authoring.
