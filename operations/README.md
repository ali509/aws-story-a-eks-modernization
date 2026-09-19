# Operations runbook and diagnostic samples

## Incident sequence

1. Record incident ID, service, environment, impact and recent changes.
2. Check CloudWatch alarms, Prometheus/Grafana metrics and recent deployment history.
3. Use AWS DevOps Agent from the approved alert/webhook path when available. Treat its output as investigation guidance, not automatic authority to change production.
4. Run the relevant read-only Bash or PowerShell sample through an approved SSM document. Target only managed hosts with approved tags, a scoped role, command timeout and bounded output.
5. Store redacted evidence under the incident ID with encryption, access control, audit logging and client-approved retention.
6. Apply only an approved, allowlisted recovery action. Verify health and error rates. Escalate if verification fails.

## Safe boundaries

The samples do not restart services, delete files, modify IIS pools or change Kubernetes resources. An approved remediation document may be added later after the client agrees the allowlist, approval and rollback process. Do not repeatedly restart an OOM-killed process or clear disk space by deleting data automatically.

## EKS and patch operations

Patch EC2 during maintenance windows. For EKS node upgrades, create replacement capacity, drain one safe batch at a time, respect PodDisruptionBudgets, verify readiness and continue only after the previous batch is healthy. Test Kubernetes and add-on versions in non-production first.

## Evidence retention

Redact secrets and personal data. Keep searchable operational evidence for the client-approved period and longer security/audit records only where policy requires. The 30-day searchable period is a proposal, not a fixed client commitment.

## Samples

- [linux-diagnostic.sh](linux-diagnostic.sh)
- [windows-diagnostic.ps1](windows-diagnostic.ps1)

The files are bounded, read-only samples. Test them on the exact client AMI and Windows image before calling them production-ready.
