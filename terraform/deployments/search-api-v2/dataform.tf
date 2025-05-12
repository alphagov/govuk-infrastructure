variable "search_dataform_github_repository_url" {
  description = "URL of the GitHub repository to link with Dataform"
  type        = string
  default     = "git@github.com:alphagov/search_v2_api_dataform.git"
}

variable "search_dataform_github_public_key" {
  description = "Public key for the GitHub repository to link with Dataform"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"
}

resource "google_secret_manager_secret_iam_member" "member" {
  project   = var.gcp_project_id
  secret_id = "github_search_v2_api_dataform_ssh_key"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:service-${var.gcp_project_number}@gcp-sa-dataform.iam.gserviceaccount.com"
}

# Create a service account for Dataform
resource "google_service_account" "dataform_service_account" {
  account_id   = "dataform-sa"
  display_name = "Dataform Service Account"
  project      = var.gcp_project_id
}

# Create Dataform repository with GitHub integration
resource "google_dataform_repository" "search_api_v2" {
  provider = google-beta
  name     = "search_api_v2"
  project  = var.gcp_project_id
  region   = var.gcp_region

  git_remote_settings {
    url            = var.search_dataform_github_repository_url
    default_branch = var.gcp_env == "production" ? "main" : var.gcp_env
    ssh_authentication_config {
      user_private_key_secret_version = "projects/${var.gcp_project_id}/secrets/github_search_v2_api_dataform_ssh_key/versions/latest"
      host_public_key                 = var.search_dataform_github_public_key
    }
  }
}

# Create release configs
resource "google_dataform_repository_release_config" "release_config" {
  provider      = google-beta
  name          = var.gcp_env
  repository    = google_dataform_repository.search_api_v2.name
  git_commitish = var.gcp_env == "production" ? "main" : var.gcp_env
  project       = var.gcp_project_id
  region        = var.gcp_region
  code_compilation_config {
    vars = {
      project_id = var.gcp_project_id
    }
  }
}

# Create workflow configurations
resource "google_dataform_repository_workflow_config" "search-intraday" {
  provider       = google-beta
  name           = "search-intraday-${var.gcp_env}"
  repository     = google_dataform_repository.search_api_v2.name
  release_config = google_dataform_repository_release_config.release_config.id
  project        = var.gcp_project_id
  region         = var.gcp_region

  #  schedule {
  #    cron = "0 * * * *"  # Run hourly
  #  }

  invocation_config {
    included_tags = ["search-intraday"]
  }
}

# BigQuery cross-project permissions
# Service account permissions to access BigQuery
resource "google_project_iam_member" "bigquery_data_editor" {
  project = "search-api-v2-${var.gcp_env}"
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:service-${var.gcp_project_number}@gcp-sa-dataform.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "bigquery_job_user" {
  project = "search-api-v2-${var.gcp_env}"
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:service-${var.gcp_project_number}@gcp-sa-dataform.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "bigquery_data_viewer" {
  project = "search-api-v2-${var.gcp_env}"
  role    = "roles/bigquery.dataViewer"
  member  = "serviceAccount:service-${var.gcp_project_number}@gcp-sa-dataform.iam.gserviceaccount.com"
}
