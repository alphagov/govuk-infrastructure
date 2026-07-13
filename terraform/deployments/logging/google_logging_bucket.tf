data "google_project" "project" {
  count = var.create_google_logging ? 1 : 0
}

resource "google_storage_bucket" "google_logging" {
  count = var.create_google_logging ? 1 : 0

  name          = "govuk-${var.govuk_environment}-gcp-logging"
  location      = "eu"
  storage_class = "MULTI_REGIONAL"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }

    condition {
      age        = 30
      with_state = "ARCHIVED"
    }
  }
}

resource "google_storage_bucket_access_control" "google_logging" {
  bucket = google_storage_bucket.google_logging[0].name

  role   = "WRITER"
  entity = "group-cloud-storage-analytics@google.com"
}
