#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

echo "Simulating backend failure using unwritable backend path"
terraform init -reconfigure -backend-config=backend/failure.hcl
