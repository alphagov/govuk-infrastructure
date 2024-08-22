resource "google_bigquery_dataset" "fastly_logs" {
  dataset_id = "fastly_logs"

  location              = "europe-west2"
  storage_billing_model = "PHYSICAL"

  access {
    role          = "roles/bigquery.admin"
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
    role       = "roles/bigquery.dataEditor"
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

  schema = jsonencode(
    [
      {
        "description" = ""
        "fields"      = []
        "mode"        = ""
        "name"        = "client_ip"
        "type"        = "STRING"
      },
      {
        "description" = ""
        "fields"      = []
        "mode"        = ""
        "name"        = "request_received"
        "type"        = "STRING"
      },
      {
        "description" = ""
        "fields"      = []
        "mode"        = ""
        "name"        = "method"
        "type"        = "STRING"
      },
      {
        "description" = ""
        "fields"      = []
        "mode"        = ""
        "name"        = "url"
        "type"        = "STRING"
      },
      {
        "description" = ""
        "fields"      = []
        "mode"        = ""
        "name"        = "status"
        "type"        = "INTEGER"
      },
      {
        "description" = ""
        "fields"      = []
        "mode"        = ""
        "name"        = "protocol"
        "type"        = "STRING"
      },
      {
        "description" = ""
        "fields"      = []
        "mode"        = ""
        "name"        = "bytes"
        "type"        = "INTEGER"
      },
      {
        "description" = ""
        "fields"      = []
        "mode"        = ""
        "name"        = "content_type"
        "type"        = "STRING"
      },
      {
        "description" = ""
        "fields"      = []
        "mode"        = ""
        "name"        = "user_agent"
        "type"        = "STRING"
      },
      {
        "description" = ""
        "fields"      = []
        "mode"        = ""
        "name"        = "fastly_backend"
        "type"        = "STRING"
      },
      {
        "description" = ""
        "fields"      = []
        "mode"        = ""
        "name"        = "cache_response"
        "type"        = "STRING"
      },
      {
        "description" = ""
        "fields"      = []
        "mode"        = ""
        "name"        = "tls_client_protocol"
        "type"        = "STRING"
      },
      {
        "description" = ""
        "fields"      = []
        "mode"        = ""
        "name"        = "tls_client_cipher"
        "type"        = "STRING"
      },
    ]
  )
}
