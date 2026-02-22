#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
terraform destroy -var-file=terraform.tfvars "$@"
