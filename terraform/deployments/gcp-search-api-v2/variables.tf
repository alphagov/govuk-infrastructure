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

variable "google_cloud_folder" {
  type        = string
  description = "The ID of the Google Cloud folder to create projects under"
}

variable "google_cloud_billing_account" {
  type        = string
  description = "The ID of the Google Cloud billing account to associate projects with"
}

variable "project_id" {
  type        = string
  description = "The ID of the overarching terraform cloud project for all workspaces"
}

variable "tfe_project_name" {
  type        = string
  default     = "govuk-search-api-v2"
  description = "The  name of the overarching terraform cloud project for all workspaces"
}
