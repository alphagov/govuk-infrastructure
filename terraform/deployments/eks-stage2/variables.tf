variable "assume_role_arn" {
  type        = string
  description = "(optional) AWS IAM role to assume. Uses the role from the environment by default."
  default     = null
}

variable "govuk_aws_state_bucket" {
  type        = string
  description = "Name of the S3 bucket used for govuk-aws's Terraform state."
}

variable "eks_state_bucket" {
  type        = string
  description = "Name of the S3 bucket for the (first-stage) 'eks' module's Terraform state. Must match the name of the bucket specified in the backend config file."
}
