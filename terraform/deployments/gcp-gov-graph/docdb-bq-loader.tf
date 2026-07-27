resource "google_service_account" "docdb_bq_loader" {
  account_id   = "docdb-bq-loader"
  display_name = "Document DB BQ Loader"
}

# Allow the deployment SA to pull images
data "google_iam_policy" "service_account_user_docdb_bq_loader" {
  binding {
    role = "roles/iam.serviceAccountUser"

    members = [
      google_service_account.artifact_registry_docker.member,
    ]
  }
}

resource "google_service_account_iam_policy" "service_account_user_docdb_bq_loader" {
  service_account_id = google_service_account.docdb_bq_loader.name
  policy_data        = data.google_iam_policy.service_account_user_docdb_bq_loader.policy_data
}
