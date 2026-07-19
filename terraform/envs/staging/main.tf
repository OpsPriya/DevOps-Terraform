# Staging Environment Configuration
# Consolidated main configuration file

# Provider configuration
provider "aws" {
  region = var.aws_region

  # Assume role for cross-account access if needed
  dynamic "assume_role" {
    for_each = var.assume_role_arn != "" ? [1] : []

    content {
      role_arn = var.assume_role_arn
    }
  }

}

# Data sources
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

# IAM Module for EKS Load Balancer Controller
module "iam" {
  source = "../../modules/iam"

  role_name               = "${var.project_name}-staging-eks-load-balancer-controller"
  trust_policy_file       = "eks-load-balancer-controller-trust-policy.json"
  create_instance_profile = false
  account_id              = data.aws_caller_identity.current.account_id
  oidc_id                 = split("/", module.eks.cluster_oidc_issuer_url)[4]
  cluster_name            = module.eks.cluster_name
  region                  = var.aws_region
  policy_files = {
    load-balancer-controller = "eks-load-balancer-controller-policy.json"
  }
}

# Remote state for shared environment
data "terraform_remote_state" "shared" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = "shared/terraform.tfstate"
    region = var.aws_region
  }
}


# VPC Configuration
module "vpc" {
  source = "../../modules/vpc"

  environment = "staging"
  vpc_cidr    = var.vpc_cidr

  # Subnets are auto-calculated based on available AZs
  auto_calculate_subnets = true

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

}

# VPC Peering to Shared VPC
module "vpc_peering" {
  source = "../../modules/vpc-peering"

  name = "${var.project_name}-staging-to-shared"

  # VPC IDs
  requester_vpc_id = module.vpc.vpc_id
  accepter_vpc_id  = data.terraform_remote_state.shared.outputs.vpc_id

  # Route table IDs
  requester_route_table_ids = concat(
    module.vpc.public_route_table_ids,
    module.vpc.private_route_table_ids
  )

  accepter_route_table_ids = data.terraform_remote_state.shared.outputs.public_route_table_ids

  # Security group rules
  requester_security_group_id = module.eks.worker_security_group_id
  accepter_security_group_id  = data.terraform_remote_state.shared.outputs.bastion_security_group_id

  # CIDR blocks for security group rules
  requester_cidr = module.vpc.vpc_cidr_block
  accepter_cidr  = data.terraform_remote_state.shared.outputs.vpc_cidr_block

}

# EKS Cluster
module "eks" {
  source = "../../modules/eks"

  environment = "staging"

  # VPC configuration
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  # EKS configuration
  kubernetes_version = var.eks_kubernetes_version
  instance_types     = var.eks_instance_types
  desired_size       = var.eks_desired_size
  max_size           = var.eks_max_size
  min_size           = var.eks_min_size
  disk_size          = 30

  # Custom AMI (optional - leave empty to use EKS-optimized AMI)
  node_ami_id = var.eks_node_ami_id
  
  # AMI type for Bottlerocket support
  node_ami_type = var.eks_node_ami_type

  # Enable cluster logging
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

}

# Application Security Group for staging environment workloads
resource "aws_security_group" "staging_app" {
  name_prefix = "${var.project_name}-staging-app-"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for staging environment application workloads - allows outbound traffic to all destinations"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

}

# EKS cluster security group rules for monitoring and load balancer access
resource "aws_security_group_rule" "eks_node_exporter_from_grafana" {
  type                     = "ingress"
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.shared.outputs.grafana_security_group_id
  security_group_id        = module.eks.cluster_security_group_id
  description              = "Node exporter metrics access from Grafana monitoring server"
}

resource "aws_security_group_rule" "eks_https_from_alb" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [module.vpc.vpc_cidr_block]
  security_group_id = module.eks.cluster_security_group_id
  description       = "HTTPS traffic from Application Load Balancer within VPC"
}

# RDS PostgreSQL
module "rds" {
  source = "../../modules/rds"


  project_name = var.project_name
  environment = "staging"

  # VPC configuration
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  # RDS configuration
  instance_class    = var.rds_instance_class
  allocated_storage = var.rds_allocated_storage
  multi_az          = var.rds_multi_az

  # Security group configuration
  additional_security_group_ids = [
    data.terraform_remote_state.shared.outputs.bastion_security_group_id,
    module.eks.cluster_security_group_id,
    aws_security_group.staging_app.id
  ]

  # Backup configuration
  backup_retention_period = var.rds_backup_retention_days
  backup_window           = "03:00-06:00"

  # Maintenance window
  maintenance_window = "Mon:00:00-Mon:03:00"

  # Database credentials
  database_name     = var.rds_database_name
  database_username = var.rds_username

  # Enable Performance Insights
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  # Enable enhanced monitoring
  monitoring_interval = 60

  # Enable deletion protection in staging
  deletion_protection = true

}

# Elasticsearch
module "elasticsearch" {
  source = "../../modules/ec2"

  name          = "staging-elasticsearch"
  description   = "Security group for staging Elasticsearch instance"
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.private_subnets[0] # Use first private subnet
  ami_id        = var.es_ami_id
  instance_type = var.es_instance_type
  key_name      = var.key_name

  # Security group rules
  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.elasticsearch_allowed_ips
      description = "SSH access from allowed IPs"
    },
    {
      from_port   = 9200
      to_port     = 9200
      protocol    = "tcp"
      cidr_blocks = var.elasticsearch_allowed_ips
      description = "Elasticsearch HTTP access from allowed IPs"
    },
    {
      from_port   = 9300
      to_port     = 9300
      protocol    = "tcp"
      cidr_blocks = var.elasticsearch_allowed_ips
      description = "Elasticsearch transport access from allowed IPs"
    }
  ]

  # Root volume configuration
  root_volume_size = var.es_volume_size
  root_volume_type = var.es_volume_type

}
