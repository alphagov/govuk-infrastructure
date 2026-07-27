# A service account for parquet ingestion
locals {
  roles = [
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser",
    "roles/bigquery.user",
    "roles/run.invoker",
    "roles/storage.objectAdmin",
  ]
}

resource "google_service_account" "parquet_to_bq_ingestion" {
  project      = var.project_id
  account_id   = "parquet-bq-ingestion"
  display_name = "DB backup parquet file ingestion"
  description  = "Service account used for database backups parquet ingestion to BigQuery"
}

resource "google_project_iam_member" "parquet_to_bq_ingestion_roles" {
  for_each = toset(local.roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.parquet_to_bq_ingestion.email}"
}
