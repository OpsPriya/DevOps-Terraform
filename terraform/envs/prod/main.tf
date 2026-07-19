# Production Environment Configuration
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

# Remote state for shared environment
data "terraform_remote_state" "shared" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = "shared/terraform.tfstate"
    region = var.aws_region
  }
}

# IAM Module for EKS Load Balancer Controller
module "iam" {
  source = "../../modules/iam"

  role_name               = "${var.project_name}-prod-eks-load-balancer-controller"
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

# VPC Configuration
module "vpc" {
  source = "../../modules/vpc"

  environment = "prod"
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

  name = "${var.project_name}-prod-to-shared"

  # VPC IDs
  requester_vpc_id = module.vpc.vpc_id
  accepter_vpc_id  = data.terraform_remote_state.shared.outputs.vpc_id

  # Route table IDs
  requester_route_table_ids = concat(
    module.vpc.public_route_table_ids,
    module.vpc.private_route_table_ids
  )

  # accepter_route_table_ids = data.terraform_remote_state.shared.outputs.public_route_table_ids

  # Security group rules
  requester_security_group_id = module.eks.worker_security_group_id
  # accepter_security_group_id  = data.terraform_remote_state.shared.outputs.bastion_security_group_id

  # CIDR blocks for security group rules
  requester_cidr = module.vpc.vpc_cidr_block
  accepter_cidr  = data.terraform_remote_state.shared.outputs.vpc_cidr_block

}

# EKS Cluster
module "eks" {
  source = "../../modules/eks"

  environment = "prod"

  # VPC configuration
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  public_subnet_ids  = module.vpc.public_subnets

  # EKS configuration
  kubernetes_version = var.eks_kubernetes_version
  instance_types     = var.eks_instance_types
  desired_size       = var.eks_desired_size
  max_size           = var.eks_max_size
  min_size           = var.eks_min_size
  disk_size          = var.eks_disk_size
  capacity_type      = var.eks_capacity_type
  update_config      = var.eks_update_config

  # Custom AMI (optional - leave empty to use EKS-optimized AMI)
  node_ami_id = var.eks_node_ami_id
  
  # AMI type for Bottlerocket support
  node_ami_type = var.eks_node_ami_type

  # Enable cluster logging
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Cluster endpoint access
  cluster_endpoint_public_access_cidrs = length(var.eks_allowed_ips) > 0 ? var.eks_allowed_ips : ["0.0.0.0/0"]

}

# Application Security Group for production environment workloads
resource "aws_security_group" "prod_app" {
  name_prefix = "${var.project_name}-prod-app-"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for production environment application workloads - allows outbound traffic to all destinations"

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
  environment = "prod"

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
    aws_security_group.prod_app.id
  ]
  allowed_cidr_blocks = var.rds_allowed_ips

  # Backup configuration
  backup_retention_period = var.rds_backup_retention_days
  backup_window           = "03:00-06:00"

  # Maintenance window
  maintenance_window = "Mon:00:00-Mon:03:00"

  # Database credentials
  database_name     = var.rds_database_name
  database_username = var.rds_username
  # RDS password is now auto-generated and stored in Secrets Manager by the RDS module

  # Enable Performance Insights
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  # Enable enhanced monitoring
  monitoring_interval = 60

  # Enable deletion protection in production
  deletion_protection = true

}

# Elasticsearch using EC2 module
module "elasticsearch" {
  source = "../../modules/ec2"

  name          = "${var.project_name}-prod-elasticsearch"
  description   = "Security group for Elasticsearch cluster"
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.random_private_subnet # Random AZ selection
  ami_id        = var.elasticsearch_ami_id
  instance_type = var.elasticsearch_instance_type
  key_name      = var.key_name
  assign_eip    = false

  # Security group rules
  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [module.vpc.vpc_cidr_block]
      description = "SSH access from VPC"
    },
    {
      from_port   = 9200
      to_port     = 9200
      protocol    = "tcp"
      cidr_blocks = var.elasticsearch_allowed_ips
      description = "Elasticsearch HTTP"
    },
    {
      from_port   = 9300
      to_port     = 9300
      protocol    = "tcp"
      cidr_blocks = var.elasticsearch_allowed_ips
      description = "Elasticsearch transport"
    }
  ]

  # Egress rules for Elasticsearch outbound access
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "All outbound traffic"
    }
  ]

  # Volume configuration
  root_volume_size = var.elasticsearch_root_volume_size
  root_volume_type = var.elasticsearch_root_volume_type

}
