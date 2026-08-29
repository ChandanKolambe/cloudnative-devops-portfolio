output "namespace_name" {
  description = "Name of the managed Kubernetes namespace."
  value       = kubernetes_namespace_v1.cloudnative_devops.metadata[0].name
}

output "namespace_labels" {
  description = "Labels applied to the managed Kubernetes namespace."
  value       = kubernetes_namespace_v1.cloudnative_devops.metadata[0].labels
}

output "namespace_uid" {
  description = "UID assigned to the managed Kubernetes namespace."
  value       = kubernetes_namespace_v1.cloudnative_devops.metadata[0].uid
}