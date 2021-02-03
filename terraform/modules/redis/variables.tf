variable "cluster_name" {
  type    = string
  default = "shared"
}

variable "internal_app_domain" {
  description = "Domain in which to create DNS records for private resources. For example, test.govuk-internal.digital"
  type        = string
  default     = "test.govuk-internal.digital"
}

variable "subnet_ids" {
  type        = list
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
