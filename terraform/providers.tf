provider "local" {}

# Placeholder for future AWS resources. No AWS resources are managed yet.
provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.kube_context
}