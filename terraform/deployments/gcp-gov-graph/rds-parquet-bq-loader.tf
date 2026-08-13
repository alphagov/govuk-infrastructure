resource "google_service_account" "rds_parquet_bq_loader" {
  account_id   = "rds-parquet-bq-loader"
  display_name = "RDS Parquet BQ Loader"
}

# Allow the deployment SA to pull images
data "google_iam_policy" "service_account_user_rds_parquet_bq_loader" {
  binding {
    role = "roles/iam.serviceAccountUser"

    members = [
      google_service_account.artifact_registry_docker.member,
    ]
  }
}

resource "google_service_account_iam_policy" "service_account_user_rds_parquet_bq_loader" {
  service_account_id = google_service_account.rds_parquet_bq_loader.name
  policy_data        = data.google_iam_policy.service_account_user_rds_parquet_bq_loader.policy_data
}

# ==============================================================================
#  CLOUD RUN JOB DEPLOYMENT
# ==============================================================================

resource "google_cloud_run_v2_job" "rds_parquet_bq_loader" {
  name     = "rds-parquet-bq-loader"
  location = "europe-west2"

  deletion_protection = true

  # Ensure the Service Account and its IAM policies are fully established
  # before the Cloud Run Job is deployed.
  depends_on = [
    google_service_account_iam_policy.service_account_user_rds_parquet_bq_loader
  ]

  template {
    task_count  = 5
    parallelism = 3

    template {
      max_retries           = 0
      timeout               = "7200s"
      execution_environment = "EXECUTION_ENVIRONMENT_GEN2"

      # Dynamically references the Service Account declared above
      service_account = google_service_account.rds_parquet_bq_loader.email

      containers {
        image = "europe-west2-docker.pkg.dev/${var.project_id}/docker/rds-parquet-bq-loader:latest"

        resources {
          limits = {
            cpu    = "2"
            memory = "8Gi"
          }
        }

        env {
          name  = "CONFIG_PATH"
          value = "config/${var.environment}/config.json"
        }

        env {
          name  = "RECOVERY_MODE"
          value = "False"
        }
      }
    }
  }
}

# ==============================================================================
# CLOUD SCHEDULER TRIGGER
# ==============================================================================

resource "google_cloud_scheduler_job" "rds_parquet_bq_loader_scheduler" {
  name             = "rds-parquet-bq-loader-scheduler"
  description      = "Triggers the Document DB BQ Loader job Mon-Fri at 06:30 AM"
  schedule         = "30 6 * * 1-5"
  time_zone        = "Europe/London"
  region           = "europe-west2"
  attempt_deadline = "320s"

  retry_config {
    retry_count = 3
  }

  http_target {
    http_method = "POST"
    # Targets the native Cloud Run V2 REST API run endpoint
    uri  = "https://run.googleapis.com/v2/projects/${google_cloud_run_v2_job.rds_parquet_bq_loader.project}/locations/${google_cloud_run_v2_job.rds_parquet_bq_loader.location}/jobs/${google_cloud_run_v2_job.rds_parquet_bq_loader.name}:run"
    body = base64encode("{}")

    headers = {
      "Content-Type" = "application/json"
    }

    # Reuses the same Service Account to authorize the Scheduler call
    oauth_token {
      service_account_email = google_service_account.rds_parquet_bq_loader.email
    }
  }
}
