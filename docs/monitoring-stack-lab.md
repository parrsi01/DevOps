# Monitoring Stack Lab Notes

## Enterprise Program Standard

This module is part of a professional infrastructure training program (not a hobby lab).

Training expectations for this module:
- production-grade design and operational assumptions (multi-AZ/region, identity, logging, recovery)
- security controls and least-privilege decisions are part of the exercise, not optional add-ons
- audit awareness: change traceability, approvals, evidence, and rollback records should be captured
- failure domain analysis must be included (process, host/node, AZ/region, dependency, control plane)
- examples are learning-safe but mapped to enterprise patterns; avoid localhost-only reasoning during analysis
- exercises are repeatable without AI by following the documented commands, checklists, and runbooks

Live project: `projects/monitoring-stack-lab/`

Covers:

- Prometheus
- Grafana
- Loki / Promtail
- App metrics endpoint
- Container metrics (`cAdvisor`)
- System metrics (`node-exporter`)
- Dashboards (CPU, memory, request rate, error rate)
- Simulations (CPU/memory/db latency/log anomaly)
- SLI / SLO basics

Start here:

```bash
cd projects/monitoring-stack-lab
./scripts/start.sh
```
