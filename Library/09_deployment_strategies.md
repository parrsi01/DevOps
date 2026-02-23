# Deployment Strategies

---

> **Field** — DevOps / Release Engineering
> **Scope** — Deployment and release patterns from the blue/green deployment lab

---

## Overview

Deploying new code and releasing it to users are two
different things. Deployment puts the code on servers.
Release controls who receives traffic. This section
covers strategies for safely releasing changes while
limiting blast radius and enabling fast rollback.

---

## Definitions

### `Deployment`

**Definition.**
The act of placing a new version of software onto
servers or into a cluster so it is ready to run.
Deployment does not automatically mean users see
the new version.

**Context.**
Separating deployment from release is a key safety
practice. You can deploy a new version, verify it
in isolation, and then gradually route users to it.

**Example.**
```bash
kubectl apply -f deployment-v2.yaml
# deploys version 2 alongside version 1
# no traffic routed to v2 yet
```

---

### `Release`

**Definition.**
The moment when users start receiving traffic from
a new version. A release is a traffic decision,
not a code deployment decision.

**Context.**
Release strategies control exposure. A deployment
can be successful while a release is rolled back
if health checks fail.

**Example.**
Deployment succeeded (v2 pods are running).
Release decision: route 10% of traffic to v2,
monitor health, then increase to 100%.

---

### `Blue/Green`

**Definition.**
A deployment strategy using two identical
environments. "Blue" runs the current version.
"Green" runs the new version. Traffic is switched
from blue to green after validation.

**Context.**
Blue/green gives instant rollback. If green fails,
switch traffic back to blue. The downside is
needing two full environments running simultaneously.

**Example.**
```
Blue (v1) ← 100% traffic
Green (v2) ← 0% traffic (being validated)

After validation:
Blue (v1) ← 0% traffic
Green (v2) ← 100% traffic
```

---

### `Canary`

**Definition.**
A deployment strategy where a small percentage
of traffic is sent to the new version first. If
health metrics are good, the percentage increases.
If something is wrong, the canary is killed.

**Context.**
Canary releases limit blast radius. Only a small
fraction of users see the new version initially.
This is the safest way to release changes to
production.

**Example.**
```bash
./scripts/set_canary.sh 10
# 10% of traffic goes to the new version

./scripts/sample_traffic.sh 50
# sample 50 requests to check health

# if healthy:
./scripts/set_canary.sh 50
./scripts/set_canary.sh 100
```

---

### `Rolling Update`

**Definition.**
A deployment strategy where old pods are gradually
replaced with new pods, one at a time. At any point,
both old and new versions may be serving traffic.

**Context.**
Rolling updates are the default Kubernetes deployment
strategy. They ensure zero downtime but can create
brief periods where two versions serve simultaneously.

**Example.**
```bash
kubectl set image deployment/my-app \
  app=my-app:v2
# Kubernetes gradually replaces v1 pods with v2
```

---

### `Cutover`

**Definition.**
The moment when traffic is switched from the old
version to the new version. In blue/green, cutover
is an all-at-once switch. In canary, it is the
final increase to 100%.

**Context.**
Cutover decisions should be based on health signals,
not time. "The canary has been running for 10 minutes"
is weaker than "the canary shows 0% error rate and
p99 latency under 200ms."

**Example.**
Cutover criteria:
- Error rate < 0.1%
- Latency p99 < 500ms
- No new error signatures in logs
- Minimum soak time: 15 minutes

---

### `Rollback`

**Definition.**
Sending traffic back to the previous stable version
after the new version shows problems. Rollback is
the safety mechanism that makes deployment strategies
low-risk.

**Context.**
Fast rollback is more important than perfect
deployment. If rollback takes 30 seconds, deployment
risk is low. If rollback takes 30 minutes, risk
is high.

**Example.**
```bash
# Blue/green rollback
./scripts/set_canary.sh 0
# all traffic returns to the stable version

# Kubernetes rollback
kubectl rollout undo deployment/my-app
```

---

### `Promotion`

**Definition.**
Increasing trust and traffic to a new version
after validation. Promotion is the opposite of
rollback. It moves the new version from canary
to full production.

**Context.**
Promotion should be gradual and evidence-based.
10% → 25% → 50% → 100%, with health checks
at each stage.

**Example.**
```
Stage 1: 10% canary → health OK → promote
Stage 2: 25% canary → health OK → promote
Stage 3: 50% canary → health OK → promote
Stage 4: 100% → canary complete
```

---

### `Feature Flag`

**Definition.**
A configuration toggle that enables or disables
a feature without deploying new code. Feature flags
decouple deployment from feature availability.

**Context.**
Feature flags let you deploy code containing a new
feature but keep it turned off until you are ready.
If the feature causes problems, you turn off the
flag without a rollback.

**Example.**
```python
if feature_flags.get("new_checkout_flow"):
    return new_checkout()
else:
    return old_checkout()
```

---

### `Health Signal`

**Definition.**
A metric or check that indicates whether a
deployment is working correctly. Health signals
are the evidence used to make promotion or
rollback decisions.

**Context.**
The most common health signals are error rate,
latency, and resource usage. Custom health signals
can include business metrics like conversion rate
or order volume.

**Example.**
Health signals to monitor during a canary:
- HTTP 5xx error rate
- Response latency (p50, p95, p99)
- CPU and memory usage
- Application-specific health endpoints

---

### `Soak Time`

**Definition.**
The minimum duration a new version must run with
good health signals before it is promoted to the
next traffic stage or to full production.

**Context.**
Some bugs only appear under sustained load or
after time (memory leaks, connection pool exhaustion).
Soak time catches these issues before full rollout.

**Example.**
Policy: new versions must soak for at least
30 minutes at each canary stage before promotion.

---

## Key Commands Summary

```bash
# Blue/green lab
cd projects/blue-green-deployment-lab
./scripts/start.sh
./scripts/set_canary.sh <percentage>
./scripts/sample_traffic.sh <count>

# Kubernetes rollout
kubectl rollout status deployment/<name>
kubectl rollout undo deployment/<name>
kubectl rollout history deployment/<name>
```

---

## See Also

- [Kubernetes](./05_kubernetes.md)
- [SRE and Incident Management](./08_sre_and_incident_management.md)
- [Monitoring and Observability](./03_monitoring_and_observability.md)

---

> **Author** — Simon Parris | DevOps Reference Library
