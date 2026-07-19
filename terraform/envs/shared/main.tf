# Shared Environment Configuration
# This file configures the shared resources including VPC, bastion host, and Grafana

provider "aws" {
  region = var.aws_region

  # Assume role for cross-account access if needed
  dynamic "assume_role" {
    for_each = var.assume_role_arn != "" ? [1] : []

    content {
      role_arn = var.assume_role_arn
    }
  }
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}


# Get availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  environment = "shared"
  vpc_cidr    = var.vpc_cidr

  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

}

# Bastion Host using EC2 module
module "bastion" {
  source = "../../modules/ec2"

  name          = "${var.project_name}-shared-bastion"
  description   = "Security group for bastion host"
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.random_public_subnet # Random AZ selection
  ami_id        = var.bastion_ami_id
  instance_type = var.bastion_instance_type
  key_name      = var.key_name
  assign_eip    = true

  # Root volume configuration
  root_volume_size = var.bastion_root_volume_size
  root_volume_type = var.bastion_root_volume_type

  # ingress_rules = [
  # ]

  # Security group rules
  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.bastion_allowed_ips
      description = "SSH access from allowed IPs"
    },
    {
      from_port   = 9187
      to_port     = 9187
      protocol    = "tcp"
      source_security_group_id = module.grafana.ec2_security_group_id
      description = "Postgres exporter access from Grafana"
    },
    {
      from_port   = 9100
      to_port     = 9100
      protocol    = "tcp"
      source_security_group_id = [module.grafana.ec2_security_group_id]
      description = "Node exporter access from Grafana"
    }
  ]

  # Egress rules for bastion outbound access
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "All outbound traffic"
    }
  ]

  # No IAM instance profile needed for basic EC2 instances

}

# Grafana using EC2 module
module "grafana" {
  source = "../../modules/ec2"

  name        = "${var.project_name}-shared-grafana"
  description = "Security group for Grafana"
  vpc_id      = module.vpc.vpc_id

  subnet_id     = module.vpc.random_private_subnet # Random AZ selection
  ami_id        = var.grafana_ami_id
  instance_type = var.grafana_instance_type
  key_name      = var.key_name
  assign_eip    = false

  # Root volume configuration
  root_volume_size = var.grafana_root_volume_size
  root_volume_type = var.grafana_root_volume_type

  # Security group rules
  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [module.vpc.vpc_cidr_block]
      description = "SSH access from VPC"
    },
    {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = [module.vpc.vpc_cidr_block]
      description = "Grafana web interface from ALB"
    },
    {
      from_port   = 9090
      to_port     = 9090
      protocol    = "tcp"
      cidr_blocks = var.grafana_alb_allowed_ips
      description = "Prometheus access from browser"
    },
    {
      from_port   = 3100
      to_port     = 3100
      protocol    = "tcp"
      cidr_blocks = [module.vpc.vpc_cidr_block]
      description = "Loki access from nodes"
    },
    {
      from_port   = 9100
      to_port     = 9100
      protocol    = "tcp"
      cidr_blocks = [module.vpc.vpc_cidr_block]
      description = "Node Exporter metrics from VPC"
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = [module.vpc.vpc_cidr_block]
      description = "Application metrics from VPC"
    },
    {
      from_port   = 8125
      to_port     = 8125
      protocol    = "udp"
      cidr_blocks = [module.vpc.vpc_cidr_block]
      description = "StatsD metrics from VPC"
    }
  ]


  # No IAM instance profile needed for basic EC2 instances

}

# Internal Tooling Server using EC2 module
module "internal_tooling" {
  source = "../../modules/ec2"

  name        = "${var.project_name}-shared-internal-tooling"
  description = "Security group for internal tooling server"
  vpc_id      = module.vpc.vpc_id

  subnet_id     = module.vpc.random_private_subnet # Random AZ selection
  ami_id        = var.internal_tooling_ami_id
  instance_type = var.internal_tooling_instance_type
  key_name      = var.key_name
  assign_eip    = false

  # Root volume configuration
  root_volume_size = var.internal_tooling_root_volume_size
  root_volume_type = var.internal_tooling_root_volume_type

  # Security group rules
  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [module.vpc.vpc_cidr_block]
      description = "SSH access from VPC"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = var.internal_tooling_allowed_ips
      description = "HTTP access"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = var.internal_tooling_allowed_ips
      description = "HTTPS access"
    }
  ]

  # Egress rules for internal tooling outbound access
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "All outbound traffic"
    }
  ]


}

# Application Load Balancer for Grafana
resource "aws_lb" "grafana" {
  name               = "${var.project_name}-shared-grafana-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.grafana_alb.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

}

# Security Group for Grafana Application Load Balancer
resource "aws_security_group" "grafana_alb" {
  name        = "${var.project_name}-shared-grafana-alb-sg"
  description = "Security group for Grafana Application Load Balancer - allows HTTP/HTTPS access from allowed IPs and VPC"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.grafana_alb_allowed_ips
    description = "HTTP access from allowed IP addresses for Grafana web interface"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.grafana_alb_allowed_ips
    description = "HTTPS access from allowed IP addresses for secure Grafana web interface"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

}

# Target Group for Grafana
resource "aws_lb_target_group" "grafana" {
  name     = "${var.project_name}-shared-grafana-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/api/health"
    matcher             = "200"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

}

# ALB Listener for Grafana
resource "aws_lb_listener" "grafana" {
  load_balancer_arn = aws_lb.grafana.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }
}

# Attach Grafana instance to target group
resource "aws_lb_target_group_attachment" "grafana" {
  target_group_arn = aws_lb_target_group.grafana.arn
  target_id        = module.grafana.instance_id
  port             = 3000
}

# These rules allow Grafana to collect metrics from other instances

data "terraform_remote_state" "prod" {
  count   = var.enable_cross_environment_monitoring ? 1 : 0
  backend = "s3"
  config = {
    bucket = var.state_bucket
    key    = "prod/terraform.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "staging" {
  count   = var.enable_cross_environment_monitoring ? 1 : 0
  backend = "s3"
  config = {
    bucket = var.state_bucket
    key    = "staging/terraform.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "dev" {
  count   = var.enable_cross_environment_monitoring ? 1 : 0
  backend = "s3"
  config = {
    bucket = var.state_bucket
    key    = "dev/terraform.tfstate"
    region = var.aws_region
  }
}

# VPC Peering to other environments

# Cross-environment monitoring security group rules for Grafana
resource "aws_security_group_rule" "grafana_metrics_from_prod" {
  count = var.enable_cross_environment_monitoring ? 1 : 0

  type                     = "ingress"
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.prod[0].outputs.monitoring_ec2_security_group_id
  security_group_id        = module.grafana.security_group_id
  description              = "Node exporter metrics from Production environment to Grafana"
}

resource "aws_security_group_rule" "grafana_app_metrics_from_prod" {
  count = var.enable_cross_environment_monitoring ? 1 : 0

  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.prod[0].outputs.monitoring_ec2_security_group_id
  security_group_id        = module.grafana.security_group_id
  description              = "Application metrics from Production environment to Grafana"
}

resource "aws_security_group_rule" "grafana_metrics_from_staging" {
  count = var.enable_cross_environment_monitoring ? 1 : 0

  type                     = "ingress"
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.staging[0].outputs.monitoring_ec2_security_group_id
  security_group_id        = module.grafana.security_group_id
  description              = "Node exporter metrics from Staging environment to Grafana"
}

resource "aws_security_group_rule" "grafana_metrics_from_dev" {
  count = var.enable_cross_environment_monitoring ? 1 : 0

  type                     = "ingress"
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.dev[0].outputs.monitoring_ec2_security_group_id
  security_group_id        = module.grafana.security_group_id
  description              = "Node exporter metrics from Development environment to Grafana"
}
