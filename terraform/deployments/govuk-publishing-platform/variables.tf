variable "content_store_cpu" {
  type = number
}

variable "content_store_memory" {
  type = number
}

variable "external_app_domain" {
  type        = string
  description = "e.g. test.govuk.digital"
}

variable "ecs_default_capacity_provider" {
  type = string
}

variable "publishing_service_domain" {
  type        = string
  description = "e.g. test.publishing.service.gov.uk"
}

variable "internal_app_domain" {
  type        = string
  description = "e.g. test.govuk-internal.digital"
}

variable "govuk_aws_state_bucket" {
  type        = string
  description = "The name of the S3 bucket used for govuk-aws's terraform state files"
}

variable "govuk_environment" {
  type        = string
  description = "The name of the environment (for example test, integration, staging or production)"
}

variable "office_cidrs_list" {
  description = "List of GDS office CIDRs"
  type        = list(any)
}

variable "frontend_desired_count" {
  type    = number
  default = 2
}

variable "draft_frontend_desired_count" {
  type    = number
  default = 1
}

variable "publisher_desired_count" {
  type    = number
  default = 1
}

variable "publishing_api_desired_count" {
  type    = number
  default = 1
}

variable "publisher_worker_desired_count" {
  type    = number
  default = 1
}

variable "content_store_desired_count" {
  type    = number
  default = 1
}

variable "draft_content_store_desired_count" {
  type    = number
  default = 1
}

variable "router_desired_count" {
  type    = number
  default = 1
}

variable "draft_router_desired_count" {
  type    = number
  default = 1
}

variable "router_api_desired_count" {
  type    = number
  default = 1
}

variable "draft_router_api_desired_count" {
  type    = number
  default = 1
}

variable "static_desired_count" {
  type    = number
  default = 1
}

variable "draft_static_desired_count" {
  type    = number
  default = 1
}

variable "signon_desired_count" {
  type    = number
  default = 1
}

variable "statsd_desired_count" {
  type    = number
  default = 1
}

variable "authenticating_proxy_desired_count" {
  type    = number
  default = 1
}

variable "assume_role_arn" {
  type        = string
  description = "(optional) AWS IAM role to assume. Uses the role from the environment by default."
  default     = null
}

variable "registry" {
  type        = string
  description = "registry from which to pull container images"
}
