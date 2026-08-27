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