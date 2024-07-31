variable "govuk_aws_state_bucket" {
  type        = string
  description = "The name of the S3 bucket used for govuk-aws's Terraform state files."
}

variable "cluster_infrastructure_state_bucket" {
  type        = string
  description = "Name of the S3 bucket for the cluster-infrastructure module's Terraform state. Must match the name of the bucket specified in the backend config file."
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
