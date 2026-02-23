# Universal DevOps Concepts

---

> **Field** — DevOps / Cross-Disciplinary Foundations
> **Scope** — Terms used across every lesson in this repository

---

## Overview

These definitions apply everywhere in DevOps. They are
the shared vocabulary for debugging, incident management,
and operational reasoning. Every other Library file builds
on these terms.

---

## Definitions

### `System`

**Definition.**
A set of parts working together to produce a result.
An app, a container, a network, or a full pipeline
can each be called a system.

**Context.**
When something breaks, the first question is always
"which system?" Naming the system narrows the search.

**Example.**
"The monitoring system is down" is more useful than
"something is broken."

---

### `Layer`

**Definition.**
One level in a technology stack. Each layer has its
own tools, failure modes, and evidence sources.

**Context.**
DevOps problems usually live in one layer. Identifying
the layer avoids wasting time in the wrong place.

**Example.**
A web request passes through layers: DNS, TCP, TLS,
HTTP, application code, database.

---

### `Symptom`

**Definition.**
What you observe when something goes wrong. An error
message, a timeout, a failed health check, or a
missing response are all symptoms.

**Context.**
Symptoms tell you something is wrong but not why.
Never skip from symptom to fix without evidence.

**Example.**
"Connection refused on port 8080" is a symptom.
The cause might be a stopped service, a firewall
rule, or a port conflict.

---

### `Root Cause`

**Definition.**
The actual reason a symptom happened. It is the
deepest change or condition that, if removed,
would prevent the symptom.

**Context.**
Fixing a symptom without finding the root cause
leads to repeat incidents. Root cause analysis
is a core DevOps and SRE practice.

**Example.**
Symptom: container keeps restarting.
Root cause: entrypoint script references a file
that was removed in the latest image build.

---

### `Evidence`

**Definition.**
Output, logs, metrics, or command results that
support or reject a hypothesis about what went wrong.

**Context.**
Evidence-based debugging means collecting proof
before applying fixes. This separates professional
operations from guesswork.

**Example.**
```bash
docker logs my-app 2>&1 | tail -20
```
The log output is evidence of what the container
did before it failed.

---

### `Hypothesis`

**Definition.**
A possible explanation for a problem that you
test with evidence. You either confirm it or
rule it out.

**Context.**
Good debugging generates hypotheses and tests
them one at a time. This prevents random changes.

**Example.**
Hypothesis: "The app crashed because the database
connection string is wrong."
Test: check the environment variable and database
reachability.

---

### `Mitigation`

**Definition.**
A fast action that reduces user impact right now,
even if it does not fix the root cause.

**Context.**
In live incidents, mitigation comes first. You
stabilize the system, then investigate the cause.

**Example.**
Rolling back to the previous container image to
restore service while investigating why the new
image fails.

---

### `Permanent Fix`

**Definition.**
A change that removes the root cause so the
problem does not recur.

**Context.**
Mitigations are temporary. Permanent fixes are
tracked through change management and tested
before deployment.

**Example.**
Fixing the broken entrypoint script, rebuilding
the image, and adding a CI test to catch the
issue in future builds.

---

### `Prevention`

**Definition.**
A control or practice that lowers the chance
of a problem happening again in the future.

**Context.**
Prevention is the final step in incident
response. It turns one incident into improved
system resilience.

**Example.**
Adding a health check to the deployment manifest
so Kubernetes automatically restarts unhealthy pods
before users notice.

---

### `Blast Radius`

**Definition.**
How many users, systems, or services are affected
by a failure or change.

**Context.**
Smaller blast radius means less risk. Deployment
strategies like canary releases exist specifically
to limit blast radius.

**Example.**
A DNS change affects all services. A single pod
restart affects only requests routed to that pod.

---

### `Runbook`

**Definition.**
Step-by-step operational instructions for a
specific task or incident response procedure.

**Context.**
Runbooks make operations repeatable. They reduce
reliance on individual memory and enable team
handoffs during incidents.

**Example.**
A runbook for database failover lists every
command, expected output, and verification step.

---

### `Auditability`

**Definition.**
The ability to prove what changed, when it changed,
who changed it, and why.

**Context.**
Regulated and enterprise environments require
audit trails. Git history, structured logs, and
artifact versioning all support auditability.

**Example.**
Every infrastructure change goes through a pull
request with a description, review, and merge
commit linking back to a ticket.

---

### `Reproduce`

**Definition.**
Triggering the same issue on purpose so you can
study it in a controlled way.

**Context.**
Reproduction is the first step in reliable debugging.
If you cannot reproduce a problem, you cannot confirm
your fix works.

**Example.**
```bash
./scripts/simulate_crash_loop.sh
```
Running a failure simulation script to reproduce
a container crash loop.

---

### `Debug`

**Definition.**
The process of collecting evidence and testing
hypotheses to find the cause of a problem.

**Context.**
Debugging is not random troubleshooting. It is
structured evidence collection followed by
hypothesis testing.

**Example.**
Check logs, check process state, check network
reachability, then form a hypothesis about which
layer failed.

---

### `Verify`

**Definition.**
Proving that a fix actually works by testing
the specific behavior that was broken.

**Context.**
Verification closes the loop. Without it, you
cannot be sure the fix addressed the real problem.

**Example.**
After fixing a port conflict, verify with:
```bash
curl http://127.0.0.1:8080/health
```

---

### `Reset`

**Definition.**
Returning a lab or system to its clean starting
state so you can practice again.

**Context.**
Repeatable practice requires clean resets. Leftover
state from previous runs can mask or create new
issues.

**Example.**
```bash
docker compose down -v --remove-orphans
```

---

### `Dependency`

**Definition.**
Something that another system needs in order
to function correctly.

**Context.**
When a dependency fails, everything that depends
on it may also fail. Mapping dependencies is
essential for incident diagnosis.

**Example.**
An application depends on a database. If the
database is unreachable, the application returns
errors even though its own code is correct.

---

### `Failure Domain`

**Definition.**
A boundary within which failures are contained.
Systems are designed so that a failure in one
domain does not spread to others.

**Context.**
Understanding failure domains helps you predict
which systems will be affected by an outage and
which will remain healthy.

**Example.**
A single Kubernetes namespace is a failure domain.
A misconfigured deployment in namespace A does not
affect pods in namespace B.

---

### `Degradation`

**Definition.**
A state where a service still works but with
reduced quality, speed, or capacity.

**Context.**
Degradation is different from a full outage.
It often requires different mitigation strategies
because the service is partially functional.

**Example.**
An API responds but takes 5 seconds instead of
200 milliseconds. The service is degraded, not down.

---

## See Also

- [Linux and System Administration](./01_linux_and_system_administration.md)
- [SRE and Incident Management](./08_sre_and_incident_management.md)
- [Containers and Docker](./02_containers_and_docker.md)

---

> **Author** — Simon Parris | DevOps Reference Library
