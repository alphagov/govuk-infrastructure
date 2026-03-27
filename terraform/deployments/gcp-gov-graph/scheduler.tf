resource "google_cloud_scheduler_job" "smart_survey" {
  name        = "smart-survey"
  description = "Smart Survey workflow schedule"
  schedule    = "0 7 * * *"
  time_zone   = "UTC"

  retry_config {
    retry_count = 0
  }

  http_target {
    http_method = "POST"
    uri         = "https://workflowexecutions.googleapis.com/v1/${google_workflows_workflow.smart_survey.id}/executions"
    body        = base64encode("{}")
    headers     = { "Content-Type" = "application/json" }
    oauth_token {
      service_account_email = google_service_account.workflow_smart_survey.email
    }
  }
}

resource "google_cloud_scheduler_job" "zendesk" {
  name        = "zendesk"
  description = "zendesk workflow schedule"
  schedule    = "0 7 * * *"
  time_zone   = "UTC"

  retry_config {
    retry_count = 0
  }

  http_target {
    http_method = "POST"
    uri         = "https://workflowexecutions.googleapis.com/v1/${google_workflows_workflow.zendesk.id}/executions"
    body        = base64encode("{}")
    headers     = { "Content-Type" = "application/json" }
    oauth_token {
      service_account_email = google_service_account.workflow_zendesk.email
    }
  }
}
