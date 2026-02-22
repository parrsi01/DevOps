terraform {
  required_version = ">= 1.5.0"

  backend "local" {
    path = "terraform.tfstate"
  }
}

locals {
  service_name = "demo-api"
  port         = 9000
  endpoint     = "http://127.0.0.1:${local.port}"
}

output "service_name" {
  value = local.service_name
}

output "service_port" {
  value = local.port
}

output "service_endpoint" {
  value = local.endpoint
}
