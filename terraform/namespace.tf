resource "kubernetes_namespace_v1" "cloudnative_devops" {
  metadata {
    name   = var.namespace_name
    labels = var.namespace_labels
  }
}