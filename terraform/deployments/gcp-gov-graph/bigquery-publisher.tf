# A dataset of tables from the Publisher app mongo database

resource "google_bigquery_dataset" "publisher" {
  dataset_id            = "publisher"
  friendly_name         = "publisher"
  description           = "Data from the GOV.UK Publisher app database"
  location              = var.region
  max_time_travel_hours = "48"
}

data "google_iam_policy" "bigquery_dataset_publisher" {
  binding {
    role = "roles/bigquery.dataEditor"
    members = [
      "projectWriters",
      google_service_account.gce_publisher.member,
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
        google_service_account.bigquery_scheduled_queries_search.member,
        google_service_account.bigquery_scheduled_queries.member,
      ],
      var.bigquery_publisher_data_viewer_members,
    )
  }
}

resource "google_bigquery_dataset_iam_policy" "publisher" {
  dataset_id  = google_bigquery_dataset.publisher.dataset_id
  policy_data = data.google_iam_policy.bigquery_dataset_publisher.policy_data
}

resource "google_bigquery_table" "publisher_editions" {
  dataset_id    = google_bigquery_dataset.publisher.dataset_id
  table_id      = "editions"
  friendly_name = "Editions"
  description   = "Editions table derived from the GOV.UK Publisher app Mongo database"
  schema        = file("schemas/publisher/editions.json")
}

resource "google_bigquery_table" "publisher_actions" {
  dataset_id    = google_bigquery_dataset.publisher.dataset_id
  table_id      = "actions"
  friendly_name = "Actions"
  description   = "Actions table derived from the GOV.UK Publisher app Mongo database. Many actions occur per edition, leading to publication."
  schema        = file("schemas/publisher/actions.json")
}
