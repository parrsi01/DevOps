#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

for env in dev staging prod; do
  file="apps/overlays/${env}/patch-deployment.yaml"
  image=$(awk '/image:/{print $2}' "$file")
  replicas=$(awk '/replicas:/{print $2; exit}' "$file")
  echo "$env  image=$image  replicas=$replicas"
done
