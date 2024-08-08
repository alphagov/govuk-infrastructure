variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-1"
}
variable "govuk_aws_state_bucket" {
  type        = string
  description = "Bucket where govuk-aws state is stored"
}
variable "govuk_environment" {
  type        = string
  description = "Acceptable values are test, integration, staging, production"
}

variable "chat_redis_cluster_apply_immediately" {
  type        = bool
  description = "Specifies whether any modifications are applied immediately, or during the next maintenance window."
}
variable "chat_redis_cluster_node_type" {
  type        = string
  description = "Instance class to be used."
}
variable "chat_redis_cluster_num_cache_clusters" {
  type        = string
  description = "Number of cache clusters (primary and replicas) this replication group will have."
}
variable "chat_redis_cluster_automatic_failover_enabled" {
  type        = bool
  description = "Specifies whether a read-only replica will be automatically promoted to read/write primary if the existing primary fails."
}
variable "chat_redis_cluster_multi_az_enabled" {
  type        = bool
  description = "Specifies whether to enable Multi-AZ Support for the replication group."
}
variable "chat_redis_cluster_parameter_group_name" {
  type        = string
  description = "Name of the parameter group to associate with this replication group. If this argument is omitted, the default cache parameter group for the specified engine is used."
}
variable "chat_redis_cluster_engine_version" {
  type        = string
  description = "Version number of the cache engine to be used for the cache clusters in this replication group."
}
variable "cloudfront_create" {
  description = "Create Cloudfront resources."
  type        = bool
  default     = false
}
variable "cloudfront_enable" {
  description = "Enable Cloudfront distributions."
  type        = bool
  default     = false
}
variable "service_disabled" {
  description = "Disable GOV.UK Chat service by serving a static error page."
  type        = bool
  default     = false
}
variable "origin_chat_domain" {
  type = string
}
variable "origin_chat_id" {
  type = string
}
variable "cloudfront_chat_distribution_aliases" {
  type        = list(any)
  description = "Additional CNAMEs to create for the Chat CloudFront distribution."
  default     = []
}
variable "chat_certificate_arn" {
  type        = string
  description = "ARN of the TLS cert to use for the Chat CloudFront distribution."
}

