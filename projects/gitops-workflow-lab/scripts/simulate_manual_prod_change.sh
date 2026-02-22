#!/usr/bin/env bash
set -euo pipefail

cat <<'MSG'
Simulate manual production change (anti-pattern)

Example change:
  kubectl -n platform-prod set image deploy/podinfo podinfo=ghcr.io/stefanprodan/podinfo:latest

Reasoning:
- Cluster changes immediately, but Git still defines the previous pinned digest.
- ArgoCD detects drift and reverts back to Git desired state (if self-heal enabled).
- If self-heal is disabled, prod remains divergent until manual sync.

Check:
  kubectl -n platform-prod get deploy podinfo -o jsonpath='{.spec.template.spec.containers[0].image}'; echo
  argocd app diff podinfo-prod
MSG
