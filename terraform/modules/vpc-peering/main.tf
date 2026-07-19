# VPC Peering Module
# Creates VPC peering connections between VPCs

resource "aws_vpc_peering_connection" "vpc_peering_connection" {
  vpc_id      = var.requester_vpc_id
  peer_vpc_id = var.accepter_vpc_id
  peer_region = var.peer_region
  auto_accept = var.auto_accept

}

# Accept the peering connection (if auto_accept is false)
resource "aws_vpc_peering_connection_accepter" "vpc_peering_accepter" {
  count                     = var.auto_accept ? 0 : 1
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering_connection.id
  auto_accept               = true

}

# Add routes to requester route tables
resource "aws_route" "requester" {
  count                     = length(var.requester_route_table_ids)
  route_table_id            = var.requester_route_table_ids[count.index]
  destination_cidr_block    = var.accepter_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering_connection.id
}

# Add routes to accepter route tables
resource "aws_route" "accepter" {
  count                     = length(var.accepter_route_table_ids)
  route_table_id            = var.accepter_route_table_ids[count.index]
  destination_cidr_block    = var.requester_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering_connection.id
}

# Security group rules for VPC peering traffic
resource "aws_security_group_rule" "requester_ingress" {
  count             = var.requester_security_group_id != "" ? 1 : 0
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = [var.accepter_cidr]
  security_group_id = var.requester_security_group_id
  description       = "Allow all traffic from ${var.name} accepter VPC (${var.accepter_cidr}) to requester VPC"
}

resource "aws_security_group_rule" "accepter_ingress" {
  count             = var.accepter_security_group_id != "" ? 1 : 0
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = [var.requester_cidr]
  security_group_id = var.accepter_security_group_id
  description       = "Allow all traffic from ${var.name} requester VPC (${var.requester_cidr}) to accepter VPC"
}
