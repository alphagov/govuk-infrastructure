resource "google_service_account" "log_writer" {
  account_id   = "log-writer"
  display_name = "Log writer"
  description  = "For writing logs to a bucket in another project"
}

data "google_iam_policy" "service_account_log_writer" {
  binding {
    role = "roles/iam.serviceAccountTokenCreator"

    members = [
      "serviceAccount:service-${var.project_number}@gcp-sa-logging.iam.gserviceaccount.com",
    ]
  }
}

resource "google_service_account_iam_policy" "log_writer" {
  service_account_id = google_service_account.log_writer.name
  policy_data        = data.google_iam_policy.service_account_log_writer.policy_data
}

resource "google_logging_project_sink" "log_sink" {
  name        = "log-sink"
  destination = "logging.googleapis.com/projects/gds-bq-reporting/locations/${var.region}/buckets/multi_project"
  exclusions {
    name        = "standard-exclusions"
    description = "Standard exclusions https://docs.data-community.publishing.service.gov.uk/data-sources/gcp-logs/#set-up"
    filter      = <<-EOT
      logName=(
              "projects/govuk-knowledge-graph/logs/cloudaudit.googleapis.com%2Factivity"
           OR "projects/govuk-knowledge-graph/logs/cloudaudit.googleapis.com%2Fsystem_event"
           OR "projects/govuk-knowledge-graph/logs/cloudaudit.googleapis.com%2Faccess_transparency"
        OR "projects/govuk-knowledge-graph/logs/externalaudit.googleapis.com%2Factivity"
        OR "projects/govuk-knowledge-graph/logs/externalaudit.googleapis.com%2Fsystem_event"
        OR "projects/govuk-knowledge-graph/logs/externalaudit.googleapis.com%2Faccess_transparency"
      )
    EOT
  }
  unique_writer_identity = true
  custom_writer_identity = google_service_account.log_writer.member
}
