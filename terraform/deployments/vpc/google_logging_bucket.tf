data "google_project" "project" {}

resource "google_storage_bucket" "google_logging" {
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
  bucket = google_storage_bucket.google_logging.name

  role   = "WRITER"
  entity = "group-cloud-storage-analytics@google.com"
}
