# Blue/Green Deployment Lab (Docker + Nginx)

Author: Simon Parris  
Date: 2026-02-22

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
