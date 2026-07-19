# Flexible EC2 Module - Handles bastion, grafana, elasticsearch, and other EC2 instances
# Security Group for EC2 instances
resource "aws_security_group" "ec2_security_group" {
  #name_prefix = "${var.name}-"
  name = "${var.name}-sg"
  vpc_id      = var.vpc_id
  description = var.description

  

  # dynamic "ingress" {
  #   for_each = [for rule in var.ingress_rules : rule if length(rule.cidr_blocks) > 0 || length(rule.security_groups) > 0]
  #   content {
  #     from_port        = ingress.value.from_port
  #     to_port          = ingress.value.to_port
  #     protocol         = ingress.value.protocol
  #     cidr_blocks      = length(ingress.value.cidr_blocks) > 0 ? ingress.value.cidr_blocks : null
  #     security_groups  = length(ingress.value.security_groups) > 0 ? ingress.value.security_groups : null
  #     description      = ingress.value.description
  #   }
  # }

  


  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
    }
  }


}

resource "aws_security_group_rule" "ingress" {
  for_each = { for idx, rule in var.ingress_rules : idx => rule }

  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  description       = each.value.description
  security_group_id = aws_security_group.ec2_security_group.id

  cidr_blocks              = length(each.value.cidr_blocks) > 0 ? each.value.cidr_blocks : null
  source_security_group_id = length(each.value.security_groups) > 0 ? each.value.security_groups[0] : null
  self                     = length(each.value.cidr_blocks) == 0 && length(each.value.security_groups) == 0 ? true : null

}

# Additional security group rules for cross-security-group access
# resource "aws_security_group_rule" "ec2_ingress_from_sg" {
#   for_each = {
#     for rule in var.ingress_rules : "${rule.from_port}-${rule.to_port}-${rule.protocol}" => rule
#     if rule.source_security_group_id != ""
#   }

#   type                     = "ingress"
#   from_port                = each.value.from_port
#   to_port                  = each.value.to_port
#   protocol                 = each.value.protocol
#   source_security_group_id = each.value.source_security_group_id
#   security_group_id        = aws_security_group.ec2_security_group.id
#   description              = each.value.description
# }

resource "aws_instance" "ec2_instance" {
  ami                  = var.ami_id
  instance_type        = var.instance_type
  key_name             = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  subnet_id            = var.subnet_id
  iam_instance_profile = var.iam_instance_profile

  # Allow stopping instance to update instance_type and other attributes
  instance_initiated_shutdown_behavior = "stop"

  # Root volume configuration
  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    encrypted   = true
  }

  # Additional EBS volumes
  dynamic "ebs_block_device" {
    for_each = var.additional_volumes
    content {
      device_name = ebs_block_device.value.device_name
      volume_size = ebs_block_device.value.volume_size
      volume_type = ebs_block_device.value.volume_type
      encrypted   = true
    }
  }

}

# Elastic IP (optional) - Created independently
resource "aws_eip" "ec2_eip" {
  count  = var.assign_eip ? 1 : 0
  domain = "vpc"

}

# EIP Association - Attaches EIP to instance
resource "aws_eip_association" "ec2_eip_association" {
  count         = var.assign_eip ? 1 : 0
  instance_id   = aws_instance.ec2_instance.id
  allocation_id = aws_eip.ec2_eip[0].id
}
