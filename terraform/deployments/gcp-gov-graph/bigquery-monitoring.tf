resource "google_bigquery_dataset" "monitoring" {
  dataset_id            = "monitoring"
  friendly_name         = "Monitoring"
  description           = "Monitoring Dataset"
  location              = var.region
  max_time_travel_hours = "48"
}

data "google_iam_policy" "bigquery_dataset_monitoring" {
  binding {
    role = "roles/bigquery.dataEditor"
    members = [
      "projectWriters",
      google_service_account.docdb_bq_loader.member,
      google_service_account.rds_parquet_bq_loader.member,
    ]
  }
  binding {
    role = "roles/bigquery.dataOwner"
    members = [
      "projectOwners",
    ]
  }
  binding {
    role = "roles/bigquery.dataViewer"
    members = [
      "projectReaders",
    ]
  }
}

resource "google_bigquery_dataset_iam_policy" "monitoring" {
  dataset_id  = google_bigquery_dataset.monitoring.dataset_id
  policy_data = data.google_iam_policy.bigquery_dataset_monitoring.policy_data
}
