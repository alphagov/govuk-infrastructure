resource "google_service_account" "query_executor" {
  project      = var.project_id
  account_id   = "bq-alert-executor"
  display_name = "Service Account to run BQ Alert Queries"
}
