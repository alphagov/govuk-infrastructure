# A dataset of tables from the Publishing API postgres database

resource "google_bigquery_dataset" "publishing_api" {
  dataset_id            = "publishing_api"
  friendly_name         = "Publishing API"
  description           = "Data from the GOV.UK Publishing API database"
  location              = var.region
  max_time_travel_hours = "48"
}

data "google_iam_policy" "bigquery_dataset_publishing_api" {
  binding {
    role = "roles/bigquery.dataEditor"
    members = [
      "projectWriters",
      google_service_account.bigquery_scheduled_queries.member,
      google_service_account.gce_publishing_api.member,
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
      var.bigquery_publishing_api_data_viewer_members,
    )
  }
}

resource "google_bigquery_dataset_iam_policy" "publishing_api" {
  dataset_id  = google_bigquery_dataset.publishing_api.dataset_id
  policy_data = data.google_iam_policy.bigquery_dataset_publishing_api.policy_data
}

resource "google_bigquery_table" "publishing_api_actions" {
  dataset_id    = google_bigquery_dataset.publishing_api.dataset_id
  table_id      = "actions"
  friendly_name = "Actions"
  description   = "Actions table from the GOV.UK Publishing API PostgreSQL database"
  schema        = file("schemas/publishing-api/actions.json")
}

resource "google_bigquery_table" "publishing_api_change_notes" {
  dataset_id    = google_bigquery_dataset.publishing_api.dataset_id
  table_id      = "change_notes"
  friendly_name = "Change notes"
  description   = "Change notes table from the GOV.UK Publishing API PostgreSQL database"
  schema        = file("schemas/publishing-api/change-notes.json")
  range_partitioning {
    field = "edition_id"
    range {
      start    = 0
      end      = 100000000 # 10 times the maximum edition_id at the end of 2023, which was about 10000000
      interval = 25000     # 4k partitions, which is the limit
    }
  }
}

resource "google_bigquery_table" "publishing_api_documents" {
  dataset_id    = google_bigquery_dataset.publishing_api.dataset_id
  table_id      = "documents"
  friendly_name = "Documents"
  description   = "Documents table from the GOV.UK Publishing API PostgreSQL database"
  schema        = file("schemas/publishing-api/documents.json")
  range_partitioning {
    field = "id"
    range {
      start    = 0
      end      = 15000000 # 10 times the maximum at the end of 2023, which was about 1500000
      interval = 3750     # 4k partitions, which is the limit
    }
  }
}

resource "google_bigquery_table" "publishing_editions" {
  dataset_id    = google_bigquery_dataset.publishing_api.dataset_id
  table_id      = "editions"
  friendly_name = "Editions"
  description   = "Editions table from the GOV.UK Publishing API PostgreSQL database"
  schema        = file("schemas/publishing-api/editions.json")
  time_partitioning {
    type  = "MONTH" # DAY would exceed of 4k partitions (max allowable)
    field = "updated_at"
  }
}

resource "google_bigquery_table" "publishing_api_events" {
  dataset_id    = google_bigquery_dataset.publishing_api.dataset_id
  table_id      = "events"
  friendly_name = "Events"
  description   = "Events table from the GOV.UK Publishing API PostgreSQL database"
  schema        = file("schemas/publishing-api/events.json")
}

resource "google_bigquery_table" "publishing_api_expanded_links" {
  dataset_id    = google_bigquery_dataset.publishing_api.dataset_id
  table_id      = "expanded_links"
  friendly_name = "Expanded links"
  description   = "Expanded links table from the GOV.UK Publishing API PostgreSQL database"
  schema        = file("schemas/publishing-api/expanded-links.json")
}

resource "google_bigquery_table" "publishing_api_link_changes" {
  dataset_id    = google_bigquery_dataset.publishing_api.dataset_id
  table_id      = "link_changes"
  friendly_name = "Link changes"
  description   = "Link changes table from the GOV.UK Publishing API PostgreSQL database"
  schema        = file("schemas/publishing-api/link-changes.json")
}

resource "google_bigquery_table" "publishing_api_link_sets" {
  dataset_id    = google_bigquery_dataset.publishing_api.dataset_id
  table_id      = "link_sets"
  friendly_name = "Link sets"
  description   = "Link sets table from the GOV.UK Publishing API PostgreSQL database"
  schema        = file("schemas/publishing-api/link-sets.json")
  # No partition, because joins are by content_id, a string, which isn't supported
}

resource "google_bigquery_table" "publishing_api_links" {
  dataset_id    = google_bigquery_dataset.publishing_api.dataset_id
  table_id      = "links"
  friendly_name = "Links"
  description   = "Links table from the GOV.UK Publishing API PostgreSQL database"
  schema        = file("schemas/publishing-api/links.json")
}

resource "google_bigquery_table" "publishing_api_path_reservations" {
  dataset_id    = google_bigquery_dataset.publishing_api.dataset_id
  table_id      = "path_reservations"
  friendly_name = "Path reservations"
  description   = "Path reservations table from the GOV.UK Publishing API PostgreSQL database"
  schema        = file("schemas/publishing-api/path-reservations.json")
}

resource "google_bigquery_table" "publishing_api_unpublishings" {
  dataset_id    = google_bigquery_dataset.publishing_api.dataset_id
  table_id      = "unpublishings"
  friendly_name = "Unpublishings"
  description   = "Unpublishings table from the GOV.UK Publishing API PostgreSQL database"
  schema        = file("schemas/publishing-api/unpublishings.json")
  range_partitioning {
    field = "edition_id"
    range {
      start    = 0
      end      = 100000000 # 10 times the maximum edition_id at the end of 2023, which was about 10000000
      interval = 25000     # 4k partitions, which is the limit
    }
  }
}
