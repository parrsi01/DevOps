#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

rm -rf .terraform
rm -f .terraform.lock.hcl
rm -f runtime/*.tfstate runtime/*.tfstate.* runtime/*.yaml runtime/*.json runtime/*.txt
rm -f tfplan
printf 'Terraform lab reset complete.\n'
