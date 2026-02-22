terraform {
  required_version = ">= 1.5.0"
}

data "terraform_remote_state" "producer" {
  backend = "local"

  config = {
    path = "../producer/terraform.tfstate"
  }
}

output "imported_service_name" {
  value = data.terraform_remote_state.producer.outputs.service_name
}

output "imported_service_endpoint" {
  value = data.terraform_remote_state.producer.outputs.service_endpoint
}
