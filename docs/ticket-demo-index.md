# Repeatable Ticket Demos

## Enterprise Program Standard

This module is part of a professional infrastructure training program (not a hobby lab).

Training expectations for this module:
- production-grade design and operational assumptions (multi-AZ/region, identity, logging, recovery)
- security controls and least-privilege decisions are part of the exercise, not optional add-ons
- audit awareness: change traceability, approvals, evidence, and rollback records should be captured
- failure domain analysis must be included (process, host/node, AZ/region, dependency, control plane)
- examples are learning-safe but mapped to enterprise patterns; avoid localhost-only reasoning during analysis
- exercises are repeatable without AI by following the documented commands, checklists, and runbooks

Use these as practice tickets. Reset and rerun anytime.

- `tickets/docker/TKT-001-crash-loop/`
- `tickets/docker/TKT-002-port-conflict/`
- `tickets/docker/TKT-003-volume-permission/`
- `tickets/docker/TKT-004-broken-entrypoint/`
- `tickets/docker/TKT-005-oom/`

Workflow per ticket:

1. Reproduce the incident
2. Gather logs/evidence
3. Confirm root cause
4. Apply fix
5. Write an incident summary in your own words
