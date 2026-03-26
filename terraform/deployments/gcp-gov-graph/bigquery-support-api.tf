# A dataset of tables from the Support API postgres database

resource "google_bigquery_dataset" "support_api" {
  dataset_id            = "support_api"
  friendly_name         = "Support API"
  description           = "Data from the GOV.UK Support API database"
  location              = var.region
  max_time_travel_hours = "48"
}

data "google_iam_policy" "bigquery_dataset_support_api" {
  binding {
    role = "roles/bigquery.dataEditor"
    members = [
      "projectWriters",
      google_service_account.bigquery_scheduled_queries.member,
      google_service_account.gce_support_api.member,
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
      var.bigquery_support_api_data_viewer_members,
    )
  }
}

resource "google_bigquery_dataset_iam_policy" "support_api" {
  dataset_id  = google_bigquery_dataset.support_api.dataset_id
  policy_data = data.google_iam_policy.bigquery_dataset_support_api.policy_data
}

resource "google_bigquery_table" "support_api_anonymous_contacts" {
  dataset_id    = google_bigquery_dataset.support_api.dataset_id
  table_id      = "anonymous_contacts"
  friendly_name = "Anonymous contacts"
  description   = "Contact tickets (anonymous, long-form), problem reports (collected at the bottom of a page), service feedback (rating out of 5, and what could be improved)"
  schema        = file("schemas/support-api/anonymous-contacts.json")
}

resource "google_bigquery_table" "support_api_archived_service_feedbacks" {
  dataset_id    = google_bigquery_dataset.support_api.dataset_id
  table_id      = "archived_service_feedbacks"
  friendly_name = "Archived service feedback"
  description   = "Service feedback (rating out of 5, and what could be improved)"
  schema        = file("schemas/support-api/archived-service-feedbacks.json")
}
