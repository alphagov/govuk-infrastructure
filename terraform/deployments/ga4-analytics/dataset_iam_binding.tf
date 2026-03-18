locals {
  members = [
    "serviceAccount:dataform-sa@search-api-v2-integration.iam.gserviceaccount.com",
    "serviceAccount:dataform-sa@search-api-v2-staging.iam.gserviceaccount.com",
    "serviceAccount:dataform-sa@search-api-v2-production.iam.gserviceaccount.com",
  ]
}

resource "google_bigquery_dataset_iam_member" "flattened_dataset_reader" {
  for_each   = toset(local.members)
  dataset_id = "${google_project.project.project_id}.flattened_dataset"
  role       = google_project_iam_custom_role.gds_bigquery_read_access.name
  member     = each.key
}

resource "google_bigquery_dataset_iam_member" "events_reader" {
  for_each   = toset(local.members)
  dataset_id = "${google_project.project.project_id}.analytics_330577055"
  role       = google_project_iam_custom_role.gds_bigquery_read_access.name
  member     = each.key
}
