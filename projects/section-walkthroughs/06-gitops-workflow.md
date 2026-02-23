# Section 6 - GitOps Workflow Lab

Source docs:

- `docs/gitops-workflow-lab.md`
- `projects/gitops-workflow-lab/README.md`

## What Type Of Software Engineering This Is

Release engineering and platform operations with Git as the source of truth (GitOps).

## Definitions

- `GitOps`: operating deployments by changing Git, not by manual cluster edits.
- `desired state`: what Git/manifests say should exist.
- `reconciler`: controller (ArgoCD) that syncs cluster state to Git state.
- `drift`: cluster state changed outside Git.
- `rollback`: reverting Git/application revision to a known-good state.

## Concepts And Theme

Manual cluster fixes may be temporary. Permanent fixes must be committed to Git.

## 1. Step 1 - Read the workflow and check script inventory

```bash
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,260p' projects/gitops-workflow-lab/README.md
ls -1 projects/gitops-workflow-lab/scripts
```

What you are doing: understanding the GitOps model and the local helper scripts before installing ArgoCD.

## 2. Step 2 - Install ArgoCD on the local cluster (requires Section 5 cluster)

```bash
cd /home/sp/cyber-course/projects/DevOps/projects/gitops-workflow-lab
./scripts/install_argocd_minikube.sh
kubectl -n argocd get pods
```

What you are doing: installing the reconciler (ArgoCD) so Git changes can be synced to Kubernetes.

## 3. Step 3 - Bootstrap applications and inspect sync status

```bash
./scripts/bootstrap_argocd_apps.sh
kubectl -n argocd get applications.argoproj.io
kubectl -n argocd port-forward svc/argocd-server 8080:443
```

What you are doing: creating the demo GitOps Applications and opening the ArgoCD UI access path.

Note: keep the port-forward terminal running while you inspect the UI.

## 4. Step 4 - Render manifests and practice drift reasoning

```bash
./scripts/render_overlay.sh dev
./scripts/render_overlay.sh staging
./scripts/render_overlay.sh prod
./scripts/show_version_matrix.sh
./scripts/simulate_config_drift.sh
kubectl -n platform-prod scale deploy/podinfo --replicas=7
kubectl -n platform-prod get deploy podinfo
kubectl -n argocd get applications.argoproj.io podinfo-prod
```

What you are doing: comparing environment overlays, then creating manual drift to observe how GitOps detects and corrects it.

## 5. Step 5 - Restore state and stop port-forward

```bash
kubectl -n platform-prod rollout status deploy/podinfo --timeout=180s
kubectl -n argocd get applications.argoproj.io podinfo-prod
# stop the port-forward with Ctrl+C in the terminal running it
```

What you are doing: confirming reconciliation completed and ending the temporary UI access session.

## Done Check

You can explain why `kubectl edit` or `kubectl scale` can be a valid emergency action but not a permanent GitOps fix.
