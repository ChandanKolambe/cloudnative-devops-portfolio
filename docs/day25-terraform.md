# Day 25: Terraform Introduction

Terraform is introduced as the next infrastructure-as-code layer for the
portfolio. The initial module is intentionally small: it validates locally
and keeps AWS ready for a later milestone without provisioning cloud resources.

## Commands

```bash
terraform version
terraform -chdir=terraform init
terraform -chdir=terraform fmt -check
terraform -chdir=terraform validate
terraform -chdir=terraform providers
terraform -chdir=terraform plan
```

Run `terraform init` first. It downloads the constrained providers and creates
`.terraform.lock.hcl`; commit that lock file after reviewing the diff.

## Evidence checklist

- Terraform version is available.
- Initialization completes and provider selections are locked.
- Formatting and validation pass.
- `plan` confirms that no resources are scheduled.
- `tree terraform` shows the module structure.

## Suggested screenshots

- Successful `terraform init`, including both provider selections and the lock-file message.
- `tree terraform` showing `versions.tf`, `providers.tf`, `README.md`, and `.terraform.lock.hcl`.
- The Terraform scope section in `terraform/README.md` showing local-only validation and the AWS placeholder.

## Day 26: Local Namespace Management

The Kubernetes provider now manages the `cloudnative-devops` namespace in the
local KinD cluster. Namespace naming and labels are configurable Terraform
variables, and the namespace name, labels, and UID are exposed as outputs.

## Commands

```bash
terraform -chdir=terraform init
terraform -chdir=terraform fmt -check
terraform -chdir=terraform validate
terraform -chdir=terraform plan
terraform -chdir=terraform apply
kubectl get namespace cloudnative-devops --show-labels
terraform -chdir=terraform destroy
terraform -chdir=terraform apply
```

## Evidence checklist

- The plan shows `kubernetes_namespace_v1.cloudnative_devops` to be created or updated.
- Apply completes and prints the namespace outputs.
- `kubectl get namespace cloudnative-devops --show-labels` confirms the namespace and Terraform labels.
- Destroy removes the namespace, and a second apply recreates it.

## Suggested screenshots

- Terraform plan showing the Kubernetes namespace resource and its labels.
- Terraform apply output showing `namespace_name`, `namespace_labels`, and `namespace_uid`.
- `kubectl get namespace cloudnative-devops --show-labels` showing `Active` and the managed-by label.
- Terraform destroy completion followed by the recreate apply.