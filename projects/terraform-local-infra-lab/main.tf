locals {
  runtime_dir      = abspath(var.infra_root)
  deployment_name  = "${var.project_name}-${var.environment}"
  node_names       = [for i in range(var.instance_count) : format("%s-node-%02d", local.deployment_name, i + 1)]
  generated_at_utc = timestamp()

  app_config = {
    service = {
      name        = local.deployment_name
      environment = var.environment
      port        = var.app_port
      metrics     = true
    }
    feature_flags = var.feature_flags
    owners        = var.owners
    nodes         = local.node_names
  }
}

resource "random_pet" "deployment_id" {
  prefix = local.deployment_name
  length = 1
}

resource "local_file" "inventory" {
  filename        = "${local.runtime_dir}/${var.environment}-inventory.json"
  file_permission = "0644"
  content = jsonencode({
    deployment_id = random_pet.deployment_id.id
    environment   = var.environment
    owners        = var.owners
    app_port      = var.app_port
    nodes         = local.node_names
    generated_at  = local.generated_at_utc
    tags = {
      lab         = "terraform-local-infra"
      managed_by  = "terraform"
      repo_module = "DevOps"
    }
  })
}

resource "local_file" "app_config" {
  filename        = "${local.runtime_dir}/${var.environment}-app-config.yaml"
  file_permission = "0644"
  content         = yamlencode(local.app_config)
}

resource "local_sensitive_file" "db_secret" {
  filename          = "${local.runtime_dir}/${var.environment}-db-password.txt"
  file_permission   = "0600"
  sensitive_content = var.db_password
}

resource "local_file" "node_configs" {
  count           = length(local.node_names)
  filename        = "${local.runtime_dir}/${var.environment}-${count.index + 1}-node.yaml"
  file_permission = "0644"
  content = yamlencode({
    node_name    = local.node_names[count.index]
    environment  = var.environment
    app_port     = var.app_port
    metrics_path = "/metrics"
    labels = {
      role    = "app"
      ordinal = count.index + 1
    }
  })
}
