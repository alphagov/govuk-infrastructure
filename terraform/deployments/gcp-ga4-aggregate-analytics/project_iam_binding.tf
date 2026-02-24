resource "google_project_iam_binding" "project_owners" {
  project = google_project.project.project_id
  role    = "roles/owner"

  members = [
    "group:gcp-ga4-aggregate-analytics-owners@digital.cabinet-office.gov.uk",
    "serviceAccount:terraform-cloud-production@govuk-production.iam.gserviceaccount.com"
  ]
}

resource "google_project_iam_binding" "project_editors" {
  project = google_project.project.project_id
  role    = "roles/editor"
  members = [
    "group:gcp-ga4-aggregate-analytics-editors@digital.cabinet-office.gov.uk",
    "serviceAccount:firebase-measurement@system.gserviceaccount.com", // Write access for GA4 exports 
  ]
}

resource "google_project_iam_binding" "project_viewers" {
  project = google_project.project.project_id
  role    = "roles/viewer"
  members = [
    "group:gcp-ga4-aggregate-analytics-viewers@digital.cabinet-office.gov.uk",
    "serviceAccount:data-processing@gds-bq-processing.iam.gserviceaccount.com", // Read access for processing pipeline
  ]
}
