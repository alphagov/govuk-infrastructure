variable "mesh_name" {
  type = string
}

variable "public_lb_domain_name" {
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
  type        = list
}

variable "concourse_cidrs_list" {
  description = "List of GDS Concourse CIDRs"
  type        = list
}
