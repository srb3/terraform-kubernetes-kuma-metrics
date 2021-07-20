provider "kubernetes" {
  config_path = var.kube_config_file
}

module "kuma_metrics" {
  source = "../../"
}

output "kuma_metrics" {
  value = module.kuma_metrics
}

locals {
  attrs = {
    namespace = var.namespace
  }
}
