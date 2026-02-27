#!/usr/bin/env bash
set -euo pipefail


# Block 1 from 04-terraform-local-infra
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,220p' projects/terraform-local-infra-lab/README.md
terraform version


# Block 2 from 04-terraform-local-infra
cd /home/sp/cyber-course/projects/DevOps/projects/terraform-local-infra-lab
cp terraform.tfvars.example terraform.tfvars
./scripts/init.sh


# Block 3 from 04-terraform-local-infra
./scripts/plan.sh
terraform fmt -check
terraform validate


# Block 4 from 04-terraform-local-infra
./scripts/apply.sh -auto-approve
terraform output
ls -l runtime/
./scripts/plan.sh


# Block 5 from 04-terraform-local-infra
./scripts/destroy.sh -auto-approve
./scripts/reset.sh

