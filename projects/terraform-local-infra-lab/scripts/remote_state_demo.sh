#!/usr/bin/env bash
set -euo pipefail
root="$(dirname "$0")/.."

pushd "$root/remote-state-demo/producer" >/dev/null
terraform init
terraform apply -auto-approve
popd >/dev/null

pushd "$root/remote-state-demo/consumer" >/dev/null
terraform init
terraform apply -auto-approve
terraform output
popd >/dev/null
