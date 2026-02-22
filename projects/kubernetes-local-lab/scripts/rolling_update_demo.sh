#!/usr/bin/env bash
set -euo pipefail
ns="platform-lab"

kubectl -n "$ns" set image deploy/podinfo podinfo=ghcr.io/stefanprodan/podinfo:6.7.2
kubectl -n "$ns" rollout status deploy/podinfo --timeout=120s
kubectl -n "$ns" rollout history deploy/podinfo

cat <<'MSG'
Rollback example:
  kubectl -n platform-lab rollout undo deploy/podinfo
MSG
