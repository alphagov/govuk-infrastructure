# A dataset of tables of GOV.UK content and related raw statistics

resource "google_bigquery_dataset" "content" {
  dataset_id            = "content"
  friendly_name         = "content"
  description           = "Deprecated: GOV.UK content data. Please use the 'private' and 'public' datsets instead. Tables in this dataset are now derived from those."
  location              = var.region
  max_time_travel_hours = "48"
}

data "google_iam_policy" "bigquery_dataset_content" {
  binding {
    role = "roles/bigquery.dataEditor"
    members = [
      "projectWriters",
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
    members = concat([
      "projectReaders",
      ],
      var.bigquery_content_data_viewer_members,
    )
  }
}

resource "google_bigquery_dataset_iam_policy" "content" {
  dataset_id  = google_bigquery_dataset.content.dataset_id
  policy_data = data.google_iam_policy.bigquery_dataset_content.policy_data
}

resource "google_bigquery_table" "content" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "content"
  friendly_name = "Content"
  description   = "Body content of static pages on the www.gov.uk domain, including separate rows for parts of 'guide' and 'travel_advice' documents."
  schema        = file("schemas/content/content.json")
}

resource "google_bigquery_table" "title" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "title"
  friendly_name = "Title"
  description   = "Titles of static content on the www.gov.uk domain, not including parts of 'guide' and 'travel_advice' pages, which are in the 'parts' table."
  schema        = file("schemas/content/title.json")
}

resource "google_bigquery_table" "description" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "description"
  friendly_name = "Description"
  description   = "Descriptions of static content on the www.gov.uk domain."
  schema        = file("schemas/content/description.json")
}

resource "google_bigquery_table" "expanded_links" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "expanded_links"
  friendly_name = "Expanded links"
  description   = "Typed relationships between two URLs, from one to the other"
  schema        = file("schemas/content/expanded-links.json")
}

resource "google_bigquery_table" "lines" {
  dataset_id    = google_bigquery_dataset.content.dataset_id
  table_id      = "lines"
  friendly_name = "Lines"
  description   = "Individual lines of content of pages"
  schema        = file("schemas/content/lines.json")
}

# Refresh legacy tables from data in the 'public' dataset.

resource "google_bigquery_routine" "content_content" {
  dataset_id      = google_bigquery_dataset.content.dataset_id
  routine_id      = "content"
  routine_type    = "PROCEDURE"
  language        = "SQL"
  definition_body = file("bigquery/content-content.sql")
}

resource "google_bigquery_routine" "content_description" {
  dataset_id      = google_bigquery_dataset.content.dataset_id
  routine_id      = "description"
  routine_type    = "PROCEDURE"
  language        = "SQL"
  definition_body = file("bigquery/content-description.sql")
}

resource "google_bigquery_routine" "content_expanded_links" {
  dataset_id      = google_bigquery_dataset.content.dataset_id
  routine_id      = "expanded_links"
  routine_type    = "PROCEDURE"
  language        = "SQL"
  definition_body = file("bigquery/content-expanded-links.sql")
}

resource "google_bigquery_routine" "content_lines" {
  dataset_id      = google_bigquery_dataset.content.dataset_id
  routine_id      = "lines"
  routine_type    = "PROCEDURE"
  language        = "SQL"
  definition_body = file("bigquery/content-lines.sql")
}

resource "google_bigquery_routine" "content_title" {
  dataset_id      = google_bigquery_dataset.content.dataset_id
  routine_id      = "title"
  routine_type    = "PROCEDURE"
  language        = "SQL"
  definition_body = file("bigquery/content-title.sql")
}

resource "google_bigquery_data_transfer_config" "content_batch" {
  data_source_id = "scheduled_query" # This is a magic word
  display_name   = "content batch"
  location       = var.region
  schedule       = "every day 07:00"
  params = {
    query = file("bigquery/content-batch.sql")
  }
  service_account_name = google_service_account.bigquery_scheduled_queries.email
}
