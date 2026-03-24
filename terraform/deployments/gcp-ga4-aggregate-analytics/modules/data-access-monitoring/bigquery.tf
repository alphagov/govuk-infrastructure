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

  schema = <<EOF
[
  {
    "name": "user_email",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "The email address of the user authorized to read sensitive data"
  }
]
EOF
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

  schema = <<EOF
[
  {"name": "insertId", "type": "STRING", "mode": "REQUIRED", "description": "Unique ID from the audit log to prevent duplicates"},
  {"name": "timestamp", "type": "TIMESTAMP", "mode": "REQUIRED"},
  {"name": "user_email", "type": "STRING", "mode": "REQUIRED"},
  {"name": "resource_name", "type": "STRING", "mode": "REQUIRED"},
  {"name": "method_name", "type": "STRING", "mode": "REQUIRED"}
]
EOF
}

resource "google_bigquery_data_transfer_config" "detection_query" {
  project        = var.project_id
  display_name   = "Detect Unauthorised BQ Reads"
  location       = "europe-west2"
  data_source_id = "scheduled_query"
  schedule       = "every 5 minutes"

  service_account_name = google_service_account.query_executor.email

  params = {
    query = <<EOT
      MERGE `${google_bigquery_table.unauthorised_access.project}.${google_bigquery_table.unauthorised_access.dataset_id}.${google_bigquery_table.unauthorised_access.table_id}` T
      USING (
        SELECT 
          insertId,
          timestamp,
          protopayload_auditlog.authenticationInfo.principalEmail as user_email,
          protopayload_auditlog.resourceName as resource_name,
          protopayload_auditlog.methodName as method_name,
        FROM `${google_bigquery_dataset.audit_logs.project}.${google_bigquery_dataset.audit_logs.dataset_id}.cloudaudit_googleapis_com_data_access`
        WHERE 
          timestamp > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR)
          
          -- Reference the authorised_users table attribute
          AND protopayload_auditlog.authenticationInfo.principalEmail NOT IN (
            SELECT user_email FROM `${google_bigquery_table.authorised_users.project}.${google_bigquery_table.authorised_users.dataset_id}.${google_bigquery_table.authorised_users.table_id}`
          )
      ) S
      ON T.insertId = S.insertId
      WHEN NOT MATCHED THEN
        INSERT (insertId, timestamp, user_email, resource_name, method_name)
        VALUES (S.insertId, S.timestamp, S.user_email, S.resource_name, S.method_name)
    EOT
  }

  # Adding these explicitly as I'm not sure if the dependency will be inferred from the contents of params.query
  depends_on = [
    google_bigquery_table.unauthorised_access,
    google_bigquery_table.authorised_users,
  ]
}
