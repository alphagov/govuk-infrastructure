# A dataset of tables derived from elsewhere that must not be accessible from
# outside of GOV.UK.

resource "google_bigquery_dataset" "private" {
  dataset_id            = "private"
  friendly_name         = "Private"
  description           = "Data that must not be accessible from outside of GOV.UK"
  location              = var.region
  max_time_travel_hours = "48" # The minimum is 48
}

data "google_iam_policy" "bigquery_dataset_private" {
  binding {
    role = "roles/bigquery.dataEditor"
    members = [
      "projectWriters",
      google_service_account.bigquery_page_views.member,
      google_service_account.bigquery_scheduled_queries.member,
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
      ],
      var.bigquery_private_data_viewer_members,
    )
  }
}

resource "google_bigquery_dataset_iam_policy" "private" {
  dataset_id  = google_bigquery_dataset.private.dataset_id
  policy_data = data.google_iam_policy.bigquery_dataset_private.policy_data
}

resource "google_bigquery_table" "page_views" {
  dataset_id    = google_bigquery_dataset.private.dataset_id
  table_id      = "page_views"
  friendly_name = "Page views"
  description   = "Number of views of GOV.UK pages over 7 days"
  schema        = file("schemas/private/page-views.json")
}

resource "google_bigquery_table" "private_publishing_api_editions_current" {
  dataset_id    = google_bigquery_dataset.private.dataset_id
  table_id      = "publishing_api_editions_current"
  friendly_name = "Publishing API editions (current)"
  description   = "The most recent Publishing API edition per document"
  schema        = file("schemas/private/publishing-api-editions-current.json")
}

resource "google_bigquery_table" "private_publishing_api_editions_new_current" {
  dataset_id    = google_bigquery_dataset.private.dataset_id
  table_id      = "publishing_api_editions_new_current"
  friendly_name = "Publishing API editions (new and current)"
  description   = "Publishing API editions from the latest batch update, that are also current"
  schema        = file("schemas/private/publishing-api-editions-new-current.json")
}
