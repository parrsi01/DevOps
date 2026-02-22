variable "project_name" {
  description = "Logical project name used in generated artifacts."
  type        = string
  default     = "terraform-lab-app"

  validation {
    condition     = length(trimspace(var.project_name)) >= 3
    error_message = "project_name must be at least 3 characters."
  }
}

variable "environment" {
  description = "Environment name (dev/stage/prod)."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "environment must be one of: dev, stage, prod."
  }
}

variable "app_port" {
  description = "Application port used in generated config."
  type        = number
  default     = 8080

  validation {
    condition     = var.app_port >= 1024 && var.app_port <= 65535
    error_message = "app_port must be between 1024 and 65535."
  }
}

variable "instance_count" {
  description = "How many synthetic app nodes to model."
  type        = number
  default     = 2

  validation {
    condition     = floor(var.instance_count) == var.instance_count && var.instance_count >= 1 && var.instance_count <= 10
    error_message = "instance_count must be a whole number between 1 and 10."
  }
}

variable "owners" {
  description = "Owner/user handles for the infrastructure inventory."
  type        = list(string)
  default     = ["parrsi01"]

  validation {
    condition     = length(var.owners) > 0 && alltrue([for o in var.owners : length(trimspace(o)) > 0])
    error_message = "owners must contain at least one non-empty value."
  }
}

variable "feature_flags" {
  description = "Feature flags rendered into app config."
  type        = map(bool)
  default = {
    metrics_enabled = true
    debug_mode      = false
  }
}

variable "db_password" {
  description = "Demo-only password written to a local sensitive file to illustrate state sensitivity."
  type        = string
  sensitive   = true
  nullable    = false

  validation {
    condition     = length(var.db_password) >= 12
    error_message = "db_password must be at least 12 characters."
  }
}

variable "infra_root" {
  description = "Local directory where Terraform writes managed lab artifacts."
  type        = string
  default     = "runtime"

  validation {
    condition     = length(trimspace(var.infra_root)) > 0
    error_message = "infra_root cannot be empty."
  }
}
