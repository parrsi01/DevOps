#!/usr/bin/env bash
set -euo pipefail

cat <<'MSG'
Terraform Debug Workflow (Local Lab)

1. Check syntax / initialization
   terraform fmt -check
   terraform validate
   terraform init -reconfigure -backend-config=backend/local.hcl

2. Inspect variables actually in use
   cat terraform.tfvars
   terraform plan -var-file=terraform.tfvars

3. Inspect state (if apply has been run)
   terraform state list
   terraform show
   terraform state show local_file.app_config

4. Detect drift or manual changes
   terraform plan -refresh-only -var-file=terraform.tfvars
   terraform plan -var-file=terraform.tfvars

5. Recover backend issues
   terraform init -reconfigure -backend-config=backend/local.hcl

6. Reconcile safely
   terraform apply -var-file=terraform.tfvars

7. Clean teardown
   terraform destroy -var-file=terraform.tfvars
MSG
