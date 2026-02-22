# Incident Response Process (SRE Lab)

Author: Simon Parris  
Date: 2026-02-22

## Goal

Provide a repeatable incident response process for the SRE simulations in this lab.

## Phases

1. Detect
2. Triage
3. Mitigate
4. Stabilize
5. Resolve
6. Recover and validate
7. Postmortem

## 1. Detect

Inputs:

- alerts (latency, error rate, target down)
- synthetic checks
- user reports
- dashboards/log anomalies

Actions:

- acknowledge alert
- record start time (used for MTTR)
- assign incident commander (even if one person)

## 2. Triage

Questions:

- What is impacted (all users, one endpoint, one environment)?
- Is this a total outage or partial outage?
- What changed recently (deploy, config, infra, traffic)?

Data to gather:

- current error rate
- current p95 latency
- availability status
- affected routes/services/dependencies

## 3. Mitigate

Focus on reducing user impact quickly.

Typical mitigation actions:

- rollback deployment/config
- scale out service
- shed load / rate-limit heavy traffic
- fail over / bypass dependency
- disable bad feature flag

## 4. Stabilize

- verify key SLIs stop degrading
- confirm alert noise decreases
- ensure no new failure mode is introduced

## 5. Resolve

- apply durable fix (not just temporary mitigation)
- validate in dashboards + logs + synthetic checks

## 6. Recover and Validate

Checklist:

- error rate near baseline
- latency within SLO targets
- dependencies healthy
- backlog/queues drained (if relevant)
- customer-facing functionality confirmed

## 7. Postmortem

- schedule within 1-3 business days
- use blameless format
- identify systemic fixes and owners
- track action items to completion
