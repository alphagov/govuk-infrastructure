resource "google_bigquery_dataset" "evaluator" {
  dataset_id                 = "search_v2_evaluator"
  location                   = var.gcp_region
  delete_contents_on_destroy = false
}

resource "google_bigquery_table" "evaluator_ratings" {
  dataset_id          = google_bigquery_dataset.evaluator.dataset_id
  table_id            = "evaluator_ratings"
  schema              = file("./files/evaluator-ratings-schema.json")
  deletion_protection = true
}

resource "google_service_account" "evaluator" {
  account_id   = "search-v2-evaluator"
  display_name = "search-v2-evaluator (Rails app)"
  description  = "Service account to provide access to BigQuery for the search-v2-evaluator Rails app"
}

resource "google_service_account_key" "evaluator" {
  service_account_id = google_service_account.evaluator.id
}

resource "google_project_iam_custom_role" "evaluator" {
  role_id     = "evaluator"
  title       = "search-v2-evaluator"
  description = "Enables write access to BigQuery for the search-v2-evaluator Rails app"

  permissions = [
    "bigquery.datasets.get",
    "bigquery.tables.get",
    "bigquery.tables.updateData",
  ]
}

resource "google_bigquery_dataset_iam_binding" "evaluator" {
  dataset_id = google_bigquery_dataset.evaluator.dataset_id
  role       = google_project_iam_custom_role.evaluator.id

  members = [
    "serviceAccount:${google_service_account.evaluator.email}",
  ]
}

resource "aws_secretsmanager_secret" "bigquery_configuration" {
  name                    = "govuk/search-v2-evaluator/google-cloud-bigquery-configuration"
  recovery_window_in_days = 0 # Force delete to allow re-applying immediately after destroying
}

resource "aws_secretsmanager_secret_version" "bigquery_configuration" {
  secret_id = aws_secretsmanager_secret.bigquery_configuration.id
  secret_string = jsonencode({
    "GOOGLE_CLOUD_CREDENTIALS" = base64decode(google_service_account_key.evaluator.private_key)
    "BIGQUERY_PROJECT"         = var.gcp_project_id
    "BIGQUERY_DATASET"         = google_bigquery_dataset.evaluator.dataset_id
    "BIGQUERY_TABLE"           = google_bigquery_table.evaluator_ratings.table_id
  })
}
