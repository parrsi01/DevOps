#!/usr/bin/env bash
set -euo pipefail

cat <<'MSG'
Simulate config drift (cluster differs from Git desired state)

Manual drift command example (prod):
  kubectl -n platform-prod scale deploy/podinfo --replicas=7

Observe:
  kubectl -n platform-prod get deploy podinfo
  kubectl -n argocd get applications.argoproj.io podinfo-prod
  argocd app get podinfo-prod

Expected with self-heal enabled:
  ArgoCD marks app OutOfSync, then reconciles replicas back to Git value.
MSG
