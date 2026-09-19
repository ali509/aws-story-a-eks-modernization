# BotConsulting - simplified Story A submission

## What the assignment actually asks

Your interpretation is mostly right: explain the architecture, boundaries, folder structure and delivery flows. A large, fully runnable Terraform repository is not explicitly required. However, the original PDF is **not a PPT-only request**:

- Section 1.4 (page 3) lists seven deliverables: architecture reference, five diagrams, Terraform design/artifacts, EKS design, incident runbook/scripts, six-pillar Well-Architected matrix and SOW.
- Section 3.2 (pages 5-6) explicitly requests working HCL snippets for TGW attachment/association and mixed Linux/Windows EKS node groups.
- Section 4.1 (pages 6-7) requests production-ready Linux and Windows diagnostic-script samples.
- Section 1.3 excludes a complete production application backend. It does not exclude infrastructure or diagnostic examples.
- There is no explicit requirement to deploy this into a paid AWS account or demonstrate a complete repository being applied. This does not guarantee the reviewer will never execute the samples.

The simplified approach is therefore an architecture-led presentation with a small technical appendix. The diagnostic excerpts show the requested checks, but require host-specific testing and a production wrapper; they are not claimed to satisfy a tested production-ready script deliverable by themselves. Confirm that this compact sample depth is acceptable if HR expects the PDF's wording literally.

## What to use

Use `Story_A_Simplified_Presentation.pptx` as the presentation. Slides 1-17 are code-free; slides 18-21 are optional technical examples. Slide 8 now separates the reusable modules repository from the account/foundation repository and the application/GitOps repository. Speaker notes explain each slide in plain language.

This guide is the companion architecture, operations and scope reference. The previous detailed bundle is preserved, but is not part of this simplified package. No resources have been deployed by this revision, and nothing has been sent to HR.

## Suggested opening

“I chose Story A because the customer has three connected problems: environments share too much, releases are manual, and troubleshooting evidence is scattered. My proposal separates the environments, standardizes delivery with Terraform and GitOps, and brings diagnostics into one controlled workflow. I will explain the flows first and keep the implementation examples in the appendix.”

## Architecture and boundaries

The management account governs AWS Organizations and SCPs; it hosts no applications.

Control Tower runs in the management account and applies governance, guardrails and account-factory workflows. It provisions or enrolls the account boundaries shown in the diagram; Terraform and landing-zone customization deploy the services inside them. The management account hosts no applications. Separate network, security/logging and shared-platform accounts provide common services. Dev, staging and production have their own accounts, runtime EKS clusters and data. The platform account hosts shared tooling and a sandbox EKS cluster, not a single cluster shared by all production and development workloads.

Each environment uses an approved, non-overlapping CIDR and multiple availability zones. Public ingress, private application, isolated data and dedicated TGW subnets have different route tables. Shared internet egress lives in the network account, with firewall and NAT paths per AZ. Data subnets have no direct internet route. Security groups restrict specific application-to-data ports; Kubernetes network policies add pod-level restrictions where supported and tested.

The hub owns the TGW and shares it through AWS RAM. Attachments associate with explicitly selected TGW route tables. Do not propagate all spoke routes into a common table: that would undermine dev/prod isolation. Inspection requires appropriate VPC/TGW routes, appliance mode on the inspection attachment and symmetric return paths. The diagrams intentionally show logical flows, not every route-table entry.

Public traffic follows DNS → HTTPS ALB/WAF → ready application endpoints. The slide's Kubernetes Service is a logical routing relationship; with ALB IP targets, the load balancer sends traffic directly to pod IPs rather than traversing a Service virtual IP. The Load Balancer Controller reconciles ingress and target registration. ACM provides certificates. OIDC/application authentication identifies users. Private EKS API access, access entries and RBAC govern administrators separately.

Linux and Windows run in separate managed node groups. Use OS selectors and appropriate taints/tolerations; keep controllers on Linux. Match Windows container versions to the node OS. Enable Windows IPAM and required node authorization. Pod Identity is recommended for supported Linux EC2 pods; Windows uses a separately tested IRSA compatibility path. Windows does not support VPC CNI custom networking, so clarify the PDF's “custom CNI” requirement rather than promise identical networking features on both OS types.

## Explain CI and CD simply

**CI checks whether the change is safe to release.** GitHub Actions runs unit tests, Veracode or an approved equivalent for SAST, SCA, DAST where an environment exists, IaC policy checks and container checks. Secret detection and Helm validation remain separate gates. After policy gates and merge, it publishes the image to ECR and proposes a GitOps change containing its immutable digest. Terraform has a separate PR flow for formatting, validation, Checkov/OPA, reviewed plan and approved apply.

**CD puts the approved version into the environment.** Argo CD watches the environment's GitOps path. Helm supplies templates and environment values; Argo CD renders and synchronizes them into EKS. Promote the same digest from dev to staging to production after environment-specific tests and approvals. Rollback means reverting the desired version in Git, syncing and verifying recovery, after checking database compatibility.

GitHub uses OIDC and a scoped target-account role. Restrict its trust to approved repositories and protected environments. Workload roles are separate from deployment roles. Cross-account access requires both source permission and target trust; resource and encryption-key policies may also need permission. SCPs and permission boundaries limit access but do not grant it.

Keep the reusable Terraform modules in a separate versioned modules repository. Account/foundation repositories call a pinned module version and own providers, account-specific variables, state and policy inputs. Application repositories remain separate and own Helm charts, values and Argo CD configuration. Modules expose validated inputs and useful IDs. Use encrypted, versioned S3 state by account, environment and stack. The PDF asks for OPA/Checkov policy-as-code and S3/DynamoDB locking. OPA is a general policy engine; Checkov evaluates Terraform and cloud configuration against security rules. They run as CI gates and fail a plan when an agreed rule fails. DynamoDB locking is now deprecated by HashiCorp, so explain the legacy requirement and agree native S3 locking for the chosen Terraform version. Bootstrap the backend separately; never mix all environments into one writable state.

## Short incident runbook

1. Record the incident ID, affected service, environment, impact and recent release/configuration changes. Confirm whether this is an application, node, network or dependency problem.
2. Collect evidence before remediation. Linux: service state, recent journal/web logs, memory, disk space and inodes. Windows: service state, Application/System events, IIS access logs and application-pool state, memory and disk. The small appendix illustrates a subset; it is not the entire runbook implementation.
3. Correlate CloudWatch logs/alarms and Prometheus/Grafana metrics. Configure a cross-account delivery pipeline into central OpenSearch; centralization is not automatic just because both products exist. Add application tracing only after a client-approved need and pilot.
4. Use a CloudWatch alarm, Grafana alert or incident webhook as the entry point for an AWS DevOps Agent investigation. The agent correlates available telemetry and recent deployment context and provides findings and mitigation suggestions. The operator reviews the evidence and decides whether to invoke an approved, versioned SSM document against allowlisted managed hosts with scoped IAM, target tags, command timeout and concurrency limits. Keep a manual runbook path if the agent is unavailable. Do not present a custom API Gateway/Lambda/Step Functions workflow as an implemented experience.
5. Store bounded results under the incident ID in encrypted evidence storage. Redact sensitive fields, restrict access, audit retrieval and apply client-approved retention. As a starting proposal only, use 30 days of searchable operational evidence, with longer security retention agreed separately.
6. Remediate only an approved condition. For example, restart an allowlisted failed service once after collecting evidence and obtaining the required approval. Never repeatedly restart an OOM-killed process or delete data to clear disk space automatically.
7. Verify service health, synthetic checks and error rates. If recovery fails, stop retries, restore the approved configuration or revert the application release where compatible, and escalate to the service owner. Preserve evidence for the postmortem.

SSM Run Command operates on managed hosts, not arbitrary pod sessions. For EKS, use pod logs and an approved Kubernetes debugging path. Patch EC2 during maintenance windows; replace EKS nodes in safe batches, respect disruption budgets and verify workloads before continuing. Agree supported Kubernetes/add-on versions and rehearse upgrades in non-production first.

## Decisions and trade-offs

- Story A is preferred over Story B because it covers account separation and workload migration as well as diagnostics; centralized egress from Story B remains a baseline control.
- Separate runtime clusters reduce shared failure and permission scope, at the cost of more platform capacity and maintenance.
- Central egress provides consistent inspection but introduces a shared dependency, routing complexity and processing cost. Test AZ failures and bypass prevention.
- Managed node groups reduce node lifecycle effort, but do not remove Windows compatibility, patching or capacity planning responsibilities.
- Keep incompatible legacy workloads on managed EC2 initially. Do not assume every Windows application can immediately become a container.
- GitOps improves traceability but needs clear emergency-change and rollback procedures. Argo CD alone does not provide advanced canary traffic control.

## SOW and acceptance

| Phase | Deliverable and acceptance | Main dependency |
| --- | --- | --- |
| Discovery | Inventory, dependency map, approved CIDRs/account model, migration waves and signed design decisions | Application owners, account inventory and non-functional requirements |
| Foundation | Landing zone, TGW/firewall, scoped IAM, non-production EKS, state and CI/CD skeleton; demonstrate denied dev-to-prod access and successful inspected egress | Approved access, quotas, network connectivity and security policy |
| Migration and operations | Linux/Windows pilot, GitOps release and rollback, diagnostics, game day and knowledge transfer; named operational owners sign off | Compatible images, DNS/certificates, test data and maintenance windows |

Measure the PDF's under-15-minute MTTR target against an agreed set of common incidents during game days; it is a target, not an achieved result. Acceptance also includes successful image promotion, healthy multi-AZ workload behavior, centralized evidence, restore/rollback rehearsal and documented escalation. Establish application-specific RTO/RPO and backups during discovery, then validate restore behavior before production approval.

Use weekly client demonstrations, a decision/risk log and written approval for scope changes. Client owners approve application readiness, security exceptions and production cutover. Dates, effort, costs and support coverage are agreed after discovery. Full application rewrites and unapproved production changes are excluded.

## Requirement map

| PDF deliverable | Simplified coverage |
| --- | --- |
| Architecture reference | [01_Architecture_Reference.md](01_Architecture_Reference.md); slides 1-9, 12-17 and speaker notes |
| Five diagrams | Organization: 2; hub-spoke: 3; ingress/authentication: 5; cross-account IAM: 7; CI/CD promotion: 10-11 |
| Terraform design and artifacts | [02_Terraform_Reference](02_Terraform_Reference/README.md); folder/state/change skeleton: 8-9; resource excerpts: 18-19 |
| EKS workload design | Slides 5-6 and 10-11; compatibility and placement notes in this guide |
| Incident response and scripts | [03_Operations_Runbook](03_Operations_Runbook/README.md), Bash and PowerShell samples, slides 12-14 and 20-21 |
| Six-pillar Well-Architected matrix | [04_Well_Architected_Matrix.md](04_Well_Architected_Matrix.md); slide 15 |
| Client SOW | [05_SOW.md](05_SOW.md); slide 17 |

## Technical references

- Original assessment: `Senior AWS Engineer -Take Home Assignment.pdf`, eight pages, supplied by HR.
- [EKS Windows support and limitations](https://docs.aws.amazon.com/eks/latest/userguide/windows-support.html)
- [EKS Pod Identity support and limitations](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html)
- [Network Firewall symmetric routing](https://docs.aws.amazon.com/network-firewall/latest/developerguide/asymmetric-routing.html)
- [Terraform S3 backend and locking](https://developer.hashicorp.com/terraform/language/backend/s3)
- [AWS DevOps Agent autonomous incident response](https://docs.aws.amazon.com/devopsagent/latest/userguide/production-operations-autonomous-incident-response.html)
- [AWS DevOps Agent GitHub integration](https://docs.aws.amazon.com/devopsagent/latest/userguide/connecting-to-cicd-pipelines-connecting-github.html)

## Presentation tips

Present the flow on each slide in one or two sentences, then explain why the boundary exists. Use “I propose” for this target architecture, not “I implemented” unless describing a confirmed personal project. Keep slides 18-21 for questions. If asked for exact commands, policies or routing entries, say those are implementation details to finalize against the approved client inputs, not hidden assumptions in this skeleton.
