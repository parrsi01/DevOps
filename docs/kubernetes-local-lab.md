# Kubernetes Local Lab Notes

## Enterprise Program Standard

This module is part of a professional infrastructure training program (not a hobby lab).

Training expectations for this module:
- production-grade design and operational assumptions (multi-AZ/region, identity, logging, recovery)
- security controls and least-privilege decisions are part of the exercise, not optional add-ons
- audit awareness: change traceability, approvals, evidence, and rollback records should be captured
- failure domain analysis must be included (process, host/node, AZ/region, dependency, control plane)
- examples are learning-safe but mapped to enterprise patterns; avoid localhost-only reasoning during analysis
- exercises are repeatable without AI by following the documented commands, checklists, and runbooks

Live project: `projects/kubernetes-local-lab/`

Covers:

- Minikube or K3s local cluster setup
- `kubectl` configuration
- namespaces, pods, deployments, ReplicaSets
- services (`ClusterIP`, `NodePort`)
- ingress controller
- ConfigMaps and Secrets
- requests/limits
- HPA autoscaling
- rolling updates
- failure simulations and troubleshooting

Start here:

```bash
cd projects/kubernetes-local-lab
./scripts/start_minikube.sh    # preferred path
./scripts/apply_base.sh
```

If using K3s instead, read `./scripts/start_k3s.sh` first and adjust ingress class if needed.
