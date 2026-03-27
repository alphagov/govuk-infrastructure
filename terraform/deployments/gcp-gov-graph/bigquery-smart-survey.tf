# A dataset of data from the Smart Survey API

resource "google_bigquery_dataset" "smart_survey" {
  dataset_id            = "smart_survey"
  friendly_name         = "Smart Survey"
  description           = "Data from the Smart Survey API"
  location              = var.region
  max_time_travel_hours = "48"
}

data "google_iam_policy" "bigquery_dataset_smart_survey" {
  binding {
    role = "roles/bigquery.dataEditor"
    members = [
      "projectWriters",
      google_service_account.workflow_smart_survey.member,
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
      var.bigquery_smart_survey_data_viewer_members,
    )
  }
}

resource "google_bigquery_dataset_iam_policy" "smart_survey" {
  dataset_id  = google_bigquery_dataset.smart_survey.dataset_id
  policy_data = data.google_iam_policy.bigquery_dataset_smart_survey.policy_data
}

resource "google_bigquery_table" "smart_survey_responses" {
  dataset_id               = google_bigquery_dataset.smart_survey.dataset_id
  table_id                 = "responses"
  friendly_name            = "Smart Survey responses"
  description              = "Survey responses from the Smart Survey API, fetched by the smart-survey workflow. One row per survey response."
  schema                   = file("schemas/smart-survey/responses.json")
  require_partition_filter = true
  time_partitioning {
    expiration_ms = 1000 * 60 * 60 * 24 * 365
    field         = "date_started"
    type          = "DAY"
  }
}
