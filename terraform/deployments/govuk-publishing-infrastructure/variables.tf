variable "govuk_aws_state_bucket" {
  type        = string
  description = "The name of the S3 bucket used for govuk-aws's Terraform state files."
}

variable "govuk_environment" {
  type        = string
  description = "GOV.UK environment where resources are being deployed"
}

variable "force_destroy" {
  type        = bool
  description = "Setting for force_destroy on resources such as S3 buckets and Route53 zones. For use in non-production environments to allow for automated tear-down."
  default     = false
}

variable "frontend_memcached_node_type" {
  type        = string
  description = "Instance type for the Frontend memcached."
}

variable "shared_redis_cluster_node_type" {
  type        = string
  description = "Instance type for the shared Redis cluster. t1 and t2 instances are not supported."
}

variable "licensify_documentdb_instance_count" {
  type        = number
  default     = 3
  description = "Number of instances to create for the Licensify DocumentDB cluster"
}

variable "licensify_backup_retention_period" {
  type        = number
  default     = 5
  description = "Number of days to keep Licensify DocumentDB backups for"
}

variable "shared_documentdb_instance_count" {
  type        = number
  default     = 3
  description = "Number of days to keep shared DocumentDB backups for"
}

variable "shared_documentdb_backup_retention_period" {
  type        = number
  default     = 5
  description = "Number of days to keep shared DocumentDB backups for"
}

variable "search_api_lb_arn" {
  type        = string
  description = "The ARN of the search-api-v2 load balancer"
}

variable "search_api_lb_dns_name" {
  type        = string
  description = "The DNS name of the search-api-v2 load balancer"
}

variable "search_api_domain" {
  type        = string
  description = "The domain name of the API gateway"
}

variable "publishing_certificate_arn" {
  type        = string
  description = "The ARN of the publishing certificate"
}

variable "search_api_rate_limit" {
  type        = string
  description = "The rate limit applied to search API over 5 minutes"
}

variable "amazonmq_engine_version" {
  type        = string
  default     = "3.11.28"
  description = "Engine version for publishing AmazonMQ cluster"
}

variable "amazonmq_deployment_mode" {
  type        = string
  default     = "SINGLE_INSTANCE"
  description = "SINGLE_INSTANCE, ACTIVE_STANDBY_MULTI_AZ, or CLUSTER_MULTI_AZ"
}

variable "amazonmq_maintenance_window_start_day_of_week" {
  type        = string
  default     = "MONDAY"
  description = "Day of week for automated maintenance"
}

variable "amazonmq_maintenance_window_start_time_utc" {
  type        = string
  default     = "07:00"
  description = "Time to start automated maintenance"
}

variable "amazonmq_host_instance_type" {
  type        = string
  default     = "mq.t3.micro"
  description = "Instance size for publishing AmazonMQ cluster"
}

variable "amazonmq_govuk_chat_retry_message_ttl" {
  type        = number
  default     = 300000
  description = "Time in miliseconds before messages in the govuk_chat_retry queue expires and are sent back to the govuk_chat_published_ducoments queue through the dead letter mechanism"
}
