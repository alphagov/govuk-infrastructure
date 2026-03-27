# Bucket for a copy of the current state of the git repository
resource "google_storage_bucket" "repository" {
  name                        = "${var.project_id}-repository" # Must be globally unique
  force_destroy               = false                          # terraform won't delete the bucket unless it is empty
  location                    = var.location
  storage_class               = "STANDARD" # https://cloud.google.com/storage/docs/storage-classes
  uniform_bucket_level_access = true
  versioning {
    enabled = false
  }
}

# Service account for GitHub to use the Cloud Storage
resource "google_service_account" "storage_github" {
  account_id   = "storage-github"
  display_name = "Storage Service Account for GitHub"
  description  = "Service account for using Cloud Storage from GitHub Actions"
}

data "google_iam_policy" "service_account_storage_github" {
  binding {
    role = "roles/iam.workloadIdentityUser"
    members = [
      "principalSet://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/github-pool/attribute.repository/alphagov/govuk-knowledge-graph-gcp"
    ]
  }
}

resource "google_service_account_iam_policy" "storage_github" {
  service_account_id = google_service_account.storage_github.name
  policy_data        = data.google_iam_policy.service_account_storage_github.policy_data
}

resource "google_storage_bucket_iam_policy" "repository" {
  bucket      = google_storage_bucket.repository.name
  policy_data = data.google_iam_policy.bucket_repository.policy_data
}

data "google_iam_policy" "bucket_repository" {
  binding {
    role = "roles/storage.admin"
    members = [
      google_service_account.storage_github.member,
    ]
  }

  binding {
    role = "roles/storage.objectViewer"
    members = [
      google_service_account.gce_publishing_api.member,
      google_service_account.gce_support_api.member,
      google_service_account.gce_publisher.member,
      google_service_account.gce_whitehall.member,
      google_service_account.gce_asset_manager.member,
    ]
  }

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

# Bucket for dataset extracted from databases for upload into BigQuery
resource "google_storage_bucket" "data_processed" {
  name                        = "${var.project_id}-data-processed" # Must be globally unique
  force_destroy               = false                              # terraform won't delete the bucket unless it is empty
  location                    = var.location
  storage_class               = "STANDARD" # https://cloud.google.com/storage/docs/storage-classes
  uniform_bucket_level_access = true
  versioning {
    enabled = false
  }
}

resource "google_storage_bucket_iam_policy" "data_processed" {
  bucket      = google_storage_bucket.data_processed.name
  policy_data = data.google_iam_policy.bucket_data_processed.policy_data
}

data "google_iam_policy" "bucket_data_processed" {
  binding {
    role = "roles/storage.objectAdmin"
    members = [
      google_service_account.gce_publisher.member,
      google_service_account.gce_asset_manager.member,
    ]
  }

  binding {
    role = "roles/storage.objectViewer"
    members = concat([
      ],
      var.storage_data_processed_object_viewer_members,
    )
  }

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

# Bucket for building Cloud Run apps
resource "google_storage_bucket" "cloudbuild" {
  name                        = "${var.project_id}_cloudbuild" # Must be globally unique
  force_destroy               = false                          # terraform won't delete the bucket unless it is empty
  location                    = var.location
  storage_class               = "STANDARD" # https://cloud.google.com/storage/docs/storage-classes
  uniform_bucket_level_access = true
  versioning {
    enabled = false
  }
}

resource "google_storage_bucket_iam_policy" "cloudbuild" {
  bucket      = google_storage_bucket.cloudbuild.name
  policy_data = data.google_iam_policy.bucket_cloudbuild.policy_data
}

data "google_iam_policy" "bucket_cloudbuild" {
  binding {
    role = "roles/storage.objectAdmin"
    members = [
      google_service_account.govgraphsearch_deploy.member,
    ]
  }

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

# Bucket for static copies of libaries, such as for BigQuery user-defined
# functions
resource "google_storage_bucket" "lib" {
  name                        = "${var.project_id}-lib" # Must be globally unique
  force_destroy               = false                   # terraform won't delete the bucket unless it is empty
  location                    = var.location
  storage_class               = "STANDARD" # https://cloud.google.com/storage/docs/storage-classes
  uniform_bucket_level_access = true
  versioning {
    enabled = false
  }
}

resource "google_storage_bucket_iam_policy" "lib" {
  bucket      = google_storage_bucket.lib.name
  policy_data = data.google_iam_policy.bucket_lib.policy_data
}

data "google_iam_policy" "bucket_lib" {
  binding {
    role = "roles/storage.objectViewer"
    # It isn't documented whether anyone needs any role for a BigQuery UDF to
    # be able to fetch a Javascript library from this bucket, but my guess is
    # that any user of the function, or any service account that runs a
    # scheduled query that uses the function, must have
    # roles/storage.objectViewer.
    members = concat([
      google_service_account.bigquery_scheduled_queries.member,
      ],
      var.bigquery_private_data_viewer_members,
    )
  }

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

# Javascript library for detecting phone numbers in plain text and standardising
# them.
resource "google_storage_bucket_object" "libphonenumber" {
  name   = "libphonenumber-max.js"
  source = "lib/libphonenumber-max.js"
  bucket = "${var.project_id}-lib"
}

# Bucket for Smart Survey API data, until BigQuery has loaded it.
resource "google_storage_bucket" "smart_survey" {
  name                        = "${var.project_id}-smart-survey" # Must be globally unique
  force_destroy               = false                            # terraform won't delete the bucket unless it is empty
  location                    = var.location
  storage_class               = "STANDARD" # https://cloud.google.com/storage/docs/storage-classes
  uniform_bucket_level_access = true
  versioning {
    enabled = false
  }
  # A nightly batch is uploaded to an object with a random name. BigQuery will
  # try to load the data out of that particular object. The next night, a new
  # object will be created. Each object will be kept for 7 days, for debugging
  # in case of trouble.
  lifecycle_rule {
    condition {
      age = 7
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_storage_bucket_iam_policy" "smart_survey" {
  bucket      = google_storage_bucket.smart_survey.name
  policy_data = data.google_iam_policy.bucket_smart_survey.policy_data
}

data "google_iam_policy" "bucket_smart_survey" {
  binding {
    role = "roles/storage.admin" # The lowest predefined role that includes storage.buckets.get
    members = [
      google_service_account.http_to_bucket.member,
    ]
  }

  binding {
    role = "roles/storage.objectViewer"
    members = [
      google_service_account.workflow_smart_survey.member,
    ]
  }

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

# Bucket for Zendesk API data, until BigQuery has loaded it.
resource "google_storage_bucket" "zendesk" {
  name                        = "${var.project_id}-zendesk" # Must be globally unique
  force_destroy               = false                       # terraform won't delete the bucket unless it is empty
  location                    = var.location
  storage_class               = "STANDARD" # https://cloud.google.com/storage/docs/storage-classes
  uniform_bucket_level_access = true
  versioning {
    enabled = false
  }
  # A nightly batch is uploaded to an object with a random name. BigQuery will
  # try to load the data out of that particular object. The next night, a new
  # object will be created. Each object will be kept for 7 days, for debugging
  # in case of trouble.
  lifecycle_rule {
    condition {
      age = 7
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_storage_bucket_iam_policy" "zendesk" {
  bucket      = google_storage_bucket.zendesk.name
  policy_data = data.google_iam_policy.bucket_zendesk.policy_data
}

data "google_iam_policy" "bucket_zendesk" {
  binding {
    role = "roles/storage.admin" # The lowest predefined role that includes storage.buckets.get
    members = [
      google_service_account.http_to_bucket.member,
    ]
  }

  binding {
    role = "roles/storage.objectViewer"
    members = [
      google_service_account.workflow_zendesk.member,
    ]
  }

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