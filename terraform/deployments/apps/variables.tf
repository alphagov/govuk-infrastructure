#--------------------------------------------------------------
# Application
#--------------------------------------------------------------

variable "image_tag" {
  type        = string
  description = "The Docker image tag to be specified in a task definition"
}

#--------------------------------------------------------------
# Common
#--------------------------------------------------------------

variable "mesh_name" {
  type = string
}

variable "mesh_domain" {
  type = string
}

#--------------------------------------------------------------
# Environment
#--------------------------------------------------------------

variable "app_domain" {
  type        = string
  description = "Example: staging.publishing.service.gov.uk"
}

variable "app_domain_internal" {
  type        = string
  description = "Example: integration.govuk-internal.digital"
}

variable "govuk_environment" {
  type        = string
  description = "Examples: test, integration, staging, production"
}

variable "mongodb_host" {
  description = "Hostname for the Shared MongoDB (defined outside this Terraform repo)."
  type        = string
}

variable "redis_host" {
  # TODO: Replace with remote state read once we define our own Redis.
  description = "Hostname for the Shared Redis (defined outside this Terraform repo)."
  type        = string
}

variable "router_mongodb_host" {
  description = "Hostname for the Router MongoDB (defined outside this Terraform repo)."
  type        = string
}

variable "sentry_environment" {
  type        = string
  description = "Usually will match the govuk_environment, e.g. test, staging"
}

variable "assume_role_arn" {
  type        = string
  description = "(optional) AWS IAM role to assume. Uses the role from the environment by default."
  default     = null
}
