#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
kubectl delete -f manifests/base --ignore-not-found=true
