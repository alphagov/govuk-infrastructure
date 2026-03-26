# Scheduled queries that don't belong in terraform configurations of particular
# datasets.

resource "google_service_account" "bigquery_scheduled_queries" {
  account_id   = "bigquery-scheduled"
  display_name = "Bigquery scheduled queries"
  description  = "Service account for scheduled BigQuery queries"
}

resource "google_bigquery_data_transfer_config" "publishing_api_batch" {
  data_source_id = "scheduled_query" # This is a magic word
  display_name   = "Publishing API batch"
  location       = var.region
  schedule       = "every day 00:00"
  params = {
    query = file("bigquery/publishing-api-batch.sql")
  }
  service_account_name = google_service_account.bigquery_scheduled_queries.email
}

resource "google_bigquery_data_transfer_config" "support_api_batch" {
  data_source_id = "scheduled_query" # This is a magic word
  display_name   = "Support API batch"
  location       = var.region
  schedule       = "every day 00:00"
  params = {
    query = file("bigquery/support-api-batch.sql")
  }
  service_account_name = google_service_account.bigquery_scheduled_queries.email
}
