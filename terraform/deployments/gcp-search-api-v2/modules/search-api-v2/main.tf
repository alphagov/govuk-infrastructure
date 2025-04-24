terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.65.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    # required for `google_service_usage_consumer_quota_override` resources
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.0"
    }
  }

  required_version = "~> 1.10"
}

locals {
  display_name = title(var.name)
}

resource "google_project" "environment_project" {
  name       = "Search API V2 ${local.display_name}"
  project_id = "search-api-v2-${var.name}"

  folder_id       = var.google_cloud_folder
  billing_account = var.google_cloud_billing_account

  labels = {
    "programme"         = "govuk"
    "team"              = "govuk-search-improvement"
    "govuk_environment" = var.name
  }
}

resource "google_project_iam_member" "environment_project_owner" {
  project = google_project.environment_project.project_id
  role    = "roles/owner"

  member = "group:govuk-gcp-access@digital.cabinet-office.gov.uk"
}

resource "google_project_service" "api_service" {
  for_each = var.google_cloud_apis

  project                    = google_project.environment_project.project_id
  service                    = each.value
  disable_dependent_services = true
}

resource "google_service_usage_consumer_quota_override" "discoveryengine_search_requests" {
  provider = google-beta
  project  = google_project.environment_project.project_id

  service = "discoveryengine.googleapis.com"
  metric  = urlencode("discoveryengine.googleapis.com/search_requests")
  force   = true

  # limit is equivalent to `unit` field when making a GET request against the metric, but without
  # leading `1/` and without curly braces
  limit          = urlencode("/min/project")
  override_value = var.discovery_engine_quota_search_requests_per_minute
}

resource "google_service_usage_consumer_quota_override" "discoveryengine_documents" {
  provider = google-beta
  project  = google_project.environment_project.project_id

  service = "discoveryengine.googleapis.com"
  metric  = urlencode("discoveryengine.googleapis.com/documents")
  force   = true

  # limit is equivalent to `unit` field when making a GET request against the metric, but without
  # leading `1/` and without curly braces
  limit          = urlencode("/project")
  override_value = var.discovery_engine_quota_documents
}

data "tfe_oauth_client" "github" {
  organization     = var.tfc_organization_name
  service_provider = "github"
}

# Set up Workload Identity Federation between Terraform Cloud and GCP
# see https://github.com/hashicorp/terraform-dynamic-credentials-setup-examples
resource "google_iam_workload_identity_pool" "tfc_pool" {
  project                   = google_project.environment_project.project_id
  workload_identity_pool_id = "terraform-cloud-id-pool"

  display_name = "Terraform Cloud ID Pool"
  description  = "Pool to enable access to project resources for Terraform Cloud"
}

resource "google_iam_workload_identity_pool_provider" "tfc_provider" {
  project                            = google_project.environment_project.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.tfc_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "terraform-cloud-provider-oidc"

  display_name = "Terraform Cloud OIDC Provider"
  description  = "Configures Terraform Cloud as an external identity provider for this project"

  attribute_mapping = {
    "google.subject"                        = "assertion.sub",
    "attribute.aud"                         = "assertion.aud",
    "attribute.terraform_run_phase"         = "assertion.terraform_run_phase",
    "attribute.terraform_project_id"        = "assertion.terraform_project_id",
    "attribute.terraform_project_name"      = "assertion.terraform_project_name",
    "attribute.terraform_workspace_id"      = "assertion.terraform_workspace_id",
    "attribute.terraform_workspace_name"    = "assertion.terraform_workspace_name",
    "attribute.terraform_organization_id"   = "assertion.terraform_organization_id",
    "attribute.terraform_organization_name" = "assertion.terraform_organization_name",
    "attribute.terraform_run_id"            = "assertion.terraform_run_id",
    "attribute.terraform_full_workspace"    = "assertion.terraform_full_workspace",
  }

  oidc {
    issuer_uri = "https://${var.tfc_hostname}"
  }

  attribute_condition = "assertion.sub.startsWith(\"organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:${var.environment_workspace_name}\")"
}

resource "google_service_account" "tfc_service_account" {
  project = google_project.environment_project.project_id

  account_id   = "tfc-service-account"
  display_name = "Terraform Cloud Service Account"
  description  = "Used by Terraform Cloud to manage resources in this project through Workload Identity Federation"
}

resource "google_service_account_iam_member" "tfc_service_account_member" {
  service_account_id = google_service_account.tfc_service_account.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.tfc_pool.name}/*"
}

resource "google_project_iam_member" "tfc_project_member" {
  project = google_project.environment_project.project_id

  role   = "roles/owner"
  member = "serviceAccount:${google_service_account.tfc_service_account.email}"
}
