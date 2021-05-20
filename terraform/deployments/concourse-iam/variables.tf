variable "govuk_environment" {
  type        = string
  description = "One of test, integration, staging, production."
}

variable "production_aws_account_id" {
  type        = string
  description = "AWS account ID where Amazon Elastic Container Registry is hosted"
}

variable "concourse_aws_account_id" {
  type        = string
  description = "AWS account ID where Concourse is hosted"
}
