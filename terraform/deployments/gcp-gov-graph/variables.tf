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

variable "name" {
  type        = string
  description = "A short name for this environment (used in resource IDs)"
}

variable "folder_id" {
  type        = string
  description = "The ID of the Google Cloud folder to create projects under"
}

variable "billing_account" {
  type        = string
  description = "The ID of the Google Cloud billing account to associate projects with"
}

variable "services" {
  type        = set(string)
  description = "The Google Cloud APIs to enable for the project"
  default = [
    "storage.googleapis.com",
    "iam.googleapis.com",
    "appengine.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudscheduler.googleapis.com",
    "cloudfunctions.googleapis.com",
    "bigquery.googleapis.com",
    "bigqueryconnection.googleapis.com",
    "bigquerydatatransfer.googleapis.com",
    "run.googleapis.com",
    "compute.googleapis.com",
    "dns.googleapis.com",
    "eventarc.googleapis.com",
    "networkmanagement.googleapis.com",
    "pubsub.googleapis.com",
    "sourcerepo.googleapis.com",
    "vpcaccess.googleapis.com",
    "workflows.googleapis.com",
    "iap.googleapis.com",
    "secretmanager.googleapis.com",
    "redis.googleapis.com",
    "dlp.googleapis.com",
    "cloudquotas.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
    "discoveryengine.googleapis.com",
    "bigquerystorage.googleapis.com",
    "cloudbuild.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ]
}

variable "tfc_project_name" {
  type        = string
  description = "The name of the overarching terraform cloud project for all workspaces"
}

variable "environment_workspace_name" {
  type        = string
  description = "Provisions resources for the environment"
}

variable "access_group_name" {
  type        = string
  description = "The google group that should be able to access the environment"
}

variable "region" {
  type    = string
  default = "europe-west2"
}

variable "zone" {
  type    = string
  default = "europe-west2-b"
}

variable "location" {
  type        = string
  description = "Google Cloud Storage location"
  default     = "EUROPE-WEST2"
}

variable "project_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "project_number" {
  type = string
}

variable "govgraph_domain" {
  type = string
}

variable "govgraphsearch_domain" {
  type = string
}

variable "govsearch_domain" {
  type = string
}

variable "application_title" {
  type = string
}

variable "enable_auth" {
  type = string
}

variable "signon_url" {
  type = string
}

variable "oauth_auth_url" {
  type = string
}

variable "oauth_token_url" {
  type = string
}

variable "oauth_callback_url" {
  type = string
}

variable "enable_redis_session_store_instance" {
  type = bool
}

variable "gtm_id" {
  type = string
}

variable "gtm_auth" {
  type = string
}

variable "project_owner_members" {
  type = set(string)
}

variable "iap_govgraphsearch_members" {
  type = set(string)
}

variable "bigquery_job_user_members" {
  type = set(string)
}

variable "storage_data_processed_object_viewer_members" {
  type = set(string)
}

variable "bigquery_private_data_viewer_members" {
  type = set(string)
}

variable "bigquery_public_data_viewer_members" {
  type = set(string)
}

variable "bigquery_content_data_viewer_members" {
  type = set(string)
}

variable "bigquery_publisher_data_viewer_members" {
  type = set(string)
}

variable "bigquery_functions_data_viewer_members" {
  type = set(string)
}

variable "bigquery_graph_data_viewer_members" {
  type = set(string)
}

variable "bigquery_publishing_api_data_viewer_members" {
  type = set(string)
}

variable "bigquery_smart_survey_data_viewer_members" {
  type = set(string)
}

variable "bigquery_support_api_data_viewer_members" {
  type = set(string)
}

variable "bigquery_search_data_viewer_members" {
  type = set(string)
}

variable "bigquery_test_data_viewer_members" {
  type = set(string)
}

variable "bigquery_whitehall_data_viewer_members" {
  type = set(string)
}

variable "bigquery_asset_manager_data_viewer_members" {
  type = set(string)
}

variable "bigquery_zendesk_data_viewer_members" {
  type = set(string)
}
