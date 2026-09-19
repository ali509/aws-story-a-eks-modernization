# AWS Story A - Take-Home Submission

This package presents an enterprise AWS modernization and multi-account EKS migration design. It includes the client presentation, editable architecture diagram, Terraform reference structure, operational diagnostics, Well-Architected controls and statement of work required for Story A.

## Start here

1. Open `Story_A_Simplified_Presentation.pptx` for the client presentation.
2. Open `AWS-Architecture.drawio` in diagrams.net for the editable AWS architecture.
3. Use `AWS-Architecture.drawio.svg` for a quick visual preview.
4. Use the architecture, Terraform, operations, Well-Architected and SOW documents for implementation detail.

## Package contents

- `docs/Architecture_Reference.md` - target architecture, boundaries, flows and trade-offs.
- `terraform/` - reusable-module and account-foundation reference structure, including TGW and mixed Linux/Windows EKS examples.
- `operations/` - Linux and Windows read-only diagnostic samples and the SSM operating approach.
- `docs/Well_Architected_Matrix.md` - six-pillar controls and evidence.
- `docs/Statement_of_Work.md` - scope, milestones, dependencies and acceptance criteria.

## Implementation boundary

The design assumes AWS Control Tower and Account Factory govern the landing zone and account boundaries. Terraform and GitOps deploy services inside those governed accounts. The Terraform and diagnostic files are concise reference artifacts and require approved account IDs, CIDRs, regions, IAM roles, certificates, domains and client policies before use. No credentials or client secrets are included.

The reusable Terraform modules are intended to live in a versioned modules repository. Account and foundation repositories call pinned module versions; application repositories own Helm charts and Argo CD configuration.

## Validation notes

The presentation and supporting references are designed for review and discussion. No resources are claimed to have been deployed in a client account. Validate all reference values, scripts and policies against the client environment before execution.
