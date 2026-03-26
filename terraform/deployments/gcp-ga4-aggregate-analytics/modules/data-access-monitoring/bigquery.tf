resource "google_bigquery_dataset" "audit_logs" {
  project    = var.project_id
  dataset_id = "data_access_logs"
  location   = "europe-west2"
}

# The "Allow List" Table
resource "google_bigquery_table" "authorised_users" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.audit_logs.dataset_id
  table_id   = "authorised_users"

  schema = jsonencode([
    {
      name        = "user_email"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "The email address of the user authorised to read sensitive data"
    }
  ])
}

# Table to store the findings
resource "google_bigquery_table" "unauthorised_access" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.audit_logs.dataset_id
  table_id   = "unauthorised_access"

  expiration_time = null

  time_partitioning {
    type  = "DAY"
    field = "timestamp"
  }

  schema = jsonencode([
    {
      name        = "insertId"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "Unique ID from the audit log to prevent duplicates"
    },
    {
      name        = "timestamp"
      type        = "TIMESTAMP"
      mode        = "REQUIRED"
      description = "The time the event occurred"
    },
    {
      name        = "user_email"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "The email of the user performing the read"
    },
    {
      name        = "resource_name"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "The full resource name of the table accessed"
    },
    {
      name        = "method_name"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "The API method used (e.g. JobService.InsertJob)"
    }
  ])
}

resource "google_bigquery_data_transfer_config" "detection_query" {
  project        = var.project_id
  display_name   = "Detect Unauthorised BQ Reads"
  location       = "europe-west2"
  data_source_id = "scheduled_query"
  schedule       = "every 60 minutes"

  service_account_name = google_service_account.query_executor.email

  email_preferences {
    enable_failure_email = true
  }

  params = {
    query = templatefile("${path.module}/detection_query.sql.tftpl", {
      project_id                = var.project_id
      audit_log_table           = "${google_bigquery_dataset.audit_logs.project}.${google_bigquery_dataset.audit_logs.dataset_id}.cloudaudit_googleapis_com_data_access"
      authorised_users_table    = "${google_bigquery_table.authorised_users.project}.${google_bigquery_table.authorised_users.dataset_id}.${google_bigquery_table.authorised_users.table_id}"
      unauthorised_access_table = "${google_bigquery_table.unauthorised_access.project}.${google_bigquery_table.unauthorised_access.dataset_id}.${google_bigquery_table.unauthorised_access.table_id}"
    })
  }

  # Adding these explicitly as I'm not sure if the dependency will be inferred from the contents of params.query
  depends_on = [
    google_bigquery_table.unauthorised_access,
    google_bigquery_table.authorised_users,
  ]
}
