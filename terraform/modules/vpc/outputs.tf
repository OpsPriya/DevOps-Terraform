output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

# First subnet selection (for compatibility)
output "random_public_subnet" {
  description = "First public subnet ID (for compatibility)"
  value       = aws_subnet.public[0].id
}

output "random_private_subnet" {
  description = "First private subnet ID (for compatibility)"
  value       = aws_subnet.private[0].id
}

output "public_route_table_id" {
  description = "ID of the first public route table (for compatibility)"
  value       = aws_route_table.public[0].id
}

output "public_route_table_ids" {
  description = "List of public route table IDs"
  value       = aws_route_table.public[*].id
}

output "private_route_table_id" {
  description = "ID of the first private route table (for compatibility)"
  value       = aws_route_table.private[0].id
}

output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = aws_route_table.private[*].id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "nat_gateway_id" {
  description = "ID of the first NAT Gateway (for compatibility)"
  value       = var.enable_nat_gateway ? aws_nat_gateway.main[0].id : ""
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = var.enable_nat_gateway ? aws_nat_gateway.main[*].id : []
}

output "nat_public_ip" {
  description = "Public IP of the first NAT Gateway (for compatibility)"
  value       = var.enable_nat_gateway ? aws_eip.nat[0].public_ip : ""
}

output "nat_public_ips" {
  description = "List of NAT Gateway public IPs"
  value       = var.enable_nat_gateway ? aws_eip.nat[*].public_ip : []
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "azs" {
  description = "List of availability zones"
  value       = data.aws_availability_zones.available.names
}

output "eks_supported_azs" {
  description = "List of EKS-supported availability zones"
  value       = local.eks_available_azs
}

output "region" {
  description = "AWS region"
  value       = data.aws_region.current.id
}
