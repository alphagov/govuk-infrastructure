# A dataset of data from the Zenesk API

resource "google_bigquery_dataset" "zendesk" {
  dataset_id            = "zendesk"
  friendly_name         = "Zendesk"
  description           = "Data from the Zendesk API"
  location              = var.region
  max_time_travel_hours = "48"
}

data "google_iam_policy" "bigquery_dataset_zendesk" {
  binding {
    role = "roles/bigquery.dataEditor"
    members = [
      "projectWriters",
      google_service_account.workflow_zendesk.member,
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
    members = concat(
      [
        "projectReaders",
      ],
      var.bigquery_zendesk_data_viewer_members,
    )
  }
}

resource "google_bigquery_dataset_iam_policy" "zendesk" {
  dataset_id  = google_bigquery_dataset.zendesk.dataset_id
  policy_data = data.google_iam_policy.bigquery_dataset_zendesk.policy_data
}

resource "google_bigquery_table" "zendesk_tickets" {
  dataset_id               = google_bigquery_dataset.zendesk.dataset_id
  table_id                 = "tickets"
  friendly_name            = "Zendesk tickets"
  description              = "Zendesk tickets from the Zendesk API, fetched by the zendesk workflow. One row per zendesk ticket."
  schema                   = file("schemas/zendesk/tickets.json")
  require_partition_filter = false
  time_partitioning {
    expiration_ms = 1000 * 60 * 60 * 24 * 365
    field         = "updated_at"
    type          = "DAY"
  }
}

resource "google_bigquery_table" "zendesk_tickets_flattened" {
  dataset_id    = google_bigquery_dataset.private.dataset_id
  table_id      = "zendesk_tickets_flattened"
  friendly_name = "Zendesk tickets (flattened)"
  description   = "Zendesk tickets from the Zendesk API, fetched by the zendesk workflow. One row per zendesk ticket."
  schema        = file("schemas/private/zendesk-tickets-flattened.json")

  # We can't use a materialized view, because they don't allow a schema, so we
  # couldn't terraform any field descriptions.
  view {
    query          = file("bigquery/zendesk-tickets-flattened.sql")
    use_legacy_sql = false
  }
}
