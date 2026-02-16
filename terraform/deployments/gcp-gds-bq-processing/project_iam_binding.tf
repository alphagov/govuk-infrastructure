resource "google_project_iam_binding" "project_owners" {
  project = google_project.project.project_id
  role    = "roles/owner"

  members = [
    "group:gcp-gds-bq-processing-owners@digital.cabinet-office.gov.uk",
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

# Creating this role with no members allows terraform to enforce that nobody should have project-wide roles/viewer access.
resource "google_project_iam_binding" "project_viewers" {
  project = google_project.project.project_id
  role    = "roles/viewer"
  members = []
}

resource "google_project_iam_binding" "code_viewers" {
  project = google_project.project.project_id
  role    = google_project_iam_custom_role.code_viewer.name
  members = [
    "group:gcp-gds-bq-processing-code-viewers@digital.cabinet-office.gov.uk",
  ]
}
