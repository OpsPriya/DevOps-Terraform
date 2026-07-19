# VPC Module
# Creates VPC, subnets, route tables, and other networking components

# Data sources
data "aws_availability_zones" "available" {
  state = "available"

  # Filter out AZs that don't support EKS or have limited capacity
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Check which AZs support EKS by testing multiple instance types
data "aws_ec2_instance_type_offerings" "eks_azs" {
  filter {
    name   = "instance-type"
    values = ["t3.medium", "t3.large", "m5.large"] # Common EKS instance types
  }
  location_type = "availability-zone"
}

# Get EKS-supported AZs by filtering available AZs with those that support EKS instance types
locals {
  # Get AZs that support EKS instance types
  eks_supported_azs = data.aws_ec2_instance_type_offerings.eks_azs.locations

  # Known problematic AZs that should be excluded (region-specific)
  problematic_azs = [
    for az in data.aws_availability_zones.available.names :
    az if can(regex(".*-1e$", az)) # Exclude AZs ending with -1e (like us-east-1e)
  ]

  # Filter available AZs to only include those that support EKS and are not problematic
  eks_available_azs = [
    for az in data.aws_availability_zones.available.names :
    az if contains(local.eks_supported_azs, az) && !contains(local.problematic_azs, az)
  ]
}

data "aws_region" "current" {}

# Local variables for subnet calculation
locals {
  # Get available AZ count (use EKS-supported AZs)
  az_count = length(local.eks_available_azs)

  # Extract the second octet from VPC CIDR (e.g., "10.0.0.0/16" -> "3")
  vpc_second_octet = split(".", var.vpc_cidr)[1]

  # Calculate private subnets: 10.X.1.0/24, 10.X.2.0/24, 10.X.3.0/24, etc.
  calculated_private_subnets = [
    for i in range(local.az_count) :
    "10.${local.vpc_second_octet}.${i + 1}.0/24"
  ]

  # Calculate public subnets: 10.X.11.0/24, 10.X.12.0/24, 10.X.13.0/24, etc.
  calculated_public_subnets = [
    for i in range(local.az_count) :
    "10.${local.vpc_second_octet}.${i + 11}.0/24"
  ]

  # Use calculated subnets if auto_calculate is enabled, otherwise use provided values
  private_subnets = var.auto_calculate_subnets && length(var.private_subnets) == 0 ? local.calculated_private_subnets : var.private_subnets
  public_subnets  = var.auto_calculate_subnets && length(var.public_subnets) == 0 ? local.calculated_public_subnets : var.public_subnets
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(local.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.public_subnets[count.index]
  availability_zone       = local.eks_available_azs[count.index]
  map_public_ip_on_launch = true

}

# Private Subnets
resource "aws_subnet" "private" {
  count             = length(local.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.private_subnets[count.index]
  availability_zone = local.eks_available_azs[count.index]

}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

}

# NAT Gateways (2 for high availability)
resource "aws_eip" "nat" {
  count  = 2
  domain = "vpc"

}

resource "aws_nat_gateway" "main" {
  count         = 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id # Place NAT Gateways in first 2 public subnets


  depends_on = [aws_internet_gateway.main]
}

# Public Route Tables (one per AZ)
resource "aws_route_table" "public" {
  count  = length(local.public_subnets)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

}

# Private Route Tables (one per AZ)
# AZs 0-2 use NAT Gateway 1, AZs 3-4 use NAT Gateway 2 for high availability
resource "aws_route_table" "private" {
  count  = length(local.private_subnets)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = count.index < 3 ? aws_nat_gateway.main[0].id : aws_nat_gateway.main[1].id
  }

}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count          = length(local.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}

resource "aws_route_table_association" "private" {
  count          = length(local.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
