output "vpc_id" {
  description = "The ID of the shared VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the shared VPC"
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

output "public_route_table_ids" {
  description = "List of public route table IDs"
  value       = module.vpc.public_route_table_ids
}

output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = module.vpc.private_route_table_ids
}

output "bastion_security_group_id" {
  description = "Security group ID of the bastion host"
  value       = module.bastion.security_group_id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = module.bastion.public_ip
}

output "grafana_security_group_id" {
  description = "Security group ID of Grafana"
  value       = module.grafana.security_group_id
}

output "grafana_private_ip" {
  description = "Private IP of Grafana"
  value       = module.grafana.private_ip
}

output "grafana_endpoint" {
  description = "Grafana endpoint URL"
  value       = "http://${module.grafana.private_ip}:3000"
}

output "internal_tooling_security_group_id" {
  description = "Security group ID of the internal tooling server"
  value       = module.internal_tooling.security_group_id
}

output "internal_tooling_private_ip" {
  description = "Private IP of the internal tooling server"
  value       = module.internal_tooling.private_ip
}

output "internal_tooling_endpoint" {
  description = "Internal tooling server endpoint URL"
  value       = "http://${module.internal_tooling.private_ip}"
}

# Load Balancer Outputs
output "grafana_load_balancer_dns" {
  description = "DNS name of the Grafana load balancer"
  value       = aws_lb.grafana.dns_name
}

output "grafana_load_balancer_zone_id" {
  description = "Zone ID of the Grafana load balancer"
  value       = aws_lb.grafana.zone_id
}

output "grafana_alb_endpoint" {
  description = "Grafana ALB endpoint URL"
  value       = "http://${aws_lb.grafana.dns_name}"
}

# Monitoring Outputs - Direct security group references
output "monitoring_eks_security_group_id" {
  description = "Security group ID for EKS monitoring (not applicable in shared)"
  value       = ""
}

output "monitoring_ec2_security_group_id" {
  description = "Security group ID for EC2 monitoring"
  value       = module.grafana.security_group_id
}
