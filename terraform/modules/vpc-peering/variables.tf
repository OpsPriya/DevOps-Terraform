variable "name" {
  description = "Name of the VPC peering connection"
  type        = string
}

variable "requester_vpc_id" {
  description = "The ID of the requester VPC"
  type        = string
}

variable "accepter_vpc_id" {
  description = "The ID of the accepter VPC"
  type        = string
}

variable "peer_region" {
  description = "The region of the accepter VPC (if different from requester)"
  type        = string
  default     = ""
}

variable "auto_accept" {
  description = "Accept the peering connection automatically"
  type        = bool
  default     = true
}

variable "requester_route_table_ids" {
  description = "List of route table IDs in the requester VPC"
  type        = list(string)
  default     = []
}

variable "accepter_route_table_ids" {
  description = "List of route table IDs in the accepter VPC"
  type        = list(string)
  default     = []
}

variable "requester_cidr" {
  description = "CIDR block of the requester VPC"
  type        = string
}

variable "accepter_cidr" {
  description = "CIDR block of the accepter VPC"
  type        = string
}

variable "requester_security_group_id" {
  description = "Security group ID in the requester VPC to add rules to"
  type        = string
  default     = ""
}

variable "accepter_security_group_id" {
  description = "Security group ID in the accepter VPC to add rules to"
  type        = string
  default     = ""
}
