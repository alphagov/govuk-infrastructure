resource "google_project_iam_binding" "project-owners" {
  project = google_project.project.project_id
  role    = "roles/owner"

  members = [
    "group:gcp-ga4-analytics-352613-owners@digital.cabinet-office.gov.uk",
  ]
}

resource "google_project_iam_binding" "project-editors" {
  project = google_project.project.project_id
  role    = "roles/editor"
  members = [
    "group:gcp-ga4-analytics-352613-editors@digital.cabinet-office.gov.uk",
  ]
}

resource "google_project_iam_binding" "project-viewers" {
  project = google_project.project.project_id
  role    = "roles/viewer"
  members = [
    # purposfully empty
  ]
}

resource "google_project_iam_binding" "project-gds_bigquery_editor" {
  project = google_project.project.project_id
  role    = "projects/ga4-analytics-352613/roles/GDS_BQ_editor"
  members = [
    "serviceAccount:firebase-measurement@system.gserviceaccount.com",
    "serviceAccount:search-console-data-export@system.gserviceaccount.com",
    "serviceAccount:service-177535650450@gcp-sa-dataform.iam.gserviceaccount.com",
    "serviceAccount:ga4-user-admin@ga4-analytics-352613.iam.gserviceaccount.com",
    "serviceAccount:ga-database@ga4-analytics-352613.iam.gserviceaccount.com",
  ]
  depends_on = [
    google_service_account.sa--ga-database,
    google_service_account.sa--ga4-user-admin,
  ]
}

resource "google_project_iam_binding" "project-gds_bigquery_user" {
  project = google_project.project.project_id
  role    = "projects/ga4-analytics-352613/roles/gds.bigquery.user"
  members = [
    "domain:digital.cabinet-office.gov.uk",
    "user:arran.gosal@merkle.com",
    "serviceAccount:177535650450-compute@developer.gserviceaccount.com",
  ]
}

resource "google_project_iam_binding" "project-GDS_BQ_read_access" {
  project = google_project.project.project_id
  role    = "projects/ga4-analytics-352613/roles/GDS_BQ_read_access"
  members = [
    "serviceAccount:analytics-events-pipeline@search-api-v2-integration.iam.gserviceaccount.com",
    "serviceAccount:analytics-events-pipeline@search-api-v2-production.iam.gserviceaccount.com",
    "serviceAccount:analytics-events-pipeline@search-api-v2-staging.iam.gserviceaccount.com",
    "serviceAccount:chatbot-cloudrun@data-insights-experimentation.iam.gserviceaccount.com",
    "serviceAccount:chatbot-cloudrun-dev@data-insights-experimentation.iam.gserviceaccount.com",
    "serviceAccount:data-insights-experimentation@data-insights-experimentation.iam.gserviceaccount.com",
    "serviceAccount:govuk-content-data-ga4@govuk-content-data.iam.gserviceaccount.com",
    "serviceAccount:govuk-looker-poc@govuk-looker-poc.iam.gserviceaccount.com",
  ]
}