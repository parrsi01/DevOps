# GitOps Workflow Lab Notes

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
