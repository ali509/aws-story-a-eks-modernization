# Terraform reference

This is the small HCL reference requested by sections 3.1 and 3.2 of the assignment. It intentionally separates reusable modules from account roots.

```text
modules-repo/              # versioned and reused by account repositories
  modules/tgw-attachment/
  modules/eks-mixed-node-groups/

account-foundation-repo/    # account-specific composition and state
  examples/dev/
  backend/
  policies/
```

The examples demonstrate the requested TGW attachment/association and mixed Linux/Windows managed node groups. They do not include provider credentials, account IDs, IAM roles, RAM sharing or every route. Those are client-specific inputs.

## Policy gates

The assignment explicitly calls for OPA/Checkov policy-as-code. A practical CI sequence is `terraform fmt`, `terraform validate`, `terraform plan`, Checkov evaluation of the plan/configuration and OPA evaluation of organization rules. Examples of rules are required tags, encryption, no public data subnets, approved regions and no unrestricted ingress. Veracode can remain the application/IaC scanning platform where the client already standardizes on it.

## State

Use an encrypted, versioned S3 backend per account, environment and stack. The backend file uses reference names for the development environment. Validate the bucket, region and locking approach before use. Confirm whether the client requires legacy DynamoDB locking or native S3 locking for the selected Terraform version.
