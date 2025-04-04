variable "govuk_environment" {
  type        = string
  description = "GOV.UK environment where resources are being deployed"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-1"
}
