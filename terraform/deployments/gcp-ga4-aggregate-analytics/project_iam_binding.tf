locals {
  project_owners_group  = "gcp-ga4-aggregate-analytics-owners@digital.cabinet-office.gov.uk"
  project_editors_group = "gcp-ga4-aggregate-analytics-editors@digital.cabinet-office.gov.uk"
  project_viewers_group = "gcp-ga4-aggregate-analytics-viewers@digital.cabinet-office.gov.uk"

  project_owners_service_accounts  = ["serviceAccount:terraform-cloud-production@govuk-production.iam.gserviceaccount.com"]
  project_editors_service_accounts = ["serviceAccount:firebase-measurement@system.gserviceaccount.com"]
  project_viewers_service_accounts = ["serviceAccount:data-processing@gds-bq-processing.iam.gserviceaccount.com"]
}

# Project Owners
resource "google_project_iam_binding" "project_owners" {
  project = google_project.project.project_id
  role    = "roles/owner"

  members = [
    "group:${local.project_owners_group}"
  ]
}

resource "google_cloud_identity_group_membership" "project_owner_sa_members" {
  for_each = toset(local.project_owners_service_accounts)

  group = "groups/${local.project_owners_group}"

  preferred_member_key {
    id = each.value
  }

  roles {
    name = "MEMBER"
  }
}

# Project Editors
resource "google_project_iam_binding" "project_editors" {
  project = google_project.project.project_id
  role    = "roles/editor"
  members = [
    "group:${local.project_editors_group}"
  ]
}

resource "google_cloud_identity_group_membership" "project_editor_sa_members" {
  for_each = toset(local.project_editors_service_accounts)

  group = "groups/${local.project_editors_group}"

  preferred_member_key {
    id = each.value
  }

  roles {
    name = "MEMBER"
  }
}

# Project Viewers
resource "google_project_iam_binding" "project_viewers" {
  project = google_project.project.project_id
  role    = "roles/viewer"
  members = [
    "group:${local.project_viewers_group}"
  ]
}

resource "google_cloud_identity_group_membership" "project_viewer_sa_members" {
  for_each = toset(local.project_viewers_service_accounts)

  group = "groups/${local.project_viewers_group}"

  preferred_member_key {
    id = each.value
  }

  roles {
    name = "MEMBER"
  }
}
