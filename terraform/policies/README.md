# OPA and Checkov policy examples

Keep these as CI checks in the account repository. Start with simple controls:

- every resource has an owner, environment and cost-center tag;
- data subnets do not receive a direct internet route;
- S3 state and logs are encrypted;
- IAM policies do not use unrestricted administrative actions without an exception;
- resources deploy only in approved regions;
- security groups do not allow unrestricted ingress.

Checkov can evaluate Terraform configuration and plan output. OPA can evaluate organization-specific rules after Terraform produces a normalized plan. Veracode can remain the primary application and IaC scanning platform if that is the client standard. The exact rules, severities and exception process must be agreed before enforcement.
