output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.rds_instance_endpoint
}

output "rds_password_secret_arn" {
  description = "ARN of the RDS password secret in AWS Secrets Manager"
  value       = module.rds.rds_password_secret_arn
}

output "rds_password_secret_name" {
  description = "Name of the RDS password secret in AWS Secrets Manager"
  value       = module.rds.rds_password_secret_name
}

output "database_connection_details" {
  description = "Database connection details (sensitive)"
  value       = module.rds.database_connection_details
  sensitive   = true
}

# Bastion and Grafana are centralized in shared environment
# Access bastion via: cd ../shared && terraform output bastion_public_ip
# Access Grafana via: cd ../shared && terraform output grafana_endpoint
