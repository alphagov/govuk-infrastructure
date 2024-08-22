resource "google_service_account" "fastly_writer" {
  account_id  = "fastly-bigquery-writer"
  description = "Service account for Fastly to write logs to BigQuery"
}

resource "google_service_account_iam_binding" "fastly_writer" {
  service_account_id = google_service_account.fastly_writer.name

  role = "roles/iam.serviceAccountTokenCreator"
  members = [
    "serviceAccount:fastly-logging@datalog-bulleit-9e86.iam.gserviceaccount.com"
  ]
}
