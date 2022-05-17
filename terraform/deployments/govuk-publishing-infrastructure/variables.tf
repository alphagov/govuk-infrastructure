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

variable "frontend_memcached_node_type" {
  type        = string
  description = "Instance type for the Frontend memcached."
}

variable "shared_redis_cluster_node_type" {
  type        = string
  description = "Instance type for the shared Redis cluster. t1 and t2 instances are not supported."
}

variable "www_dns_name" {
  type        = string
  description = "Name of the CNAME record to create in the eks.environment.govuk.digital zone, pointing to the CDN. Intended for use when testing Terraform alongside an existing cluster."
  default     = "www"
}

variable "www_dns_validation_name" {
  type        = string
  description = "The name (hostname part) of the CNAME record to be created for the CDN to validate ownership of the www domain name."
  default     = "_acme-challenge.www"
}

variable "www_dns_validation_rdata" {
  type        = string
  description = "The record data (contents) of the CNAME record to be created for the CDN to validate ownership of the www domain name."
}
