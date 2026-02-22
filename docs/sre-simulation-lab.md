# SRE Simulation Lab Notes

Author: Simon Parris  
Date: 2026-02-22

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
