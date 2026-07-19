variable "environment" {
  description = "Environment name (e.g., prod, staging, dev)"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the RDS subnet group"
  type        = list(string)
}

variable "additional_security_group_ids" {
  type    = list(string)
  default = []
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access RDS"
  type        = list(string)
  default     = []
}

# Database configuration
variable "database_name" {
  description = "Name of the database to create"
  type        = string
  default     = "appdb"
}

variable "database_username" {
  description = "Username for the database"
  type        = string
  default     = "admin"
}


# RDS instance configuration
variable "engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "15.7"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "allocated_storage" {
  description = "Initial storage size in GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage size in GB for storage autoscaling"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage type (standard, gp2, gp3, io1)"
  type        = string
  default     = "gp3"
}

variable "iops" {
  description = "The amount of provisioned IOPS for the DB instance"
  type        = number
  default     = null
}

# High availability
variable "multi_az" {
  description = "Enable multi-AZ deployment"
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "The AZ for the RDS instance. If not specified, AWS will auto-assign"
  type        = string
  default     = null
}

# Backup & maintenance
variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "The daily time range during which automated backups are created"
  type        = string
  default     = "03:00-06:00"
}

variable "maintenance_window" {
  description = "The window to perform maintenance in"
  type        = string
  default     = "Mon:00:00-Mon:03:00"
}

# Security
variable "kms_key_arn" {
  description = "ARN of the KMS key for encryption at rest"
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when destroying the database"
  type        = bool
  default     = true
}

# Monitoring
variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected"
  type        = number
  default     = 0
}

variable "monitoring_role_arn" {
  description = "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs"
  type        = string
  default     = ""
}

# Performance Insights
variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = true
}

variable "performance_insights_retention_period" {
  description = "The amount of time in days to retain Performance Insights data"
  type        = number
  default     = 7
}

# Read Replica
variable "create_read_replica" {
  description = "Create a read replica in a different AZ"
  type        = bool
  default     = false
}

variable "replica_instance_class" {
  description = "Instance class for the read replica. If not specified, same as primary instance"
  type        = string
  default     = ""
}

# Parameters
variable "db_parameters" {
  description = "A list of DB parameters to apply"
  type = list(object({
    name         = string
    value        = string
    apply_method = string
  }))
  default = []
}

variable "project_name" {
  description = "Generic project prefix used in resource names"
  type        = string
  default     = "interview-demo"
}
