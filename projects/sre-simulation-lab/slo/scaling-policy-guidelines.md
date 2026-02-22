# Scaling Policy Guidelines (SRE Lab)

Author: Simon Parris  
Date: 2026-02-22

## Goals

- protect latency SLO under traffic spikes
- avoid oscillation (thrash)
- scale down slowly to reduce instability
- leave headroom for burst traffic

## Baseline Policy (Example)

- Min replicas: `3`
- Max replicas: `12`
- Scale up target: CPU `60%`
- Scale up quickly (allow up to 100% growth/minute)
- Scale down slowly (stabilization window `300s`)

## Why this works

- fast scale-up protects user latency during sudden spikes
- slower scale-down avoids flapping when traffic is noisy
- minimum replicas preserve redundancy for partial failures

## When to change policy

- If latency breaches happen before scale-out: lower target or pre-scale
- If flapping occurs: increase scale-down stabilization window
- If cost is too high: tune requests, improve efficiency before shrinking safety margin
