resource "google_project_iam_binding" "project_owners" {
  project = google_project.project.project_id
  role    = "roles/owner"

  members = [
    "group:gcp-ga4-analytics-352613-owners@digital.cabinet-office.gov.uk",
    "serviceAccount:terraform-cloud-production@govuk-production.iam.gserviceaccount.com"
  ]
}

resource "google_project_iam_binding" "project_editors" {
  project = google_project.project.project_id
  role    = "roles/editor"
  members = [
    "group:gcp-ga4-analytics-352613-editors@digital.cabinet-office.gov.uk",
  ]
}

resource "google_project_iam_binding" "project_viewers" {
  project = google_project.project.project_id
  role    = "roles/viewer"
  members = [
    # purposfully empty
  ]
}

resource "google_project_iam_binding" "gds_bigquery_editor" {
  project = google_project.project.project_id
  role    = google_project_iam_custom_role.gds_bigquery_editor.name
  members = [
    "serviceAccount:firebase-measurement@system.gserviceaccount.com",
    "serviceAccount:search-console-data-export@system.gserviceaccount.com",
    "serviceAccount:service-177535650450@gcp-sa-dataform.iam.gserviceaccount.com",
    "serviceAccount:service-659461823838@gcp-sa-dataform.iam.gserviceaccount.com",
    "serviceAccount:177535650450-compute@developer.gserviceaccount.com",
    google_service_account.ga_database.member,
    google_service_account.ga4_user_admin.member,
  ]
  depends_on = [
    google_service_account.ga_database,
    google_service_account.ga4_user_admin,
  ]
}

resource "google_project_iam_binding" "gds_bigquery_user" {
  project = google_project.project.project_id
  role    = google_project_iam_custom_role.gds_bigquery_user.name
  members = [
    "domain:digital.cabinet-office.gov.uk",
    "user:arran.gosal@merkle.com",
  ]
}

resource "google_project_iam_binding" "gds_bigquery_read_access" {
  project = google_project.project.project_id
  role    = google_project_iam_custom_role.gds_bigquery_read_access.name
  members = [
    "serviceAccount:analytics-events-pipeline@search-api-v2-integration.iam.gserviceaccount.com",
    "serviceAccount:analytics-events-pipeline@search-api-v2-production.iam.gserviceaccount.com",
    "serviceAccount:analytics-events-pipeline@search-api-v2-staging.iam.gserviceaccount.com",
    "serviceAccount:govuk-content-data-ga4@govuk-content-data.iam.gserviceaccount.com",
    "serviceAccount:govuk-looker-poc@govuk-looker-poc.iam.gserviceaccount.com",
  ]
}

resource "google_project_iam_binding" "gds_log_alert_writer" {
  project = google_project.project.project_id
  role    = google_project_iam_custom_role.gds_logging_alerts_writer.name
  members = [
    "group:govuk-performance-analysts@digital.cabinet-office.gov.uk"
  ]
}
