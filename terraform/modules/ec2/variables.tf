variable "name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "description" {
  description = "Description for the security group"
  type        = string
  default     = "Security group for EC2 instance"
}

variable "vpc_id" {
  description = "VPC ID where the instance will be created"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the instance will be created"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}


variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type        = string
  default     = ""
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 8
}

variable "root_volume_type" {
  description = "Root volume type"
  type        = string
  default     = "gp3"
}

variable "assign_eip" {
  description = "Whether to assign an Elastic IP"
  type        = bool
  default     = false
}

variable "additional_volumes" {
  description = "Additional EBS volumes"
  type = list(object({
    device_name = string
    volume_size = number
    volume_type = string
  }))
  default = []
}

# variable "ingress_rules" {
#   description = "Security group ingress rules"
#   type = list(object({
#     from_port                = number
#     to_port                  = number
#     protocol                 = string
#     cidr_blocks             = optional(list(string), [])
#     security_groups         = optional(list(string), [])
#     source_security_group_id = optional(string, "")
#     description              = string
#   }))
#   default = []
# }

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = optional(list(string), [])
    security_groups  = optional(list(string), [])
    description      = string
  }))
  default = []
}


variable "egress_rules" {
  description = "Security group egress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "All outbound traffic"
    }
  ]
}


variable "ignore_changes" {
  description = "List of attributes to ignore changes for to prevent unnecessary recreation"
  type        = list(string)
  default     = ["instance_type", "key_name", "user_data", "vpc_security_group_ids"]
}


# variable "ingress_rules" { type = list(object({
#   from_port   = number
#   to_port     = number
#   protocol    = string
#   cidr_blocks = list(string)
#   description = optional(string)
# })) }
