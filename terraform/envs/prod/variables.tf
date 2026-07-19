# Production Environment Variables

# Core Configuration
variable "aws_region" {
  description = "AWS region to deploy resources"
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
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.30.0.0/16"
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

# Security Configuration
variable "eks_allowed_ips" {
  description = "IP addresses allowed to access EKS cluster endpoint"
  type        = list(string)
  default     = []
}

variable "rds_allowed_ips" {
  description = "IP addresses allowed to access RDS"
  type        = list(string)
  default     = []
}

variable "elasticsearch_allowed_ips" {
  description = "IP addresses allowed to access Elasticsearch"
  type        = list(string)
  default     = []
}

variable "eks_public_access_cidrs" {
  description = "CIDR blocks for EKS public access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# EKS Configuration
variable "eks_kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.33"
}

variable "eks_instance_types" {
  description = "List of EC2 instance types for EKS worker nodes"
  type        = list(string)
  default     = ["t3.large"]
}

variable "eks_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "eks_max_size" {
  description = "Maximum number of EKS worker nodes"
  type        = number
  default     = 5
}

variable "eks_min_size" {
  description = "Minimum number of EKS worker nodes"
  type        = number
  default     = 1
}

variable "eks_capacity_type" {
  description = "Type of capacity for EKS nodes (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"
}

variable "eks_disk_size" {
  description = "Disk size in GiB for EKS worker nodes"
  type        = number
  default     = 50
}

variable "eks_update_config" {
  description = "Configuration for EKS node group updates"
  type = object({
    max_unavailable_percentage = optional(number, 25)
    max_unavailable            = optional(number, 1)
  })
  default = {
    max_unavailable = 1
  }
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

# RDS Configuration
variable "rds_instance_class" {
  description = "Instance class for RDS"
  type        = string
  default     = "db.t3.medium"
}

variable "rds_allocated_storage" {
  description = "Allocated storage in GB for RDS"
  type        = number
  default     = 100
}

variable "rds_multi_az" {
  description = "Enable multi-AZ deployment for RDS"
  type        = bool
  default     = true
}

variable "rds_backup_retention_days" {
  description = "Number of days to retain RDS backups"
  type        = number
  default     = 30
}

variable "rds_database_name" {
  description = "Name of the database to create"
  type        = string
  default     = "appdb"
}

variable "rds_username" {
  description = "Database administrator username"
  type        = string
  default     = "appadmin"
}

variable "rds_skip_final_snapshot" {
  description = "Skip final snapshot when destroying the database"
  type        = bool
  default     = false
}

# Elasticsearch Configuration
variable "elasticsearch_ami_id" {
  description = "AMI ID for Elasticsearch instance (Golden AMI)"
  type        = string
}

variable "elasticsearch_instance_type" {
  description = "Instance type for Elasticsearch"
  type        = string
  default     = "t3.medium"
}

variable "elasticsearch_root_volume_size" {
  description = "Root volume size for Elasticsearch"
  type        = number
  default     = 50
}

variable "elasticsearch_root_volume_type" {
  description = "Root volume type for Elasticsearch"
  type        = string
  default     = "gp3"
}

# SSH Key Configuration
variable "key_name" {
  description = "Name of the AWS key pair to use for EC2 instances"
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
