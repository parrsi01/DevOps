# Infrastructure as Code

---

> **Field** — DevOps / Infrastructure Engineering
> **Scope** — Terraform concepts, workflow, and state management from the local infrastructure lab

---

## Overview

Infrastructure as Code (IaC) means managing servers,
networks, and services through versioned configuration
files instead of manual commands. Terraform is the
primary IaC tool in this repository. The key skill
is predicting what will change before applying.

---

## Definitions

### `Infrastructure as Code`

**Definition.**
The practice of defining infrastructure (servers,
networks, storage) in text files that can be
versioned, reviewed, and applied automatically.

**Context.**
IaC makes infrastructure changes repeatable,
auditable, and reversible. Manual changes create
drift, knowledge silos, and untrackable risk.

**Example.**
Instead of clicking through a cloud console to
create a server, you write a `.tf` file and run
`terraform apply`.

---

### `Terraform`

**Definition.**
An open-source tool for declarative infrastructure
management. You describe the desired state of your
infrastructure in HCL files, and Terraform figures
out what changes are needed to reach that state.

**Context.**
Terraform is a controlled change system. The most
important skill is reading the plan output and
understanding what will happen before you apply.

**Example.**
```bash
terraform init    # download providers
terraform plan    # preview changes
terraform apply   # execute changes
terraform destroy # remove everything
```

---

### `Plan`

**Definition.**
A preview of the changes Terraform intends to make.
The plan shows what will be added (+), changed (~),
or destroyed (-) without actually making changes.

**Context.**
Always read the plan before applying. The plan is
your safety net. If it shows unexpected changes,
investigate before proceeding.

**Example.**
```bash
terraform plan
# Plan: 2 to add, 1 to change, 0 to destroy.
```

---

### `Apply`

**Definition.**
Execute the changes shown in the plan. Apply
creates, updates, or destroys infrastructure
resources to match the desired configuration.

**Context.**
Apply is the action step. After applying, run
plan again to verify the system is stable
(no further changes needed).

**Example.**
```bash
terraform apply
# creates/modifies resources as planned
# updates state file with new reality
```

---

### `State`

**Definition.**
Terraform's record of the infrastructure it manages.
The state file maps configuration resources to
real-world objects. Terraform uses state to determine
what changes are needed.

**Context.**
State is critical. If the state file is lost or
corrupted, Terraform loses track of what exists.
In teams, state is stored remotely (S3, GCS) to
prevent conflicts.

**Example.**
```bash
terraform state list
# shows all resources Terraform is tracking

terraform state show aws_instance.web
# shows details of a specific managed resource
```

---

### `Drift`

**Definition.**
When real infrastructure changes outside of
Terraform. Someone manually modified a resource,
but the Terraform state still reflects the old
configuration.

**Context.**
Drift is dangerous because Terraform's next plan
may try to "fix" the manual change. Detecting and
resolving drift is a key operational skill.

**Example.**
Someone manually changes a security group rule
in the cloud console. Next `terraform plan` shows
a change to revert it back to the configured state.

---

### `Idempotent`

**Definition.**
An operation is idempotent if running it multiple
times produces the same result as running it once.
After a successful apply, running plan again should
show no changes.

**Context.**
Idempotency is how you verify stability. If plan
keeps showing changes after apply, something is
wrong: a config issue, provider bug, or drift.

**Example.**
```bash
terraform apply   # makes changes
terraform plan    # should show: No changes.
```

---

### `Provider`

**Definition.**
A Terraform plugin that knows how to manage a
specific type of infrastructure. AWS, Azure, GCP,
Docker, and Kubernetes each have their own provider.

**Context.**
Provider errors during `terraform init` usually
mean the provider version is wrong, the network
is unreachable, or the provider is not configured.

**Example.**
```hcl
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}
```

---

### `HCL`

**Definition.**
HashiCorp Configuration Language. The declarative
language used to write Terraform configuration
files. HCL uses blocks, arguments, and expressions.

**Context.**
HCL looks like JSON but is designed to be
human-readable. Understanding block structure
(resource, variable, output, data) is essential
for reading and writing Terraform configs.

**Example.**
```hcl
resource "docker_container" "web" {
  name  = "my-web-app"
  image = docker_image.app.image_id
  ports {
    internal = 8080
    external = 80
  }
}
```

---

### `Module`

**Definition.**
A reusable package of Terraform configuration.
Modules let you group related resources and use
them across projects with different input variables.

**Context.**
Modules reduce duplication and enforce standards.
A "networking" module might create VPCs, subnets,
and security groups with consistent naming.

**Example.**
```hcl
module "network" {
  source = "./modules/networking"
  cidr   = "10.0.0.0/16"
  env    = "production"
}
```

---

### `Variable`

**Definition.**
An input parameter for a Terraform configuration.
Variables make configs reusable by letting you
change values without editing the main code.

**Context.**
Variables are defined in `.tf` files and values
are set in `.tfvars` files or environment variables.
Missing variables cause plan/apply failures.

**Example.**
```hcl
variable "environment" {
  type    = string
  default = "dev"
}
```
```bash
cp terraform.tfvars.example terraform.tfvars
# set your variable values
```

---

### `Output`

**Definition.**
A value that Terraform displays after apply and
makes available to other configurations. Outputs
expose important information like IP addresses,
URLs, or resource IDs.

**Context.**
Outputs are how you extract results from Terraform.
They also enable module composition by passing
values between modules.

**Example.**
```hcl
output "web_url" {
  value = "http://${docker_container.web.ports[0].external}"
}
```

---

### `Destroy`

**Definition.**
Remove all infrastructure managed by the current
Terraform configuration. This is the cleanup step
that tears down resources.

**Context.**
Destroy is irreversible for most cloud resources.
In lab environments, it returns you to a clean
state. In production, it requires extreme caution.

**Example.**
```bash
terraform destroy
# removes all managed resources
# updates state to reflect nothing exists
```

---

## Key Commands Summary

```bash
# Workflow
terraform init      # initialize, download providers
terraform plan      # preview changes
terraform apply     # execute changes
terraform destroy   # remove everything

# State inspection
terraform state list
terraform state show <resource>

# Variables
cp terraform.tfvars.example terraform.tfvars
terraform plan -var="env=staging"
```

---

## See Also

- [Kubernetes](./05_kubernetes.md)
- [GitOps and Version Control](./06_gitops_and_version_control.md)
- [Universal DevOps Concepts](./00_universal_devops_concepts.md)

---

> **Author** — Simon Parris | DevOps Reference Library
