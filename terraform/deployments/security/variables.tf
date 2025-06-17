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
  description = "GOV.UK environment where resources are being deployed"
}

variable "fastly_account_id" {
  type        = string
  description = "GOV.UK Fastly Account ID"
  default     = ""
}