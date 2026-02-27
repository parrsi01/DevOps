#!/usr/bin/env bash
set -euo pipefail


# Block 1 from 06-gitops-workflow
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,260p' projects/gitops-workflow-lab/README.md
ls -1 projects/gitops-workflow-lab/scripts


# Block 2 from 06-gitops-workflow
cd /home/sp/cyber-course/projects/DevOps/projects/gitops-workflow-lab
./scripts/install_argocd_minikube.sh
kubectl -n argocd get pods


# Block 3 from 06-gitops-workflow
./scripts/bootstrap_argocd_apps.sh
kubectl -n argocd get applications.argoproj.io
kubectl -n argocd port-forward svc/argocd-server 8080:443


# Block 4 from 06-gitops-workflow
./scripts/render_overlay.sh dev
./scripts/render_overlay.sh staging
./scripts/render_overlay.sh prod
./scripts/show_version_matrix.sh
./scripts/simulate_config_drift.sh
kubectl -n platform-prod scale deploy/podinfo --replicas=7
kubectl -n platform-prod get deploy podinfo
kubectl -n argocd get applications.argoproj.io podinfo-prod


# Block 5 from 06-gitops-workflow
kubectl -n platform-prod rollout status deploy/podinfo --timeout=180s
kubectl -n argocd get applications.argoproj.io podinfo-prod
# stop the port-forward with Ctrl+C in the terminal running it

