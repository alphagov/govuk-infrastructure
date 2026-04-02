locals {
  data_processing_roles = [
    "roles/bigquery.admin",
    "roles/bigquery.jobUser",
    "roles/secretmanager.secretAccessor",
  ]
}

resource "google_project_iam_member" "data_processing_permissions" {
  for_each = toset(local.data_processing_roles)
  project  = google_project.project.project_id
  role     = each.key
  member   = "serviceAccount:${google_service_account.data_processing.email}"
}
