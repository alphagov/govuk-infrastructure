variable "cluster_name" {
  type    = string
  default = "shared"
}

variable "subnet_ids" {
  type        = list(any)
  description = "Subnet IDs to assign to the aws_elasticache_subnet_group"
}


variable "node_type" {
  type        = string
  description = "The node type to use. Must not be t.* in order to use failover."
  default     = "cache.m3.medium"
}

variable "vpc_id" {
  type = string
}

variable "internal_private_zone_id" {
  type = string
}

variable "workspace" {
  type = string
}

variable "environment" {
  type = string
}

variable "additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}
