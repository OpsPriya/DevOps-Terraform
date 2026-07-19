# VPC Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

# EKS Outputs
output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_certificate_authority" {
  description = "The certificate authority data for the EKS cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "eks_cluster_security_group_id" {
  description = "The security group ID of the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

# RDS Outputs
output "rds_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = module.rds.rds_instance_endpoint
}

output "rds_port" {
  description = "The port on which the RDS instance is listening"
  value       = module.rds.rds_instance_port
}

# Elasticsearch Outputs
output "elasticsearch_endpoint" {
  description = "Elasticsearch endpoint URL"
  value       = "http://${module.elasticsearch.private_ip}:9200"
}

output "elasticsearch_kibana_endpoint" {
  description = "Elasticsearch Kibana endpoint URL"
  value       = "http://${module.elasticsearch.private_ip}:5601"
}

# Bastion and Grafana are centralized in shared environment
# Access bastion via: cd ../shared && terraform output bastion_public_ip
# Access Grafana via: cd ../shared && terraform output grafana_endpoint

# VPC Peering Outputs
output "vpc_peering_connection_id" {
  description = "The ID of the VPC peering connection"
  value       = module.vpc_peering.peering_connection_id
}

# Common
output "region" {
  description = "AWS region"
  value       = var.aws_region
}
