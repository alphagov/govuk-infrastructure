# A service to use as a remote function in BigQuery
# Then create a place to put the app images
resource "google_cloud_run_v2_service" "dlp_deidentify_service" {
  name     = "dlp-deidentify-service"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.dlp_deidentify_service.email
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker.repository_id}/dlp-deidentify-service:latest"
      env {
        name  = "PROJECT_ID"
        value = var.project_id
      }
      resources {
        limits = {
          cpu    = "1000m"
          memory = "2048Mi"
        }
      }
    }
  }
}

resource "google_service_account" "dlp_deidentify_service" {
  account_id   = "dlp-deidentify-service"
  display_name = "Service account for Cloud Run service dlp-deidentify-service"
}

data "google_iam_policy" "cloud_run_dlp_deidentify_service" {
  binding {
    role    = "roles/run.invoker"
    members = ["serviceAccount:bqcx-578894245899-q9ri@gcp-sa-bigquery-condel.iam.gserviceaccount.com"]
  }
}

resource "google_cloud_run_v2_service_iam_policy" "dlp_deidentify_service" {
  location    = var.region
  name        = google_cloud_run_v2_service.dlp_deidentify_service.name
  policy_data = data.google_iam_policy.cloud_run_dlp_deidentify_service.policy_data
}

data "google_iam_policy" "service_account_dlp_deidentify_service" {
  binding {
    role = "roles/iam.serviceAccountUser"

    members = [
      google_service_account.artifact_registry_docker.member,
    ]
  }
}

resource "google_service_account_iam_policy" "service_account_dlp_deidentify_service" {
  service_account_id = google_service_account.dlp_deidentify_service.name
  policy_data        = data.google_iam_policy.service_account_dlp_deidentify_service.policy_data
}
