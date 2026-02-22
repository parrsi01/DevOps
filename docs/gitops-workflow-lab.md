# GitOps Workflow Lab Notes

## Enterprise Program Standard

This module is part of a professional infrastructure training program (not a hobby lab).

Training expectations for this module:
- production-grade design and operational assumptions (multi-AZ/region, identity, logging, recovery)
- security controls and least-privilege decisions are part of the exercise, not optional add-ons
- audit awareness: change traceability, approvals, evidence, and rollback records should be captured
- failure domain analysis must be included (process, host/node, AZ/region, dependency, control plane)
- examples are learning-safe but mapped to enterprise patterns; avoid localhost-only reasoning during analysis
- exercises are repeatable without AI by following the documented commands, checklists, and runbooks

Live project: `projects/gitops-workflow-lab/`

Covers:

- ArgoCD-based GitOps workflow (with tool-agnostic fallback explanation)
- declarative deployment model (Kustomize base + overlays)
- Git as source of truth
- rollback strategy (`git revert` + ArgoCD reconcile)
- version pinning and immutable image tag guidance (prefer digests)
- simulations (bad deploy rollback, drift, manual prod change, env version mismatch)
- deployment diagram and troubleshooting guide

Start here:

```bash
cd projects/gitops-workflow-lab
# install ArgoCD into your local cluster (after module 8 cluster setup)
./scripts/install_argocd_minikube.sh
./scripts/bootstrap_argocd_apps.sh
```
