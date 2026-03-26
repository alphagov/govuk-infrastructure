# A dataset of tables from the Asset Manager mongo database

resource "google_bigquery_dataset" "asset_manager" {
  dataset_id            = "asset_manager"
  friendly_name         = "Asset Manager"
  description           = "Data from the GOV.UK Asset Manager database"
  location              = var.region
  max_time_travel_hours = "48"
}

data "google_iam_policy" "bigquery_dataset_asset_manager" {
  binding {
    role = "roles/bigquery.dataEditor"
    members = [
      "projectWriters",
      google_service_account.bigquery_scheduled_queries.member,
      google_service_account.gce_asset_manager.member,
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
      var.bigquery_asset_manager_data_viewer_members,
    )
  }
}

resource "google_bigquery_dataset_iam_policy" "asset_manager" {
  dataset_id  = google_bigquery_dataset.asset_manager.dataset_id
  policy_data = data.google_iam_policy.bigquery_dataset_asset_manager.policy_data
}

resource "google_bigquery_table" "asset_manager_assets" {
  dataset_id    = google_bigquery_dataset.asset_manager.dataset_id
  table_id      = "assets"
  friendly_name = "Assets"
  description   = "Assets table from the GOV.UK Asset Manager mongo database"
  schema        = file("schemas/asset-manager/assets.json")
  clustering    = ["content_type"]
  time_partitioning {
    type  = "MONTH"
    field = "updated_at"
  }
}
