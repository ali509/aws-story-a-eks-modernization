# Story A architecture reference

## 1. Problem and target outcome

The current-state problem is a flat environment with overlapping networks, manual releases and fragmented operational evidence. Story A separates environments into AWS accounts, creates a shared network and security foundation, moves workloads to EKS where suitable, and standardizes delivery through Terraform and GitOps.

The target is measurable recovery improvement. The assignment’s under-15-minute MTTR target should be proven with agreed game-day scenarios. It is not an achieved result in this reference design.

## 2. Account and network model

- Management account: AWS Organizations and SCP guardrails. No application workloads.

- Control Tower governs the landing zone and enrolls/provisions accounts through Account Factory and landing-zone customization. It does not itself deploy ECR, EKS, OpenSearch, or application resources. Terraform modules and account/foundation repositories deploy those services into the governed accounts.
- Network account: Transit Gateway, AWS RAM sharing, inspection VPC, Network Firewall and central NAT.
- Security and logging account: centralized security findings, audit logs and approved log destinations.
- Shared platform account: reusable platform tooling and a sandbox EKS cluster.
- Dev, staging and production accounts: independent EKS clusters, state and data boundaries.

Each environment uses non-overlapping CIDRs and multiple Availability Zones. VPCs contain public ingress, private application, isolated data and dedicated TGW subnets. Data subnets have no direct internet route. TGW route tables permit only approved paths. Firewall and NAT paths are deployed per AZ and use symmetric routing.

## 3. EKS and workload placement

Use separate managed Linux and Windows node groups in the same environment cluster when the workload supports both operating systems. Linux hosts platform controllers and Linux APIs. Windows nodes run compatible Windows containers with OS labels and taints/tolerations. Keep incompatible legacy applications on managed EC2 until they are ready for containerization.

Pod Identity is the preferred Linux workload IAM pattern where supported. Use a separately tested IRSA compatibility path for Windows workloads. Windows IPAM and Windows-specific node authorization must be validated during the pilot. Do not promise identical custom CNI capabilities on Linux and Windows.

Ingress follows Route 53 to HTTPS ALB, ACM and WAF, then private application endpoints. The AWS Load Balancer Controller reconciles Kubernetes ingress rules. Kubernetes administrators use a private EKS API endpoint, access entries and RBAC. Workload IAM is separate from user authentication.

## 4. Repository and delivery boundaries

The reusable Terraform modules repository is versioned independently. Account/foundation repositories call pinned module versions and own providers, backend state and account-specific values. Application repositories own Helm charts, environment values and Argo CD applications.

CI runs from GitHub Actions. Veracode or an approved equivalent performs the client-selected SAST, SCA, DAST, IaC and container checks. Helm validation and secret scanning are separate gates. A successful build publishes an immutable ECR digest and proposes a GitOps change. Argo CD renders Helm and promotes the same digest through dev, staging and production with approvals.

## 5. Observability and incident response

CloudWatch collects host and application logs and alarms. Prometheus and Grafana provide Kubernetes metrics and dashboards. A configured subscription or delivery pipeline can route selected logs into central OpenSearch. Application tracing is optional and should be piloted only if request-level latency analysis is required.

For incidents, an alarm or incident webhook can start an AWS DevOps Agent investigation. The agent provides findings and mitigation suggestions using available telemetry and deployment context. An operator reviews the evidence and chooses an approved SSM diagnostic or recovery action. Keep a manual runbook path when the agent is unavailable. Automated changes remain allowlisted and approval-controlled.

## 6. Security, state and operations

GitHub Actions uses OIDC and a scoped target-account role. Workload roles are separate. Cross-account access needs source permission, target trust and any resource or KMS policy permission. SCPs and permission boundaries limit permissions but do not grant them.

Terraform state is encrypted and versioned in S3, separated by account, environment and stack. The assignment asks for DynamoDB locking. HashiCorp now documents native S3 locking as the forward-looking choice, so confirm the Terraform version and locking approach before implementation. Never use one writable state for every environment.

SSM documents target allowlisted managed hosts with timeouts and bounded output. Collect evidence before remediation. Patch EC2 in maintenance windows. Replace EKS nodes in safe batches, respect disruption budgets and verify workloads before continuing.

## 7. Trade-offs

- Separate clusters improve isolation but increase platform capacity and maintenance.
- Central egress improves inspection consistency but adds shared routing complexity.
- Managed mixed-OS node groups reduce lifecycle work but do not remove Windows compatibility testing.
- GitOps improves auditability but needs an emergency-change and rollback procedure.
- AWS DevOps Agent reduces custom orchestration code, but human review and a manual runbook remain necessary.
