# A workflow to create an instance from a template, triggered by PubSub

resource "google_service_account" "workflow_govuk_database_backups" {
  account_id   = "workflow-database-backups"
  display_name = "Service account for the govuk-database-backups workflow"
}

resource "google_service_account" "eventarc" {
  account_id   = "eventarc"
  display_name = "Service account for EventArc to trigger workflows"
}

# A service account for the smart-survey workflow
resource "google_service_account" "workflow_smart_survey" {
  account_id   = "workflow-smart-survey"
  display_name = "Service account for the smart-survey workflow"
}

# Workflow for the smart-survey data
resource "google_workflows_workflow" "smart_survey" {
  name                    = "smart-survey"
  region                  = var.region
  description             = "Fetch from the Smart Survey API into BigQuery"
  service_account         = google_service_account.workflow_smart_survey.id
  execution_history_level = "EXECUTION_HISTORY_DETAILED"

  source_contents = templatefile(
    "workflows/smart-survey.yaml",
    {
      http_to_bucket_uri = google_cloud_run_v2_service.http_to_bucket.uri,
      bucket_name        = google_storage_bucket.smart_survey.name,
      schema = indent(32,
      yamlencode(jsondecode(file("schemas/smart-survey/raw-responses.json")))),
      query = jsonencode(file("bigquery/smart-survey-responses.sql"))
    }
  )
}

# A service account for the zendesk workflow
resource "google_service_account" "workflow_zendesk" {
  account_id   = "workflow-zendesk"
  display_name = "Service account for the Zendeesk workflow"
}

# A workflow to fetch tickets from the zendesk api
resource "google_workflows_workflow" "zendesk" {
  name                    = "zendesk"
  region                  = var.region
  description             = "Fetch from the Zendesk API into BigQuery"
  service_account         = google_service_account.workflow_zendesk.id
  execution_history_level = "EXECUTION_HISTORY_DETAILED"

  source_contents = templatefile(
    "workflows/zendesk.yaml",
    {
      http_to_bucket_uri = google_cloud_run_v2_service.http_to_bucket.uri,
      bucket_name        = google_storage_bucket.zendesk.name,
      schema = indent(32,
      yamlencode(jsondecode(file("schemas/zendesk/tickets-incremental.json")))),
      query = jsonencode(file("bigquery/zendesk-tickets.sql"))
    }
  )
}

