locals {
  # 1000ms * 60s * 60m * 24h * 90 days
  ninety_days_in_ms = 1000 * 60 * 60 * 24 * 90
}

resource "google_bigquery_dataset" "raw_events_dataset" {
  dataset_id                      = "analytics_523297687"
  friendly_name                   = "Analytics Property ID 523297687"
  description                     = "This dataset contains events tables from GA4 property ID 523297687"
  location                        = "europe-west2"
  default_partition_expiration_ms = local.ninety_days_in_ms
  default_table_expiration_ms     = local.ninety_days_in_ms

  depends_on = [google_project_service.project_services]
}
