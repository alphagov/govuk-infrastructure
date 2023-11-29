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
