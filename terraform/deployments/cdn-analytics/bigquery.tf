resource "google_bigquery_dataset" "fastly_logs" {
  dataset_id = "fastly_logs"

  location              = "europe-west2"
  storage_billing_model = "PHYSICAL"

  access {
    role          = "OWNER"
    user_by_email = "terraform-cloud-${var.govuk_environment}@${data.google_project.project.project_id}.iam.gserviceaccount.com"
  }

  access {
    role           = "roles/bigquery.admin"
    group_by_email = "govuk-gcp-access@digital.cabinet-office.gov.uk"
  }

  access {
    role           = "roles/bigquery.admin"
    group_by_email = "analytics-team@digital.cabinet-office.gov.uk"
  }

  access {
    role          = "WRITER"
    user_by_email = google_service_account.fastly_writer.email
  }
}

resource "google_bigquery_table" "fastly_logs" {
  dataset_id = google_bigquery_dataset.fastly_logs.dataset_id
  table_id   = "fastly_logs"

  time_partitioning {
    type          = "DAY"
    expiration_ms = 604800000 # 7 days
  }

  schema = file("bigquery_schema.json")
}
