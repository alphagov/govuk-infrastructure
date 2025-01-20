variable "name" {
  type        = string
  description = "A short name for this environment (used in resource IDs)"
}

variable "tfc_project" {
  type = object({
    id   = string
    name = string
  })
  description = "The Terraform Cloud/Enterprise project to create workspaces under"
}

variable "upstream_environment_name" {
  type        = string
  description = "The name of the upstream environment, if any (used to wait for a successful apply on a 'lower' environment before applying this one)"
  default     = null
}

variable "tfc_organization_name" {
  type        = string
  description = "The name of the Terraform Cloud/Enterprise organization to use"
  default     = "govuk"
}

variable "google_project_id" {
  description = "The GCP project ID for the environment"
  type        = string
}

variable "google_project_number" {
  description = "The GCP project number for the environment"
  type        = string
}

variable "google_workload_provider_name" {
  description = "The workload provider name to authenticate against on GCP"
  type        = string
}

variable "google_service_account_email" {
  description = "The GCP service account email runs will use to authenticate"
  type        = string
}
