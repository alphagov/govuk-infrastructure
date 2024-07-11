data "google_project" "project" {}
/*
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
}*/

locals {
  google_project = var.govuk_environment == "staging" ? "govuk-staging-160211" : "govuk-${var.govuk_environment}"
  sae = "terraform-cloud-${var.govuk_environment}@${local.google_project}.iam.gserviceaccount.com"
}

resource "google_project_iam_binding" "tfc" {
  project = local.google_project
  role    = "roles/owner"
  members = ["user:sam.simpson@digital.cabinet-office.gov.uk",
  "group:govuk-gcp-access@digital.cabinet-office.gov.uk",
  "serviceAccount:${local.sae}"]
}
