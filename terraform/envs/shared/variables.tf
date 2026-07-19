# Shared Environment Variables

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
  description = "CIDR block for the VPC"
  type        = string
    default     = "10.0.0.0/16"
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
variable "bastion_allowed_ips" {
  description = "IP addresses allowed to access bastion host"
  type        = list(string)
  default     = []
}

variable "grafana_alb_allowed_ips" {
  description = "IP addresses allowed to access Grafana Application Load Balancer"
  type        = list(string)
  default     = []
}

variable "internal_tooling_allowed_ips" {
  description = "IP addresses allowed to access internal tooling server"
  type        = list(string)
  default     = []
}

variable "enable_cross_environment_monitoring" {
  description = "Enable cross-environment metrics collection to Grafana"
  type        = bool
  default     = false
}

# Bastion Host Configuration
variable "bastion_ami_id" {
  description = "AMI ID for bastion host (Golden AMI)"
  type        = string
    default     = ""
}

variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "bastion_root_volume_size" {
  description = "Root volume size for bastion host"
  type        = number
  default     = 20
}

variable "bastion_root_volume_type" {
  description = "Root volume type for bastion host"
  type        = string
  default     = "gp3"
}

# Grafana Configuration
variable "grafana_ami_id" {
  description = "AMI ID for Grafana instance (Golden AMI)"
  type        = string
  default     = ""
}

variable "grafana_instance_type" {
  description = "Instance type for Grafana"
  type        = string
  default     = "m6a.large"
}

variable "grafana_root_volume_size" {
  description = "Root volume size for Grafana"
  type        = number
  default     = 60
}

variable "grafana_root_volume_type" {
  description = "Root volume type for Grafana"
  type        = string
  default     = "gp3"
}

# Internal Tooling Server Configuration
variable "internal_tooling_ami_id" {
  description = "AMI ID for internal tooling server (Golden AMI)"
  type        = string
}

variable "internal_tooling_instance_type" {
  description = "Instance type for internal tooling server"
  type        = string
  default     = "c6a.large"
}

variable "internal_tooling_root_volume_size" {
  description = "Root volume size for internal tooling server"
  type        = number
  default     = 150
}

variable "internal_tooling_root_volume_type" {
  description = "Root volume type for internal tooling server"
  type        = string
  default     = "gp3"
}

# SSH Key Configuration
variable "key_name" {
  description = "SSH key pair name for bastion host"
  type        = string
  default     = ""
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
