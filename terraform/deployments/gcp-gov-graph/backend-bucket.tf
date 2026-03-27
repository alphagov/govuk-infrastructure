# Add a bucket to store terraform state.  Backend configuration is in
# init/backend.tf, which should be moved into the same directory as this file
# once `terraform apply` has created this bucket.  Unfortunately there is no
# other way to temporarily use a local backend.
resource "google_storage_bucket" "backend" {
  name                        = "${var.project_id}-tfstate" # Must be globally unique
  force_destroy               = false                       # terraform won't delete the bucket unless it is empty
  location                    = var.location
  storage_class               = "STANDARD" # https://cloud.google.com/storage/docs/storage-classes
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

resource "google_storage_bucket_iam_policy" "backend" {
  bucket      = google_storage_bucket.backend.name
  policy_data = data.google_iam_policy.bucket_backend.policy_data
}

data "google_iam_policy" "bucket_backend" {
  binding {
    role = "roles/storage.legacyBucketOwner"
    members = [
      "projectEditor:${var.project_id}",
      "projectOwner:${var.project_id}",
    ]
  }

  binding {
    role = "roles/storage.legacyBucketReader"
    members = [
      "projectViewer:${var.project_id}",
    ]
  }

  binding {
    role = "roles/storage.legacyObjectOwner"
    members = [
      "projectEditor:${var.project_id}",
      "projectOwner:${var.project_id}",
    ]
  }

  binding {
    role = "roles/storage.legacyObjectReader"
    members = [
      "projectViewer:${var.project_id}",
    ]
  }
}
