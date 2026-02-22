# Terraform Local Infrastructure Lab Notes

## Enterprise Program Standard

This module is part of a professional infrastructure training program (not a hobby lab).

Training expectations for this module:
- production-grade design and operational assumptions (multi-AZ/region, identity, logging, recovery)
- security controls and least-privilege decisions are part of the exercise, not optional add-ons
- audit awareness: change traceability, approvals, evidence, and rollback records should be captured
- failure domain analysis must be included (process, host/node, AZ/region, dependency, control plane)
- examples are learning-safe but mapped to enterprise patterns; avoid localhost-only reasoning during analysis
- exercises are repeatable without AI by following the documented commands, checklists, and runbooks

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
