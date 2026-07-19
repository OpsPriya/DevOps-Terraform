variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "service_principal" {
  description = "Service principal for assume role policy (used when no trust_policy_file is provided)"
  type        = string
  default     = "ec2.amazonaws.com"
}

variable "trust_policy_file" {
  description = "JSON file name for custom trust policy (e.g., for EKS OIDC)"
  type        = string
  default     = ""
}

variable "account_id" {
  description = "AWS Account ID for policy templates"
  type        = string
  default     = ""
}

variable "oidc_id" {
  description = "EKS OIDC Provider ID for policy templates"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "EKS Cluster name for policy templates"
  type        = string
  default     = ""
}

variable "region" {
  description = "AWS region for policy templates"
  type        = string
  default     = "us-east-1"
}

variable "policy_files" {
  description = "Map of policy names to JSON file names"
  type        = map(string)
  default     = {}
}

variable "managed_policy_arns" {
  description = "List of AWS managed policy ARNs to attach"
  type        = list(string)
  default     = []
}

variable "create_instance_profile" {
  description = "Whether to create an instance profile"
  type        = bool
  default     = false
}
