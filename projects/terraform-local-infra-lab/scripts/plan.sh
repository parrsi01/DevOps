#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
terraform plan -var-file=terraform.tfvars "$@"
