# Log Sink Permissions
resource "google_bigquery_dataset_iam_member" "sink_writer" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.audit_logs.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = google_logging_project_sink.bq_read_sink.writer_identity
}

resource "google_project_iam_audit_config" "bq_audit" {
  project = var.project_id
  service = "bigquery.googleapis.com"
  audit_log_config {
    log_type = "DATA_READ"
  }
}

# Alert Query Permissions
resource "google_project_iam_member" "query_executor" {
  project = var.project_id
  role    = "roles/bigquery.editor"
  member  = "serviceAccount:${google_service_account.query_executor.email}"
}

data "google_project" "project" {
  project_id = var.project_id
}

# Allows the BQ Transfer Service Agent to act as query_executor.
resource "google_service_account_iam_member" "token_creator" {
  service_account_id = google_service_account.query_executor.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-biqquerydatatransfer.iam.gserviceaccount.com"
}
