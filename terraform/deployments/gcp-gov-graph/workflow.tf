# A workflow to create an instance from a template, triggered by PubSub

resource "google_service_account" "workflow_govuk_database_backups" {
  account_id   = "workflow-database-backups"
  display_name = "Service account for the govuk-database-backups workflow"
}

resource "google_service_account" "eventarc" {
  account_id   = "eventarc"
  display_name = "Service account for EventArc to trigger workflows"
}

resource "google_workflows_workflow" "govuk_database_backups" {
  name            = "govuk-database-backups"
  region          = var.region
  description     = "Run database instances from their templates"
  service_account = google_service_account.workflow_govuk_database_backups.id
  source_contents = templatefile(
    "workflows/govuk-database-backups.yaml",
    {
      project_id                    = var.project_id
      zone                          = var.zone
      postgres_startup_script       = jsonencode(var.postgres-startup-script)
      publishing_api_metadata_value = jsonencode(module.publishing-api-container.metadata_value)
      support_api_metadata_value    = jsonencode(module.support-api-container.metadata_value)
      publisher_metadata_value      = jsonencode(module.publisher-container.metadata_value)
      whitehall_metadata_value      = jsonencode(module.whitehall-container.metadata_value)
      asset_manager_metadata_value  = jsonencode(module.asset-manager-container.metadata_value)
    }
  )
}

resource "google_eventarc_trigger" "govuk_database_backups" {
  name            = "govuk-database-backups"
  location        = var.region
  service_account = google_service_account.eventarc.email
  matching_criteria {
    attribute = "type"
    value     = "google.cloud.pubsub.topic.v1.messagePublished"
  }
  destination {
    workflow = google_workflows_workflow.govuk_database_backups.id
  }
  transport {
    pubsub {
      topic = google_pubsub_topic.govuk_database_backups.id
    }
  }
}

# A service account for the redis-cli workflow
resource "google_service_account" "workflow_redis_cli" {
  account_id   = "workflow-redis-cli"
  display_name = "Service account for the redis-cli workflow"
}

# A workflow to start a virtual machine to access the Memorystore Redis instance
resource "google_workflows_workflow" "redis_cli" {
  name            = "redis-cli"
  region          = var.region
  description     = "Create a virtual machine for accessing the Memorystore Redis instance"
  service_account = google_service_account.workflow_redis_cli.id

  # Enable / Disable
  count = var.enable_redis_session_store_instance ? 1 : 0

  source_contents = templatefile(
    "workflows/redis-cli.yaml",
    {
      project_id     = var.project_id,
      zone           = var.zone,
      network_name   = google_redis_instance.session_store[0].authorized_network,
      subnetwork_id  = google_compute_subnetwork.cloudrun.id,
      metadata_value = jsonencode(module.redis-cli-container[0].metadata_value)
    }
  )
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

