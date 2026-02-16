resource "google_project_iam_binding" "project_owners" {
  project = google_project.project.project_id
  role    = "roles/owner"

  members = [
    "group:gcp-gds-bq-processing-owners@digital.cabinet-office.gov.uk",
    "user:ian.ansell@digital.cabinet-office.gov.uk",
    "serviceAccount:terraform-cloud-production@govuk-production.iam.gserviceaccount.com",
  ]
}

resource "google_project_iam_binding" "project_editors" {
  project = google_project.project.project_id
  role    = "roles/editor"
  members = [
    "group:gcp-gds-bq-processing-editors@digital.cabinet-office.gov.uk",
  ]
}
