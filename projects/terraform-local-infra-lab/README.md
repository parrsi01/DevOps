# Terraform Local Infrastructure Lab

Production-style Terraform practice without cloud costs.

This lab uses local files as "infrastructure" so you can safely learn Terraform workflows:

- variables
- outputs
- state file behavior
- remote state concepts
- idempotency
- `plan` vs `apply`
- `destroy`
- failure simulations and debugging

## What This Lab Builds (Locally)

Terraform manages files under `runtime/` to represent a small app deployment:

- inventory file (`dev-inventory.json`)
- app config (`dev-app-config.yaml`)
- per-node config files (`dev-1-node.yaml`, etc.)
- a sensitive password file (`dev-db-password.txt`)

These are local stand-ins for cloud resources (instances, config, secrets).

## Prerequisites

- Terraform CLI installed (`terraform version`)

This VM currently did not have Terraform installed when this lab was added, so validate after installing:

```bash
terraform fmt -check
terraform validate
```

## Files (Core)

- `versions.tf` - Terraform version, providers, local backend declaration
- `variables.tf` - typed inputs + validation rules
- `main.tf` - local resources and generated configs
- `outputs.tf` - values shown after apply
- `terraform.tfvars.example` - example variable values
- `backend/local.hcl` - working local backend path
- `backend/failure.hcl` - intentional backend failure config

## Quick Start (Step-by-Step)

1. Create `terraform.tfvars`

```bash
cd projects/terraform-local-infra-lab
cp terraform.tfvars.example terraform.tfvars
```

2. Initialize backend/providers

```bash
./scripts/init.sh
```

3. Preview changes (`plan`)

```bash
./scripts/plan.sh
```

4. Apply changes

```bash
./scripts/apply.sh -auto-approve
```

5. Inspect outputs and generated files

```bash
terraform output
ls -l runtime/
cat runtime/dev-inventory.json | jq .
```

6. Destroy when finished

```bash
./scripts/destroy.sh -auto-approve
```

## Variables (What They Teach)

Defined in `variables.tf` with type checking and validation.

Examples:

- `environment` (`dev` / `stage` / `prod`)
- `app_port` (validated port range)
- `instance_count` (validated integer range)
- `owners` (non-empty list)
- `feature_flags` (map of booleans)
- `db_password` (sensitive variable, min length validation)

Why this matters in production:

- catches bad inputs before infra changes
- makes modules reusable across environments
- reduces config drift caused by ad-hoc values

## Outputs (What They Teach)

Defined in `outputs.tf`.

Examples included:

- synthetic deployment ID
- runtime directory path
- node names
- managed file list (marked sensitive)

Why outputs matter:

- expose important values after `apply`
- feed other modules or automation pipelines
- enable remote-state consumers (with care)

## `plan` vs `apply` (Critical Terraform Habit)

## `terraform plan`

- calculates what Terraform *would* change
- does not modify infrastructure
- use this before every apply in real workflows

## `terraform apply`

- performs the changes needed to match configuration
- updates the state file after successful changes
- should be gated/reviewed in team environments

Recommended habit:

1. `plan`
2. review changes carefully
3. `apply`

## Idempotency (Core Terraform Concept)

Terraform is designed to be idempotent:

- Running `apply` repeatedly with the same config and same real infrastructure should produce no changes.

In this lab:

- Run `./scripts/apply.sh -auto-approve` twice.
- The second run should show no changes (unless there is drift or a changed input).

Why this matters:

- safe repeat execution in automation/CI pipelines
- predictable rollouts
- easier troubleshooting

## State File Explanation (Local Backend)

This lab uses a local backend (`backend/local.hcl`) writing state to:

- `runtime/terraform.local.tfstate`

What the state file does:

- maps Terraform resources to real objects (here: local files)
- stores metadata and resource IDs/attributes
- lets Terraform compare desired config vs actual tracked resources

Important note:

- State can contain sensitive data (directly or indirectly).
- Do not commit real state files to Git.
- This repo ignores local state via `.gitignore` in this lab folder.

Useful commands:

```bash
terraform state list
terraform show
./scripts/show-state.sh
```

## Remote State Explanation (Concept + Demo)

Remote state means storing Terraform state outside the local machine (for example S3, GCS, Azure Blob, Terraform Cloud) so teams/automation can share it safely.

Benefits:

- team access to the same state
- safer collaboration than emailing `.tfstate`
- state locking (backend-dependent) reduces concurrent-change corruption

Risks / cautions:

- state can expose secrets
- consumers become coupled to producer outputs
- backend outages block `init/plan/apply`

This lab includes a local demo of the concept:

- `remote-state-demo/producer/` - produces outputs
- `remote-state-demo/consumer/` - reads outputs using `terraform_remote_state`

Run demo (after Terraform install):

```bash
./scripts/remote_state_demo.sh
```

## `destroy` (Teardown)

`terraform destroy` removes Terraform-managed resources.

In this lab it deletes the managed files created in `runtime/`.

Use:

```bash
./scripts/destroy.sh -auto-approve
```

Why practice destroy:

- proves you can cleanly tear down managed infrastructure
- catches unmanaged leftovers or manual hotfix artifacts
- teaches lifecycle discipline

## Simulations (Required Failure Drills)

## 1. State Drift

Drift = real infrastructure changed outside Terraform, so state/config no longer match reality.

Simulate:

```bash
./scripts/simulate_state_drift.sh
./scripts/plan.sh
```

What happens:

- Script edits a Terraform-managed file (`runtime/dev-app-config.yaml`)
- `plan` should detect and propose correction

Resolution:

```bash
./scripts/apply.sh -auto-approve
```

## 2. Manual Infrastructure Change

Manual change = out-of-band change not managed by Terraform.

Simulate:

```bash
./scripts/simulate_manual_change.sh
./scripts/plan.sh
```

What happens:

- Script creates `runtime/manual-hotfix.txt` (unmanaged file)
- Terraform may show **no changes** because it does not track that file

Lesson:

- Not all real-world changes are visible in Terraform plans
- You still need ops hygiene, reviews, and file/system checks

## 3. Variable Mismatch

Simulate invalid input:

```bash
./scripts/simulate_variable_mismatch.sh
```

Expected result:

- `terraform plan` fails validation (`app_port=70000`)

Resolution:

- fix the variable value
- rerun `./scripts/plan.sh`

## 4. Backend Failure

Simulate backend initialization failure:

```bash
./scripts/simulate_backend_failure.sh
```

Expected result:

- `terraform init` fails because backend path is unwritable (`/root/...`)

Resolution:

```bash
./scripts/init.sh
```

## Debugging Workflow (Step-by-Step)

Use this flow whenever Terraform behaves unexpectedly.

1. Confirm you are in the right folder

```bash
pwd
ls -1 *.tf
```

2. Confirm backend and providers are initialized

```bash
terraform init -reconfigure -backend-config=backend/local.hcl
```

3. Validate configuration and formatting

```bash
terraform fmt -check
terraform validate
```

4. Inspect inputs

```bash
cat terraform.tfvars
terraform plan -var-file=terraform.tfvars
```

5. Inspect state (if apply has already run)

```bash
terraform state list
terraform show
terraform state show local_file.app_config
```

6. Check for drift vs unmanaged manual changes

```bash
terraform plan -refresh-only -var-file=terraform.tfvars
terraform plan -var-file=terraform.tfvars
ls -l runtime/
```

7. Reconcile carefully

- If drift is expected and config is source of truth: `apply`
- If manual change is intentional: update Terraform config to represent it
- If backend broke: re-run `init` with working backend config

8. Clean teardown and reset when done

```bash
./scripts/destroy.sh -auto-approve
./scripts/reset.sh
```

## Command Cheatsheet

```bash
cp terraform.tfvars.example terraform.tfvars
./scripts/init.sh
./scripts/plan.sh
./scripts/apply.sh -auto-approve
terraform output
terraform state list
terraform show
./scripts/destroy.sh -auto-approve
./scripts/reset.sh
```
