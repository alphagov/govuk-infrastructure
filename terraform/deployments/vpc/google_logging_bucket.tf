data "google_project" "project" {}

resource "google_storage_bucket" "google_logging" {
  name          = "govuk-${var.govuk_environment}-gcp-logging"
  location      = "eu"
  storage_class = "multi_regional"
  project       = data.google_project.project.id

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }

    condition {
      age = 30
    }
  }
}

resource "google_storage_bucket_acl" "google_logging" {
  bucket = google_storage_bucket.google_logging.name

  role_entity = [
    "WRITER:group-cloud-storage-analytics@google.com",
  ]
}

import {
  to = google_storage_bucket.google_logging
  id = "${data.google_project.project.id}/govuk-${var.govuk_environment}-gcp-logging"
}
