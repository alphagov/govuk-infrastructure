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

resource "google_project_iam_audit_config" "bq_storage_audit" {
  project = var.project_id
  service = "bigquerystorage.googleapis.com"
  audit_log_config {
    log_type = "DATA_READ"
  }
}
