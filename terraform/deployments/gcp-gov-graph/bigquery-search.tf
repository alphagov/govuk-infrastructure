# A dataset of tables for the govsearch app

resource "google_service_account" "bigquery_scheduled_queries_search" {
  account_id   = "bigquery-scheduled-search"
  display_name = "Bigquery scheduled queries for search"
  description  = "Service account for scheduled BigQuery queries for the 'search' dataset"
}

resource "google_bigquery_dataset" "search" {
  dataset_id            = "search"
  friendly_name         = "search"
  description           = "GOV.UK content data"
  location              = var.region
  max_time_travel_hours = "48"
}

data "google_iam_policy" "bigquery_dataset_search" {
  binding {
    role = "roles/bigquery.dataEditor"
    members = [
      "projectWriters",
      google_service_account.bigquery_scheduled_queries_search.member,
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
        google_service_account.govgraphsearch.member,
        google_service_account.bigquery_scheduled_queries.member,
        google_service_account.bigquery_scheduled_queries_search.member,
      ],
      var.bigquery_search_data_viewer_members,
    )
  }
}

resource "google_bigquery_dataset_iam_policy" "search" {
  dataset_id  = google_bigquery_dataset.search.dataset_id
  policy_data = data.google_iam_policy.bigquery_dataset_search.policy_data
}

resource "google_bigquery_table" "search_document_type" {
  dataset_id    = google_bigquery_dataset.search.dataset_id
  table_id      = "document_type"
  friendly_name = "Distinct document types"
  description   = "Distinct document types for dropdown menus in the govsearch app"
  schema        = file("schemas/search/document-type.json")
}

resource "google_bigquery_table" "search_government" {
  dataset_id    = google_bigquery_dataset.search.dataset_id
  table_id      = "government"
  friendly_name = "Distinct governments"
  description   = "Distinct governments for dropdown menus in the govsearch app"
  schema        = file("schemas/search/government.json")
}

resource "google_bigquery_table" "search_locale" {
  dataset_id    = google_bigquery_dataset.search.dataset_id
  table_id      = "locale"
  friendly_name = "Distinct locales"
  description   = "Distinct locales for dropdown menus in the govsearch app"
  schema        = file("schemas/search/locale.json")
}

resource "google_bigquery_table" "search_publishing_app" {
  dataset_id    = google_bigquery_dataset.search.dataset_id
  table_id      = "publishing_app"
  friendly_name = "Distinct Publishing Applications"
  description   = "Distinct publishing apps for dropdown menus in the govsearch app"
  schema        = file("schemas/search/publishing_app.json")
}

resource "google_bigquery_table" "search_organisation" {
  dataset_id    = google_bigquery_dataset.search.dataset_id
  table_id      = "organisation"
  friendly_name = "Distinct organisations"
  description   = "Distinct organisations for dropdown menus in the govsearch app"
  schema        = file("schemas/search/organisation.json")
}

resource "google_bigquery_table" "search_page" {
  dataset_id    = google_bigquery_dataset.search.dataset_id
  table_id      = "page"
  friendly_name = "Page table for the govsearch app"
  description   = "Page table for the govsearch app"
  schema        = file("schemas/search/page.json")
}

resource "google_bigquery_table" "search_person" {
  dataset_id    = google_bigquery_dataset.search.dataset_id
  table_id      = "person"
  friendly_name = "Distinct persons"
  description   = "Distinct persons for dropdown menus in the govsearch app"
  schema        = file("schemas/search/person.json")
}

resource "google_bigquery_table" "search_taxon" {
  dataset_id    = google_bigquery_dataset.search.dataset_id
  table_id      = "taxon"
  friendly_name = "Taxon"
  description   = "Taxon table for the govsearch app"
  schema        = file("schemas/search/taxon.json")
}

resource "google_bigquery_routine" "search_document_type" {
  dataset_id      = google_bigquery_dataset.search.dataset_id
  routine_id      = "document_type"
  routine_type    = "PROCEDURE"
  language        = "SQL"
  definition_body = file("bigquery/search-document-type.sql")
}

resource "google_bigquery_routine" "search_government" {
  dataset_id      = google_bigquery_dataset.search.dataset_id
  routine_id      = "government"
  routine_type    = "PROCEDURE"
  language        = "SQL"
  definition_body = file("bigquery/search-government.sql")
}

resource "google_bigquery_routine" "search_locale" {
  dataset_id      = google_bigquery_dataset.search.dataset_id
  routine_id      = "locale"
  routine_type    = "PROCEDURE"
  language        = "SQL"
  definition_body = file("bigquery/search-locale.sql")
}

resource "google_bigquery_routine" "search_publishing_app" {
  dataset_id      = google_bigquery_dataset.search.dataset_id
  routine_id      = "publishing_app"
  routine_type    = "PROCEDURE"
  language        = "SQL"
  definition_body = file("bigquery/search-publishing-app.sql")
}

resource "google_bigquery_routine" "search_organisation" {
  dataset_id      = google_bigquery_dataset.search.dataset_id
  routine_id      = "organisation"
  routine_type    = "PROCEDURE"
  language        = "SQL"
  definition_body = file("bigquery/search-organisation.sql")
}

resource "google_bigquery_routine" "search_page" {
  dataset_id      = google_bigquery_dataset.search.dataset_id
  routine_id      = "page"
  routine_type    = "PROCEDURE"
  language        = "SQL"
  definition_body = file("bigquery/search-page.sql")
}

resource "google_bigquery_routine" "search_person" {
  dataset_id      = google_bigquery_dataset.search.dataset_id
  routine_id      = "person"
  routine_type    = "PROCEDURE"
  language        = "SQL"
  definition_body = file("bigquery/search-person.sql")
}

resource "google_bigquery_routine" "search_taxon" {
  dataset_id      = google_bigquery_dataset.search.dataset_id
  routine_id      = "taxon"
  routine_type    = "PROCEDURE"
  language        = "SQL"
  definition_body = file("bigquery/search-taxon.sql")
}

resource "google_bigquery_data_transfer_config" "search_batch" {
  data_source_id = "scheduled_query" # This is a magic word
  display_name   = "Search batch"
  location       = var.region
  schedule       = "every day 07:00"
  params = {
    query = file("bigquery/search-batch.sql")
  }
  service_account_name = google_service_account.bigquery_scheduled_queries_search.email
}
