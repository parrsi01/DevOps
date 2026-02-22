output "deployment_id" {
  description = "Synthetic deployment ID generated for the lab run."
  value       = random_pet.deployment_id.id
}

output "runtime_directory" {
  description = "Absolute path where Terraform writes local artifacts."
  value       = abspath(var.infra_root)
}

output "managed_files" {
  description = "Managed files created by the lab."
  value = concat(
    [local_file.inventory.filename, local_file.app_config.filename, local_sensitive_file.db_secret.filename],
    [for f in local_file.node_configs : f.filename]
  )
  sensitive = true
}

output "node_names" {
  description = "Synthetic node names for the local lab inventory."
  value       = local.node_names
}

output "plan_apply_destroy_summary" {
  description = "Quick reminder of Terraform workflow."
  value = {
    plan    = "Preview changes before apply"
    apply   = "Create/update to match configuration"
    destroy = "Tear down Terraform-managed resources"
  }
}
