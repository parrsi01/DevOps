# SRE Simulation Lab Notes

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

Live project: `projects/sre-simulation-lab/`

Covers:

- SLIs / SLOs / error budgets
- latency monitoring (Prometheus queries + alert rules)
- downtime and traffic spike simulations
- scaling policy design
- incident response process
- blameless postmortem template
- reliability concepts (MTTR, MTBF, alert fatigue)

Dependency:

- Uses `projects/monitoring-stack-lab/` as the underlying runtime and metrics source.

Start here:

```bash
cd projects/monitoring-stack-lab && ./scripts/start.sh
cd ../sre-simulation-lab && ./scripts/preflight.sh
```
