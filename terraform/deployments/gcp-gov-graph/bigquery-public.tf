# A dataset of tables derived from elsewhere that may be accessible from outside
# of GOV.UK.

resource "google_bigquery_dataset" "public" {
  dataset_id            = "public"
  friendly_name         = "Public"
  description           = "Data that must not be accessible from outside of GOV.UK"
  location              = var.region
  max_time_travel_hours = "48" # The minimum is 48
}

data "google_iam_policy" "bigquery_dataset_public" {
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
    members = concat(
      [
        "projectReaders",
        google_service_account.bigquery_page_views.member,
        google_service_account.bigquery_scheduled_queries_search.member,
      ],
      var.bigquery_public_data_viewer_members,
    )
  }
}

resource "google_bigquery_dataset_iam_policy" "public" {
  dataset_id  = google_bigquery_dataset.public.dataset_id
  policy_data = data.google_iam_policy.bigquery_dataset_public.policy_data
}

resource "google_bigquery_table" "public_attachments" {
  dataset_id    = google_bigquery_dataset.public.dataset_id
  table_id      = "assets"
  friendly_name = "Assets of attachments of editions"
  description   = "Asset metadata extracted from the `details` column of editions. An edition can have many attachments, which can each have many assets (usually two: a document and its thumbnail)."
  schema        = file("schemas/public/assets.json")
}

resource "google_bigquery_table" "base_path_lookup" {
  dataset_id    = google_bigquery_dataset.public.dataset_id
  table_id      = "base_path_lookup"
  friendly_name = "Base path lookup"
  description   = "Maps base paths that the GOV.UK website serves, to base paths in the Publishing API. For example, /towing-with-car/weight-and-width-limits is a base path that the website serves with content from an edition in the Publishing API that has the (shorter) base path /towing-with-car."
  schema        = file("schemas/public/base-path-lookup.json")
}

resource "google_bigquery_table" "public_content_new" {
  dataset_id    = google_bigquery_dataset.public.dataset_id
  table_id      = "content_new"
  friendly_name = "Content (new records)"
  description   = "Content extracted from HTML of editions in the latest batch"
  schema        = file("schemas/public/content-new.json")
}

resource "google_bigquery_table" "public_content" {
  dataset_id    = google_bigquery_dataset.public.dataset_id
  table_id      = "content"
  friendly_name = "Content"
  description   = "Content extracted from HTML of editions"
  schema        = file("schemas/public/content.json")
}

resource "google_bigquery_table" "public_contact_phone_numbers" {
  dataset_id    = google_bigquery_dataset.public.dataset_id
  table_id      = "contact_phone_numbers"
  friendly_name = "Contact phone numbers"
  description   = "One row per document with schema 'contact', with an array of phone numbers, standardised to their E.164 format"
  schema        = file("schemas/public/contact-phone-numbers.json")
}

resource "google_bigquery_table" "public_department_analytics_profile" {
  dataset_id    = google_bigquery_dataset.public.dataset_id
  table_id      = "department_analytics_profile"
  friendly_name = "Department analytics profile (org ID)"
  description   = "The Google Analytics ID that some organisations have"
  schema        = file("schemas/public/department-analytics-profile.json")
}

resource "google_bigquery_table" "public_phone_numbers" {
  dataset_id    = google_bigquery_dataset.public.dataset_id
  table_id      = "phone_numbers"
  friendly_name = "Phone numbers"
  description   = "One row per document (per part, for multipart documents), with an array of phone numbers detected in the document's body or metadata, standardised to the E.164 format"
  schema        = file("schemas/public/phone-numbers.json")
}

resource "google_bigquery_table" "public_publishing_api_editions_new_current" {
  dataset_id    = google_bigquery_dataset.public.dataset_id
  table_id      = "publishing_api_editions_new_current"
  friendly_name = "Publishing API editions (new and current)"
  description   = "Publishing API editions from the latest batch update, that are also current and public"
  schema        = file("schemas/public/publishing-api-editions-new-current.json")
}

resource "google_bigquery_table" "public_publishing_api_editions_current" {
  dataset_id    = google_bigquery_dataset.public.dataset_id
  table_id      = "publishing_api_editions_current"
  friendly_name = "Publishing API editions (current)"
  description   = "The most-recent edition of each document of each content item"
  schema        = file("schemas/public/publishing-api-editions-current.json")
}

resource "google_bigquery_table" "public_publishing_api_links_current" {
  dataset_id    = google_bigquery_dataset.public.dataset_id
  table_id      = "publishing_api_links_current"
  friendly_name = "Publishing API links (current)"
  description   = "Links between current editions of each content item"
  schema        = file("schemas/public/publishing-api-links-current.json")
}

resource "google_bigquery_table" "public_publishing_api_unpublishings_current" {
  dataset_id    = google_bigquery_dataset.public.dataset_id
  table_id      = "publishing_api_unpublishings_current"
  friendly_name = "Publishing API unpublishings (current)"
  description   = "The most-recent unpublishing of each unpublished document of each content item"
  schema        = file("schemas/public/publishing-api-unpublishings-current.json")
}

resource "google_bigquery_table" "public_start_button_links" {
  dataset_id    = google_bigquery_dataset.public.dataset_id
  table_id      = "start_button_links"
  friendly_name = "Start button links"
  description   = "One row per edition, with the text displayed on its start button, and the URL that it links to"
  schema        = file("schemas/public/start-button-links.json")
}

resource "google_bigquery_table" "public_taxonomy" {
  dataset_id    = google_bigquery_dataset.public.dataset_id
  table_id      = "taxonomy"
  friendly_name = "Taxonomy"
  description   = "One row per taxon, each with an array of its ancestors, which include itself"
  schema        = file("schemas/public/taxonomy.json")
}

resource "google_bigquery_table" "public_organisations" {
  dataset_id    = google_bigquery_dataset.public.dataset_id
  table_id      = "organisations"
  friendly_name = "organisations"
  description   = "One row per organisation, each with arrays of parents, children, predecessors and successors."
  schema        = file("schemas/public/organisations.json")
}
