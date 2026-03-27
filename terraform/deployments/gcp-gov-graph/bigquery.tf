resource "google_service_account" "bigquery_page_views" {

  account_id   = "bigquery-page-views"
  display_name = "Service account for page views query"
  description  = "Service account for a scheduled query of page views"
}

resource "google_bigquery_dataset" "test" {
  dataset_id            = "test"
  friendly_name         = "test"
  description           = "Test queries"
  location              = var.region
  max_time_travel_hours = "48"
}

data "google_iam_policy" "bigquery_dataset_test" {
  binding {
    role = "roles/bigquery.dataOwner"
    members = [
      "projectOwners",
    ]
  }
  binding {
    role = "roles/bigquery.dataEditor"
    members = [
      "projectWriters",
    ]
  }
  binding {
    role = "roles/bigquery.dataViewer"
    members = concat(
      [
        "projectReaders",
        google_service_account.bigquery_scheduled_queries.member,
      ],
      var.bigquery_test_data_viewer_members,
    )
  }
}

resource "google_bigquery_dataset_iam_policy" "test" {
  dataset_id  = google_bigquery_dataset.test.dataset_id
  policy_data = data.google_iam_policy.bigquery_dataset_test.policy_data
}

resource "google_bigquery_table" "tables_metadata" {
  dataset_id    = google_bigquery_dataset.test.dataset_id
  table_id      = "tables_metadata"
  friendly_name = "Tables metadata"
  description   = "Table modified date and row count, sorted ascending"
  view {
    use_legacy_sql = false
    query          = file("bigquery/tables-metadata.sql")
  }
}

resource "google_bigquery_table" "tables_metadata_check_results" {
  dataset_id    = google_bigquery_dataset.test.dataset_id
  table_id      = "tables_metadata_check_results"
  friendly_name = "Tables metadata check results"
  description   = "Results of the previous run of the check_tables_metatdata scheduled query"
  schema        = file("schemas/test/tables-metadata-check-results.json")
}
resource "google_bigquery_data_transfer_config" "check_tables_metadata" {
  display_name   = "Check tables metadata"
  data_source_id = "scheduled_query" # This is a magic word
  location       = var.region
  schedule       = "every hour"
  params = {
    destination_table_name_template = "tables_metadata_check_results"
    write_disposition               = "WRITE_TRUNCATE"
    query = templatefile(
      "bigquery/check-tables-metadata.sql",
      {
        alerts_error_message_old_data = var.alerts_error_message_old_data,
        alerts_error_message_no_data  = var.alerts_error_message_no_data,
      }
    )
  }
  service_account_name = google_service_account.bigquery_scheduled_queries.email
}

# Because these queries are scheduled, without any way to manage their
# dependencies on source tables, they musn't use each other as a source.

# Fetch page view statistics from GA4
resource "google_bigquery_data_transfer_config" "page_views" {
  data_source_id = "scheduled_query" # This is a magic word
  display_name   = "Page views"
  location       = var.region
  schedule       = "every day 03:00"
  params = {
    query = file("bigquery/page-views.sql")
  }
  service_account_name = google_service_account.bigquery_page_views.email
}
