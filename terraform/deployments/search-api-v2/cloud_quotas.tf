resource "google_cloud_quotas_quota_preference" "evaluation_create_requests_preference" {
  parent   = "projects/${var.gcp_project_id}"
  name     = "discoveryengine_evaluation_create_requests"
  service  = "discoveryengine.googleapis.com"
  quota_id = "EvaluationCreateRequestsPerDayPerProject"
  quota_config {
    preferred_value = var.evaluation_create_requests
  }
}

resource "google_cloud_quotas_quota_preference" "complete_query_requests_preference" {
  parent   = "projects/${var.gcp_project_id}"
  name     = "discoveryengine_complete_query_requests"
  service  = "discoveryengine.googleapis.com"
  quota_id = "CompleteQueryRequestsPerMinutePerProject"
  quota_config {
    preferred_value = var.complete_query_requests
  }
}

# We are importing evaluation_create_requests_preference resource on integration
# as we'd created it manually when testing
import {
  for_each = var.import_quota_preference ? [1] : []
  id       = "projects/${var.gcp_project_id}/locations/global/quotaPreferences/discoveryengine_evaluation_create_requests"
  to       = google_cloud_quotas_quota_preference.evaluation_create_requests_preference
}
