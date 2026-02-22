# Terraform Local Infrastructure Lab Notes

Live project: `projects/terraform-local-infra-lab/`

Covers:

- variables and validation
- outputs
- state file (local backend) explanation
- remote state explanation (`terraform_remote_state` demo)
- idempotency
- `plan` vs `apply`
- `destroy`
- failure simulations (drift, manual change, variable mismatch, backend failure)
- debugging workflow

Start here:

```bash
cd projects/terraform-local-infra-lab
cp terraform.tfvars.example terraform.tfvars
./scripts/init.sh
./scripts/plan.sh
```

Note: Install Terraform CLI first (`terraform version`).
