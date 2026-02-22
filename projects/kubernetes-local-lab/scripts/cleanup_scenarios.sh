#!/usr/bin/env bash
set -euo pipefail
ns="platform-lab"
for d in crashloop-demo imagepull-demo oom-demo liveness-fail-demo readiness-fail-demo; do
  kubectl -n "$ns" delete deploy "$d" --ignore-not-found=true
done
for s in podinfo-broken; do
  kubectl -n "$ns" delete svc "$s" --ignore-not-found=true
done
for i in podinfo-broken; do
  kubectl -n "$ns" delete ingress "$i" --ignore-not-found=true
done
