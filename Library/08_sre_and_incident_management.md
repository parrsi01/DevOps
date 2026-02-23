# SRE and Incident Management

---

> **Field** — DevOps / Site Reliability Engineering
> **Scope** — Reliability concepts, incident response, and postmortem practices from the SRE lab

---

## Overview

Site Reliability Engineering (SRE) bridges development
and operations by applying engineering practices to
system reliability. This section covers how to measure
reliability, manage incidents, and make decisions
based on error budgets rather than guesswork.

---

## Definitions

### `SRE (Site Reliability Engineering)`

**Definition.**
An engineering discipline that applies software
practices to operations problems. SRE focuses on
reliability, automation, and measured service quality.

**Context.**
SRE transforms "the site is down, fix it" into
structured practices with measurable targets,
error budgets, and blameless reviews.

**Example.**
An SRE team defines an SLO of 99.9% availability,
monitors it with SLIs, and uses the error budget
to decide when to slow down feature releases.

---

### `SLI (Service Level Indicator)`

**Definition.**
A measured behavior of a service that represents
its quality. Common SLIs include latency (how fast),
error rate (how often it fails), and availability
(how often it is up).

**Context.**
SLIs are the raw metrics. They answer "how is the
service performing right now?" without judgment
about whether that performance is acceptable.

**Example.**
```
SLI: p99 latency = 450ms
SLI: error rate = 0.3%
SLI: availability = 99.95%
```

---

### `SLO (Service Level Objective)`

**Definition.**
A target level for an SLI. The SLO defines what
"good enough" means for a specific metric over a
time period.

**Context.**
SLOs turn raw metrics into decisions. If the SLO
is 99.9% availability and you are at 99.85%, you
know reliability is threatened and can adjust
priorities accordingly.

**Example.**
```
SLO: 99.9% of requests complete in < 500ms
      over a rolling 30-day window
```

---

### `Error Budget`

**Definition.**
The allowed amount of unreliability before stricter
controls kick in. It is calculated as 100% minus the
SLO target. An SLO of 99.9% means the error budget
is 0.1%.

**Context.**
Error budgets make risk decisions explicit. While
budget remains, teams can ship features. When budget
is consumed, the focus shifts to reliability work.

**Example.**
```
SLO: 99.9% availability
Error budget: 0.1% = ~43 minutes/month of downtime
Remaining this month: 18 minutes
```

---

### `Incident`

**Definition.**
An event that causes or risks user-facing service
degradation. Incidents range from minor slowdowns
to full outages.

**Context.**
Incidents are not just "something broke." They are
events with user impact that require response,
communication, and follow-up.

**Example.**
"API latency exceeded 2 seconds for 15 minutes
affecting checkout flow for approximately 5,000
users."

---

### `Postmortem`

**Definition.**
A structured review conducted after an incident.
Postmortems document what happened, why it happened,
what was done, and what will be done to prevent
recurrence. They are blameless by design.

**Context.**
Postmortems are learning documents, not blame
documents. The goal is systemic improvement, not
identifying who made a mistake.

**Example.**
Postmortem sections:
1. Summary
2. Impact
3. Timeline
4. Root cause
5. Corrective actions
6. Lessons learned

---

### `Timeline`

**Definition.**
An ordered record of events during an incident.
The timeline captures when symptoms appeared, when
responders engaged, what actions were taken, and
when the issue was resolved.

**Context.**
A good timeline separates observation from action
and helps identify gaps in response. It is the
backbone of every postmortem.

**Example.**
```
10:15 — Alert fires: error rate > 5%
10:18 — On-call acknowledges
10:22 — Hypothesis: database connection pool
10:30 — Mitigation: restart app pods
10:35 — Error rate returns to baseline
```

---

### `RCA (Root Cause Analysis)`

**Definition.**
A method for identifying the deepest reason an
incident occurred. RCA goes beyond the immediate
trigger to find systemic causes.

**Context.**
Good RCA asks "why?" multiple times. "The server
crashed" is not a root cause. "The server crashed
because the OOM killer triggered because the memory
limit was set below the application's actual usage"
is closer to a root cause.

**Example.**
Technique: Five Whys
1. Why did the service fail? → Pod was killed
2. Why was the pod killed? → OOM (out of memory)
3. Why did it run out of memory? → Memory limit too low
4. Why was the limit too low? → Set during initial deploy, never updated
5. Why was it never updated? → No memory monitoring alert

---

### `Remediation`

**Definition.**
A permanent corrective change that addresses the
root cause of an incident. Remediation is different
from mitigation, which is a temporary stabilization.

**Context.**
Every incident should result in remediation actions
with owners and deadlines. Without remediation,
the same incident will recur.

**Example.**
Mitigation: restart pods (immediate relief)
Remediation: increase memory limits and add
monitoring alert for memory usage approaching
the limit (permanent fix).

---

### `Preventive Action`

**Definition.**
A change intended to stop a type of incident from
happening in the future. Prevention goes beyond
fixing one incident to improving the system.

**Context.**
Good preventive actions are specific and testable.
"Be more careful" is not a preventive action.
"Add a memory usage alert at 80% threshold" is.

**Example.**
- Add automated load testing to CI pipeline
- Create a runbook for database failover
- Add health check probes to all deployments

---

### `MTTR (Mean Time to Recovery)`

**Definition.**
The average time from when an incident is detected
to when the service is restored. MTTR measures how
fast a team can respond and recover.

**Context.**
Lower MTTR is better. MTTR is improved by better
monitoring (faster detection), clear runbooks
(faster response), and automation (faster recovery).

**Example.**
If three incidents took 30, 45, and 15 minutes
to resolve, MTTR = (30 + 45 + 15) / 3 = 30 minutes.

---

### `Toil`

**Definition.**
Repetitive, manual operational work that scales
with service size and could be automated. Toil is
work that produces no lasting value.

**Context.**
SRE teams track toil and prioritize automating it.
If you manually restart pods every week, that is
toil. Automating the restart or fixing the root
cause eliminates the toil.

**Example.**
Toil: manually rotating log files every day
Fix: configure log rotation with logrotate or
a container logging driver.

---

### `On-Call`

**Definition.**
A rotation where an engineer is responsible for
responding to incidents outside normal working
hours. On-call engineers receive alerts and are
expected to respond within defined timeframes.

**Context.**
Sustainable on-call requires good runbooks, useful
alerts (not noise), and manageable frequency. Too
much on-call load burns out engineers.

**Example.**
On-call responsibilities:
- Acknowledge alerts within 5 minutes
- Begin investigation within 15 minutes
- Escalate if unable to resolve within 1 hour

---

## Key Commands Summary

```bash
# SRE lab setup
cd projects/monitoring-stack-lab && ./scripts/start.sh
cd projects/sre-simulation-lab && ./scripts/preflight.sh

# Incident evidence
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl logs <pod> --previous
curl http://localhost:9090/api/v1/query?query=<promql>
```

---

## See Also

- [Monitoring and Observability](./03_monitoring_and_observability.md)
- [Universal DevOps Concepts](./00_universal_devops_concepts.md)
- [Deployment Strategies](./09_deployment_strategies.md)

---

> **Author** — Simon Parris | DevOps Reference Library
