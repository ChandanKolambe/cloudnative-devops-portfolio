# Terraform

This directory is the starting point for the project's infrastructure-as-code
work.

## Scope

- **Local:** Terraform's local provider is included for safe, local-only
  exercises and validation.
- **AWS:** The AWS provider is constrained and configured as a placeholder for
  future cloud resources. This milestone creates no AWS resources and does not
  require AWS credentials.

## Initialize

```bash
terraform -chdir=terraform init
terraform -chdir=terraform validate
```

The initialization command creates `.terraform.lock.hcl`, which must be
committed to keep provider selections reproducible.