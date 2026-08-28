# Terraform

This directory manages the project's infrastructure-as-code work.

## Scope

- **Local:** Terraform's local and Kubernetes providers support safe, local
  KinD exercises and validation.
- **AWS:** The AWS provider is constrained and configured as a placeholder for
  future cloud resources. This milestone creates no AWS resources and does not
  require AWS credentials.

## Initialize

```bash
terraform -chdir=terraform init
terraform -chdir=terraform fmt -check
terraform -chdir=terraform validate
terraform -chdir=terraform plan
terraform -chdir=terraform apply
```

The Kubernetes provider uses `~/.kube/config` and the
`kind-cloudnative-cluster` context by default. Override `kubeconfig_path`,
`kube_context`, `namespace_name`, or `namespace_labels` with `-var` when
needed. The initialization command updates `.terraform.lock.hcl`, which must
be committed to keep provider selections reproducible.