# Well-Architected control matrix

| Pillar | Proposed control | Acceptance evidence |
| --- | --- | --- |
| Operational Excellence | GitHub Actions gates, Argo CD promotion and tested incident runbooks | Approved release, rollback and game-day records |
| Security | Account isolation, scoped IAM, SCPs, permission boundaries and inspected egress | Denied-access tests, policy reports and audit logs |
| Reliability | Multi-AZ EKS capacity, safe node replacement and tested backups | AZ test, restore test and healthy rollout evidence |
| Performance Efficiency | Requests/limits, autoscaling and load testing | Load-test results and scaling behavior |
| Cost Optimization | Ownership tags, Compute Optimizer review and log retention controls | Monthly cost review and optimization actions |
| Sustainability | Remove idle capacity and expire unnecessary data | Capacity and retention reports |

These are proposed controls, not a claim of completed certification or measured SLO.
