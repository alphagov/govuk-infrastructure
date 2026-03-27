# A service to use as a remote function in BigQuery
# Then create a place to put the app images
resource "google_cloud_run_v2_service" "data_loss_prevention" {
  name     = "data-loss-prevention"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  template {
    service_account = google_service_account.data_loss_prevention.email
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker.repository_id}/data-loss-prevention:latest"
      env {
        name  = "PROJECT_ID"
        value = var.project_id
      }
      resources {
        limits = {
          cpu    = "1000m"  # If we put "1" or nothing, terraform reapplies it.
          memory = "2048Mi" # By experiment, necessary and sufficient.
        }
      }
    }
  }
}

resource "google_service_account" "data_loss_prevention" {
  account_id   = "data-loss-prevention"
  display_name = "Service account for Cloud Run service data-loss-prevention"
}

resource "google_bigquery_connection" "data_loss_prevention" {
  connection_id = "data-loss-prevention"
  description   = "Remote function data_loss_prevention"
  location      = var.region
  cloud_resource {}
}

data "google_iam_policy" "cloud_run_data_loss_prevention" {
  binding {
    role = "roles/run.invoker"
    members = [
      "serviceAccount:${google_bigquery_connection.data_loss_prevention.cloud_resource[0].service_account_id}",
    ]
  }
}

resource "google_cloud_run_v2_service_iam_policy" "data_loss_prevention" {
  location    = var.region
  name        = google_cloud_run_v2_service.data_loss_prevention.name
  policy_data = data.google_iam_policy.cloud_run_data_loss_prevention.policy_data
}

data "google_iam_policy" "bigquery_connection_data_loss_prevention" {
  binding {
    role = "roles/bigquery.connectionUser"
    members = [
      google_service_account.bigquery_scheduled_queries.member,
    ]
  }
}

resource "google_bigquery_connection_iam_policy" "data_loss_prevention" {
  connection_id = google_bigquery_connection.data_loss_prevention.connection_id
  policy_data   = data.google_iam_policy.bigquery_connection_data_loss_prevention.policy_data
}

# generate a random string suffix for a bigquery job to deploy the function
resource "random_string" "deploy_data_loss_prevention" {
  length  = 20
  special = false
}

## Run a bigquery job to deploy the remote function
resource "google_bigquery_job" "deploy_data_loss_prevention" {
  job_id   = "d_job_${random_string.deploy_data_loss_prevention.result}"
  location = var.region

  query {
    priority = "INTERACTIVE"
    query = templatefile(
      "bigquery/data-loss-prevention.sql",
      {
        project_id = var.project_id
        region     = var.region
        uri        = google_cloud_run_v2_service.data_loss_prevention.uri
      }
    )
    create_disposition = "" # must be set to "" for scripts
    write_disposition  = "" # must be set to "" for scripts
  }
}

data "google_iam_policy" "service_account_data_loss_prevention" {
  binding {
    role = "roles/iam.serviceAccountUser"

    members = [
      google_service_account.artifact_registry_docker.member,
    ]
  }
}

resource "google_service_account_iam_policy" "service_account_data_loss_prevention" {
  service_account_id = google_service_account.data_loss_prevention.name
  policy_data        = data.google_iam_policy.service_account_data_loss_prevention.policy_data
}
