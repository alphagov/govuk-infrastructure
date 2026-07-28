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

# Allow the CLoud Run Job to invoke service
data "google_iam_policy" "cloud_run_rds_parquet_bq_loader" {
  binding {
    role = "roles/run.invoker"
    members = [
      google_service_account.rds_parquet_bq_loader.member,
    ]
  }
}

resource "google_cloud_run_v2_service_iam_policy" "cloud_run_rds_parquet_bq_loader" {
  location    = var.region
  name        = "rds-parquet-bq-loader"
  policy_data = data.google_iam_policy.cloud_run_rds_parquet_bq_loader.policy_data
}
