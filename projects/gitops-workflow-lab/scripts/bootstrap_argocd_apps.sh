#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

kubectl apply -f argocd/project.yaml
kubectl apply -f argocd/root-app.yaml
kubectl apply -f argocd/applications/

kubectl -n argocd get applications.argoproj.io
