variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-1"
}

variable "fastly_account_id" {
  type        = string
  description = "GOV.UK Fastly Account ID"
}
