# Section 4 - Terraform Local Infrastructure

Source docs:

- `docs/terraform-local-infra-lab.md`
- `projects/terraform-local-infra-lab/README.md`

## What Type Of Software Engineering This Is

Infrastructure as Code (IaC) engineering: predictable change management using code, plans, state, and repeatable execution.

## Definitions

- `plan`: preview of what Terraform will change.
- `apply`: execution of the planned changes.
- `state`: Terraform's record of managed resources.
- `drift`: actual infrastructure differs from desired code/state.
- `idempotent`: re-running produces no extra changes when already correct.

## Concepts And Theme

Read the plan before applying. Terraform is about controlled change, not fast clicking.

## 1. Step 1 - Read the lab and verify Terraform exists

```bash
cd /home/sp/cyber-course/projects/DevOps
sed -n '1,220p' projects/terraform-local-infra-lab/README.md
terraform version
```

What you are doing: confirming the workflow and checking the required CLI is installed.

## 2. Step 2 - Create variables file and initialize Terraform

```bash
cd /home/sp/cyber-course/projects/DevOps/projects/terraform-local-infra-lab
cp terraform.tfvars.example terraform.tfvars
./scripts/init.sh
```

What you are doing: preparing input values and initializing backend/providers so Terraform can plan safely.

## 3. Step 3 - Run and read the plan

```bash
./scripts/plan.sh
terraform fmt -check
terraform validate
```

What you are doing: previewing changes and validating Terraform syntax/style before any apply.

## 4. Step 4 - Apply once, inspect outputs, then test idempotency

```bash
./scripts/apply.sh -auto-approve
terraform output
ls -l runtime/
./scripts/plan.sh
```

What you are doing: applying the local-safe infrastructure, checking generated outputs/files, and proving the second plan is stable (no-op or minimal expected change).

## 5. Step 5 - Tear down and reset

```bash
./scripts/destroy.sh -auto-approve
./scripts/reset.sh
```

What you are doing: removing managed local resources and resetting the lab for repeat practice.

## Done Check

You can explain the difference between `plan`, `apply`, `state`, and `drift` without mixing them up.
