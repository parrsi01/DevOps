#!/usr/bin/env bash
set -euo pipefail
ns="platform-lab"

kubectl -n "$ns" run hpa-loadgen --image=busybox:1.36 --restart=Never \
  -- /bin/sh -c 'while true; do wget -q -O- http://hpa-demo >/dev/null; done'

cat <<'MSG'
Load generator started.
Watch autoscaling with:
  kubectl -n platform-lab get hpa -w
  kubectl -n platform-lab get deploy hpa-demo -w
Delete when done:
  kubectl -n platform-lab delete pod hpa-loadgen
MSG
