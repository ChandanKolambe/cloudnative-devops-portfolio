variable "kubeconfig_path" {
  description = "Path to the kubeconfig used by the Kubernetes provider."
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "Kubernetes context where the namespace is managed."
  type        = string
  default     = "kind-cloudnative-cluster"
}

variable "namespace_name" {
  description = "Name of the application namespace."
  type        = string
  default     = "cloudnative-devops"
}

variable "namespace_labels" {
  description = "Labels applied to the managed namespace."
  type        = map(string)
  default = {
    "app.kubernetes.io/managed-by"       = "terraform"
    environment                          = "local"
    "pod-security.kubernetes.io/enforce" = "baseline"
    "pod-security.kubernetes.io/warn"    = "restricted"
  }
}