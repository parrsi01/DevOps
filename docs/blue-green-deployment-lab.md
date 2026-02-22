# Blue/Green Deployment Lab (Docker + Nginx)

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

## Summary

This lab provides a local, repeatable blue/green deployment simulation using Docker Compose and Nginx.

It demonstrates:
- two version deployments (`blue-v1`, `green-v2`)
- traffic switching (`0%`, `100%`, and canary percentages)
- health-gated cutover
- rollback strategy
- failure scenarios across app + router + shared data

## Live Project

- `../projects/blue-green-deployment-lab/README.md`

## Key Exercises

- Canary rollout to green and validate traffic split
- Health-based cutover (abort when unhealthy)
- Bad deployment rollback
- Partial rollback to reduce blast radius
- Data compatibility rollback trap (schema mismatch)

## Why This Matters

This is a practical bridge between Docker-only deployments and more advanced rollout strategies used in Kubernetes or GitOps systems.

It teaches the core operational reasoning behind:
- release safety checks
- progressive delivery
- rollback readiness
- backward-compatible data migrations
