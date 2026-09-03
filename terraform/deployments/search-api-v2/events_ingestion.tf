# Event Transfer is now orchestrated via Dataform - Cloud scheduler and Cloud Function orchestration has been removed
# BQ dataset and table creation hasn't been migrated to Dataform so remains here
# Event ingest is orchestrated in Ruby stack not in GCP

# top level dataset to store events for ingestion into Discovery Engine (previously marketed as "Vertex AI Search")
resource "google_bigquery_dataset" "dataset" {
  dataset_id                 = "analytics_events_vertex"
  location                   = var.gcp_region
  delete_contents_on_destroy = true
}

# ga4 'view_item_list' events get transformed and inserted into this time-partitioned search-event table defined with a
# Discovery Engine 'search' schema: https://docs.cloud.google.com/generative-ai-app-builder/docs/user-events#bigquery_4
resource "google_bigquery_table" "search_event" {
  dataset_id          = google_bigquery_dataset.dataset.dataset_id
  table_id            = "search-event"
  schema              = file("./files/search-event-schema.json")
  deletion_protection = false
  time_partitioning {
    type = "DAY"
  }

}

# ga4 'page_view' events get transformed and inserted into this time-partitioned view-item-event table defined with a
# Discovery Engine 'view item' schema: https://docs.cloud.google.com/generative-ai-app-builder/docs/user-events#bigquery
resource "google_bigquery_table" "view_item_event" {
  dataset_id          = google_bigquery_dataset.dataset.dataset_id
  table_id            = "view-item-event"
  schema              = file("./files/view-item-event-schema.json")
  deletion_protection = false
  time_partitioning {
    type = "DAY"
  }
}

# ga4 'select_item' events get transformed and inserted into this time-partitioned view-item-external-link-event table
# defined with a Discovery Engine 'view item' schema:
# https://docs.cloud.google.com/generative-ai-app-builder/docs/user-events#bigquery
resource "google_bigquery_table" "view_item_external_link_event" {
  dataset_id          = google_bigquery_dataset.dataset.dataset_id
  table_id            = "view-item-external-link-event"
  schema              = file("./files/view-item-event-schema.json")
  deletion_protection = false
  time_partitioning {
    type = "DAY"
  }
}

# ga4 'view_item_list' intraday events get transformed and inserted into this time-partitioned search-intraday-event
# table defined with a Discovery Engine 'search' schema:
# https://docs.cloud.google.com/generative-ai-app-builder/docs/user-events#bigquery_4
resource "google_bigquery_table" "search_intraday_event" {
  dataset_id          = google_bigquery_dataset.dataset.dataset_id
  table_id            = "search-intraday-event"
  schema              = file("./files/search-event-schema.json")
  deletion_protection = false
  time_partitioning {
    type = "DAY"
  }

}

# ga4 'page_view' intraday events get transformed and inserted into this time-partitioned view-item-intraday-event table
# defined with a Discovery Engine 'view item' schema:
# https://docs.cloud.google.com/generative-ai-app-builder/docs/user-events#bigquery
resource "google_bigquery_table" "view_item_intraday_event" {
  dataset_id          = google_bigquery_dataset.dataset.dataset_id
  table_id            = "view-item-intraday-event"
  schema              = file("./files/view-item-event-schema.json")
  deletion_protection = false
  time_partitioning {
    type = "DAY"
  }
}

# ga4 'select_item' intraday events get transformed and inserted into this time-partitioned
# view-item-external-link-intraday-event table defined with a Discovery Engine 'view item' schema:
# https://docs.cloud.google.com/generative-ai-app-builder/docs/user-events#bigquery
resource "google_bigquery_table" "view_item_external_link_intraday_event" {
  dataset_id          = google_bigquery_dataset.dataset.dataset_id
  table_id            = "view-item-external-link-intraday-event"
  schema              = file("./files/view-item-event-schema.json")
  deletion_protection = false
  time_partitioning {
    type = "DAY"
  }
}
