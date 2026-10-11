# Multi-Environment AWS Platform with Terraform + Atlantis

Production-style Terraform project that provisions a multi-environment AWS platform using reusable modules and GitOps-style workflows with Atlantis.

---

## Overview

This repository demonstrates a real-world Terraform structure used for managing AWS infrastructure across multiple environments:

| Environment | Purpose |
|-------------|---------|
| **shared**  | Common networking, monitoring & access services |
| **dev**     | Development workloads |
| **staging** | Pre-production validation |
| **prod**    | Production workloads |

Each environment maintains **separate remote state** in S3 for isolation and safety.

---

## Architecture
Pull Request
↓
Atlantis runs terraform plan
↓
Reviewer approves the plan
↓
Atlantis runs terraform apply
↓
AWS infrastructure is created / updated
text**Deployment order:**
shared → dev → staging → prod
textApplication environments depend on outputs from the `shared` state (VPC IDs, security groups, etc.).

---

## Repository Structure
DevOps-Terraform/
├── terraform/
│   ├── modules/                 # Reusable modules
│   │   ├── vpc/
│   │   ├── vpc-peering/
│   │   ├── ec2/
│   │   ├── eks/
│   │   ├── rds/
│   │   └── iam/
│   └── envs/                    # Environment-specific configurations
│       ├── shared/
│       ├── dev/
│       ├── staging/
│       └── prod/
├── atlantis.yaml                # Atlantis configuration
├── INTERVIEW_NOTES.md           # Design decisions explained
└── README.md
text---

## Key Features

- **Reusable modules** – Avoids code duplication across environments
- **Separate state files** – Reduces blast radius of changes
- **S3 remote state + locking** – Safe for team collaboration
- **VPC Peering** – Connects application VPCs with shared services
- **EKS with managed node groups** – Production-ready Kubernetes
- **RDS with Secrets Manager** – Automated credential management
- **Atlantis integration** – Pull-request based plan & apply with approval controls

---

## Modules

| Module        | Description |
|---------------|-------------|
| `vpc`         | VPC, subnets, route tables, NAT, IGW |
| `vpc-peering` | Peering between application and shared VPCs |
| `ec2`         | EC2 instances / bastion hosts |
| `eks`         | EKS cluster + managed node groups |
| `rds`         | RDS instance with Secrets Manager integration |
| `iam`         | IAM roles and policies |

---

## How to Use

### Prerequisites
- Terraform >= 1.5
- AWS CLI configured
- S3 bucket + DynamoDB table for remote state (or update backend config)

### Local Workflow

```bash
# Navigate to an environment
cd terraform/envs/dev

# Initialize
terraform init

# Plan
terraform plan

# Apply (after review)
terraform apply
Atlantis Workflow (Recommended)

Create a Pull Request with infrastructure changes
Atlantis automatically comments with terraform plan
Reviewer approves the plan
Comment atlantis apply (or use the configured apply trigger)
Infrastructure is updated safely
