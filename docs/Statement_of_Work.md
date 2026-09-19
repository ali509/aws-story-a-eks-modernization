# Statement of Work - Story A

## Scope

Design an AWS multi-account foundation and EKS migration path for a hybrid Linux/Windows environment. Establish reusable Terraform modules, account-specific composition, GitHub Actions CI, Helm and Argo CD delivery, centralized logs/metrics, and controlled diagnostic operations.

## Phases

| Phase | Activities | Exit criteria |
| --- | --- | --- |
| Discovery | Inventory accounts, applications, dependencies, CIDRs, Windows compatibility, security controls and recovery scenarios | Approved architecture, migration waves, risks and dependencies |
| Foundation | Organizations guardrails, network hub, TGW attachments, firewall/NAT, state, IAM, non-production EKS and CI/CD skeleton | Isolation tests, inspected egress test, approved plan/apply and healthy non-production cluster |
| Pilot and migration | Pilot Linux and Windows workloads, Helm/Argo CD promotion, diagnostics, rollback and game-day testing | Successful promotion/rollback, evidence collection, recovery test and operational handover |

## Dependencies

Client account access, approved regions and CIDRs, quotas, DNS and certificates, application owners, compatible container images, IAM/security approvals, test data, maintenance windows and monitoring/retention requirements.

## Acceptance criteria

- Dev, staging and production have approved account and route boundaries.
- Terraform modules are versioned separately from account repositories.
- CI produces scan evidence and an immutable image digest.
- Argo CD promotes the same digest with environment approvals.
- Linux and Windows diagnostic samples run through approved SSM controls after client testing.
- A recovery game day measures the agreed common incidents against the under-15-minute MTTR target.
- Runbooks, ownership, escalation and rollback procedures are accepted by the client.

## Out of scope

Full application rewrites, kernel modifications, unapproved production cutover, client-specific secrets and a claim that the reference snippets have already been deployed.

## Communication

Weekly demonstrations, a decision log, a risk register, written change approvals and a named client owner for security, networking, application readiness and production cutover.
