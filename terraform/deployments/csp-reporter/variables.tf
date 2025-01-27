variable "govuk_environment" {
  type        = string
  description = "GOV.UK environment where resources are being deployed"
}

variable "aws_region" {
  type        = string
  default     = "eu-west-1"
  description = "AWS region to create resources in"
}
