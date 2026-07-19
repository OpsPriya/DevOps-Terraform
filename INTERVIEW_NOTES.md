# Short Interview Explanation

## 30-second answer

This Terraform project provisions a multi-environment AWS platform. I created reusable modules for VPC, VPC peering, EC2, EKS, RDS, and IAM, then called those modules from shared, development, staging, and production environments. Each environment keeps separate remote state in S3. The shared environment provides common access and monitoring services, while the other environments deploy their own networking, Kubernetes cluster, database, and search instance. Atlantis can run Terraform plan and apply through pull requests with approval controls.

## Deployment flow

```text
Pull request
   ↓
Atlantis runs terraform plan
   ↓
Reviewer approves the plan
   ↓
Atlantis runs terraform apply
   ↓
AWS infrastructure is created or updated
```

## Deployment order

```text
shared → dev → staging → prod
```

The application environments depend on outputs from the shared state, such as VPC and security-group information.

## Key interview points

- Reusable modules avoid duplicated Terraform code.
- Separate state reduces the impact of changes between environments.
- S3 remote state supports team collaboration and state locking.
- VPC peering connects application VPCs with shared monitoring and access services.
- EKS runs containerized workloads using managed node groups.
- RDS credentials are generated automatically and stored in Secrets Manager.
- Atlantis provides pull-request-based plans, approvals, and controlled applies.
- Sensitive files such as state, plan, backend configuration, and tfvars are excluded from Git.
