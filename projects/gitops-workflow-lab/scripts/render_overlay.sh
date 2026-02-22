#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

env_name="${1:-dev}"
path="apps/overlays/${env_name}"

if [ ! -d "$path" ]; then
  echo "Unknown overlay: $env_name"
  exit 1
fi

if command -v kubectl >/dev/null 2>&1; then
  kubectl kustomize "$path"
elif command -v kustomize >/dev/null 2>&1; then
  kustomize build "$path"
else
  echo "Install kubectl or kustomize to render overlays"
  exit 1
fi
