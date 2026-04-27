resource "google_project_iam_binding" "project_owners" {
  project = google_project.project.project_id
  role    = "roles/owner"

  members = concat(
    [var.terraform_service_account],
    var.project_owners
  )
}

resource "google_project_iam_binding" "project_editors" {
  project = google_project.project.project_id
  role    = "roles/editor"
  members = var.project_editors
}

resource "google_project_iam_binding" "project_viewers" {
  project = google_project.project.project_id
  role    = "roles/viewer"
  members = var.project_viewers
}
