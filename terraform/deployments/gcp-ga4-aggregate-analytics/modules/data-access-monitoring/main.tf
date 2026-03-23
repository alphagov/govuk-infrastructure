resource "google_bigquery_dataset" "audit_logs" {
  project    = var.project_id
  dataset_id = "data_access_logs"
  location   = "europe-west2"
}

resource "google_logging_project_sink" "bq_read_sink" {
  project     = var.project_id
  name        = "bq-read-audit-sink"
  destination = "bigquery.googleapis.com/${google_bigquery_dataset.audit_logs.id}"

  filter = <<EOT
    (protoPayload.metadata.tableDataRead:* OR protoPayload.methodName:"google.cloud.bigquery.storage.v1.BigQueryRead.CreateReadSession")
  EOT

  exclusions {
    name        = "exclude-audit-dataset-loop"
    description = "Prevents the sink from logging its own writes to the audit dataset"
    filter      = "protoPayload.resourceName:\"projects/${var.project_id}/datasets/${google_bigquery_dataset.audit_logs.dataset_id}\""
  }

  unique_writer_identity = true

  bigquery_options {
    use_partitioned_tables = true
  }
}
