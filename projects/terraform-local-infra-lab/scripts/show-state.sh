#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
terraform state list
printf '\nState file path (local backend): %s\n' "$(pwd)/runtime/terraform.local.tfstate"
