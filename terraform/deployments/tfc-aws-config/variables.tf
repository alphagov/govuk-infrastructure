variable "govuk_environment" {
  type        = string
  description = "The name of the AWS environment"
}

variable "tfc_hostname" {
  type        = string
  default     = "app.terraform.io"
  description = "The hostname of the TFC or TFE to use with AWS"
}

variable "tfc_organization_name" {
  type        = string
  default     = "govuk"
  description = "The name of the Terraform Cloud organization"
}

variable "billing_account_id" {
  type        = string
  default     = "015C7A-FAF970-B0D375"
  description = "The id of the gcp billing account"
}
