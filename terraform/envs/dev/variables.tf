# Development Environment Variables

# Core Configuration
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "assume_role_arn" {
  description = "ARN of the role to assume for cross-account access"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = []
}

variable "auto_calculate_subnets" {
  description = "Whether to automatically calculate subnet CIDRs based on VPC CIDR and available AZs"
  type        = bool
  default     = true
}

variable "enable_shared_vpc_peering" {
  description = "Enable VPC peering to shared VPC"
  type        = bool
  default     = false
}

# EKS Configuration
variable "eks_kubernetes_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.33"
}

variable "eks_instance_types" {
  description = "Instance types for EKS nodes"
  type        = list(string)
  default     = ["t3.large"]
}

variable "eks_desired_size" {
  description = "Desired number of EKS nodes"
  type        = number
  default     = 1
}

variable "eks_max_size" {
  description = "Maximum number of EKS nodes"
  type        = number
  default     = 2
}

variable "eks_min_size" {
  description = "Minimum number of EKS nodes"
  type        = number
  default     = 1
}

variable "eks_node_ami_id" {
  description = "Custom AMI ID for EKS nodes (leave empty to use EKS-optimized AMI)"
  type        = string
  default     = ""
}

variable "eks_node_ami_type" {
  description = "AMI type for EKS nodes (e.g., AL2_x86_64, BOTTLEROCKET_ARM_64, BOTTLEROCKET_x86_64)"
  type        = string
  default     = ""
}

variable "eks_public_access_cidrs" {
  description = "CIDR blocks for EKS public access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "eks_private_access" {
  description = "Enable private access to EKS cluster"
  type        = bool
  default     = true
}

# EKS Node Group Configuration
variable "node_group_desired_size" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
  default     = 2
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in the EKS node group"
  type        = number
  default     = 1
}

variable "node_group_capacity_type" {
  description = "Capacity type for EKS node group (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"
}

variable "node_group_disk_size" {
  description = "Disk size for EKS node group"
  type        = number
  default     = 60
}

variable "node_group_update_config" {
  description = "Update configuration for EKS node group"
  type = object({
    max_unavailable_percentage = number
  })
  default = {
    max_unavailable_percentage = 25
  }
}

# RDS Configuration
variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.medium"
}

variable "rds_allocated_storage" {
  description = "Allocated storage for RDS (GB)"
  type        = number
  default     = 20
}

variable "rds_multi_az" {
  description = "Enable multi-AZ deployment for RDS"
  type        = bool
  default     = false
}

variable "rds_backup_retention_days" {
  description = "Number of days to retain RDS backups"
  type        = number
  default     = 3
}

variable "rds_database_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "rds_username" {
  description = "Database username"
  type        = string
  default     = "appadmin"
}

variable "rds_engine_version" {
  description = "RDS engine version"
  type        = string
  default     = "15.7"
}

variable "rds_max_allocated_storage" {
  description = "RDS maximum allocated storage"
  type        = number
  default     = 100
}

variable "rds_skip_final_snapshot" {
  description = "Skip final snapshot when destroying the database"
  type        = bool
  default     = true
}

variable "rds_deletion_protection" {
  description = "Enable deletion protection for RDS instance"
  type        = bool
  default     = false
}

# Elasticsearch Configuration
variable "elasticsearch_ami_id" {
  description = "AMI ID for Elasticsearch instance"
  type        = string
}

variable "elasticsearch_instance_type" {
  description = "Instance type for Elasticsearch"
  type        = string
  default     = "m6a.large"
}

variable "elasticsearch_allowed_ips" {
  description = "IP addresses allowed to access Elasticsearch"
  type        = list(string)
  default     = []
}

variable "elasticsearch_root_volume_size" {
  description = "Root volume size for Elasticsearch"
  type        = number
  default     = 60
}

variable "elasticsearch_root_volume_type" {
  description = "Root volume type for Elasticsearch"
  type        = string
  default     = "gp3"
}

# SSH Key Configuration
variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
}

variable "project_name" {
  description = "Generic project prefix used in resource names"
  type        = string
  default     = "interview-demo"
}

variable "state_bucket" {
  description = "S3 bucket containing remote Terraform state"
  type        = string
}
