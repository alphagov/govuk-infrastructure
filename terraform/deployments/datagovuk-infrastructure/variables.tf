variable "govuk_aws_state_bucket" {
  type        = string
  description = "The name of the S3 bucket used for govuk-aws's Terraform state files."
}

variable "ckan_s3_organogram_bucket" {
  type        = string
  description = "Bucket for CKAN organogram data"
}

variable "ckan_service_account_namespace" {
  type        = string
  description = "Namespace in which the CKAN service account resides"
  default     = "datagovuk"
}

variable "ckan_service_account_name" {
  type        = string
  description = "Name of the service account CKAN will use"
  default     = "ckan"
}

variable "govuk_environment" {
  type        = string
  description = "Acceptable values are test, integration, staging, production"
}
