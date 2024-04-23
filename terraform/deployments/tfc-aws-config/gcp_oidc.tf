data "google_project" "project" {}

resource "google_iam_workload_identity_pool" "tfc" {
  workload_identity_pool_id = "terraform-cloud-${var.govuk_environment}"
  display_name              = "Terraform Cloud (${var.govuk_environment})"
  description               = "Identity pool for Terraform Cloud connection to GCP (${var.govuk_environment})"
}

resource "google_iam_workload_identity_pool_provider" "tfc" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.tfc.workload_identity_pool_id
  workload_identity_pool_provider_id = "terraform-cloud-${var.govuk_environment}"
  attribute_condition                = "assertion.sub.startsWith(\"organization:govuk:\")"
  attribute_mapping = {
    "google.subject" = "assertion.terraform_organization_name"
  }
  oidc {
    issuer_uri = "https://app.terraform.io"
  }
}

resource "google_service_account" "tfc" {
  account_id = "terraform-cloud-${var.govuk_environment}"
}

resource "google_project_iam_binding" "tfc" {
  project = "govuk-${var.govuk_environment}"
  role    = "roles/editor"
  members = ["serviceAccount:${google_service_account.tfc.email}"]
}

data "google_iam_policy" "tfc" {
  binding {
    role = "roles/iam.workloadIdentityUser"
    members = [
      "principal://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/terraform-cloud-${var.govuk_environment}/subject/govuk"
    ]
  }
}

resource "google_service_account_iam_policy" "tfc" {
  service_account_id = google_service_account.tfc.id
  policy_data        = data.google_iam_policy.tfc.policy_data
}

resource "tfe_variable_set" "gcp_variable_set" {
  name = "gcp-credentials-${var.govuk_environment}"
}

resource "tfe_variable" "tfc_var_gcp_provider_auth" {
  key             = "TFC_GCP_PROVIDER_AUTH"
  value           = "true"
  category        = "env"
  description     = "Configures Terraform Cloud to authenticate with GCP using dynamic credentials"
  variable_set_id = tfe_variable_set.gcp_variable_set.id
}

resource "tfe_variable" "tfc_var_gcp_run_service_account_email" {
  key             = "TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL"
  value           = google_service_account.tfc.email
  category        = "env"
  description     = "The service account email TFC will use with authenticating with GCP"
  variable_set_id = tfe_variable_set.gcp_variable_set.id
}

resource "tfe_variable" "tfc_var_gcp_workload_provider_name" {
  key             = "TFC_GCP_WORKLOAD_PROVIDER_NAME"
  value           = google_iam_workload_identity_pool_provider.tfc.name
  category        = "env"
  description     = "Name of the identity pool provider to use when authenticating with GCP"
  variable_set_id = tfe_variable_set.gcp_variable_set.id
}
