#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

echo "Simulating variable mismatch (invalid app_port)"
terraform plan -var-file=terraform.tfvars -var='app_port=70000'
