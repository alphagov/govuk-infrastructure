variable "mesh_name" {
  type = string
}

variable "external_app_domain" {
  type = string
}

variable "govuk_aws_state_bucket" {
  type        = string
  description = "The name of the S3 bucket used for govuk-aws's terraform state files"
}

variable "assume_role_arn" {
  type        = string
  description = "(optional) AWS IAM role to assume. Uses the role from the environment by default."
  default     = null
}

variable "office_cidrs_list" {
  description = "List of GDS office CIDRs"
  type        = list(any)
}

variable "concourse_cidrs_list" {
  description = "List of GDS Concourse CIDRs"
  type        = list(any)
}

variable "publishing_service_domain" {
  type        = string
  description = "e.g. test.publishing.service.gov.uk"
}

variable "govuk_environment" {
  type        = string
  description = "The name of the environment (for example test, integration, staging or production)"
}
