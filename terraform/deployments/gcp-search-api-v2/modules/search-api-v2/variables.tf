variable "name" {
  type        = string
  description = "A short name for this environment (used in resource IDs)"
}

variable "google_cloud_folder" {
  type        = string
  description = "The ID of the Google Cloud folder to create projects under"
}

variable "google_cloud_billing_account" {
  type        = string
  description = "The ID of the Google Cloud billing account to associate projects with"
}

variable "google_cloud_apis" {
  type        = set(string)
  description = "The Google Cloud APIs to enable for the project"
  default = [
    # Required to be able to manage resources using Terraform
    "cloudresourcemanager.googleapis.com",
    # Required to set up service accounts and manage dynamic credentials
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
    # Required for Discovery Engine
    "discoveryengine.googleapis.com",
    # Required for event data pipeline
    "bigquery.googleapis.com",
    "bigquerystorage.googleapis.com",
    "storage.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudfunctions.googleapis.com",
    "run.googleapis.com",
    "cloudscheduler.googleapis.com",
    # Required for observability
    "logging.googleapis.com",
    "monitoring.googleapis.com",
  ]
}

variable "discovery_engine_quota_search_requests_per_minute" {
  type        = number
  description = "The maximum number of search requests per minute for the Discovery Engine"
  default     = 250
}

variable "discovery_engine_quota_documents" {
  type        = number
  description = "The maximum number of documents across Discovery Engine datastores"
  default     = 1000000
}

variable "upstream_environment_name" {
  type        = string
  description = "The name of the upstream environment, if any (used to wait for a successful apply on a 'lower' environment before applying this one)"
  default     = null
}

variable "tfc_hostname" {
  type        = string
  description = "The hostname of the Terraform Cloud/Enterprise instance to use"
  default     = "app.terraform.io"
}

variable "tfc_organization_name" {
  type        = string
  description = "The name of the Terraform Cloud/Enterprise organization to use"
  default     = "govuk"
}

variable "tfc_project_name" {
  type        = string
  description = "The  name of the overarching terraform cloud project for all workspaces"
}

variable "environment_workspace_name" {
  type        = string
  description = "Provisions search-api-v2 Discovery Engine resources for the environment"
}
