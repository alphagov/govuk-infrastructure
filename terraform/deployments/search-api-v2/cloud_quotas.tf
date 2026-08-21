resource "google_cloud_quotas_quota_preference" "evaluation_create_requests_preference" {
  parent        = "projects/${gcp_project_id}"
  name          = "discoveryengine_evaluation_create_requests"
  service       = "discoveryengine.googleapis.com"
  quota_id      = "EvaluationCreateRequestsPerDayPerProject"
  quota_config  {
    preferred_value = var.evaluation_create_requests
  }
}
