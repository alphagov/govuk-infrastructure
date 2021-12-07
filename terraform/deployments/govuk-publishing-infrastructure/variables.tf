variable "govuk_aws_state_bucket" {
  type        = string
  description = "The name of the S3 bucket used for govuk-aws's Terraform state files."
}

variable "cluster_infrastructure_state_bucket" {
  type        = string
  description = "Name of the S3 bucket for the cluster-infrastructure module's Terraform state. Must match the name of the bucket specified in the backend config file."
}

variable "shared_redis_cluster_name" {
  type        = string
  description = "Name of the shared Redis cluster"
  default     = "shared-redis"
}

variable "shared_redis_cluster_port" {
  type        = number
  description = "Port of the shared Redis cluster"
  default     = 6379
}

variable "shared_redis_cluster_node_type" {
  type        = string
  description = "Node type to used for the shared Redis cluster. Must not be t.* in order to use failover."
  default     = "cache.m3.medium"
}

variable "govuk_environment" {
  type        = string
  description = "GOV.UK environment where resources are being deployed"
}
