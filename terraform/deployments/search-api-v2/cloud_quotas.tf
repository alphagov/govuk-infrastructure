resource "google_cloud_quotas_quota_preference" "evaluation_create_requests_preference" {
  parent        = "projects/${gcp_project_id}"
  name          = "discoveryengine_evaluation_create_requests"
  service       = "discoveryengine.googleapis.com"
  quota_id      = "EvaluationCreateRequestsPerDayPerProject"
  quota_config  {
    preferred_value = var.evaluation_create_requests
  }
}

resource "google_cloud_quotas_quota_preference" "complete_query_requests_preference" {
  parent        = "projects/${gcp_project_id}"
  name          = "discoveryengine_complete_query_requests"
  service       = "discoveryengine.googleapis.com"
  quota_id      = "CompleteQueryRequestsPerMinutePerProject"
  quota_config  {
    preferred_value = var.complete_query_requests
  }
}

resource "google_cloud_quotas_quota_preference" "search_requests_regional_preference" {
  parent        = "projects/${gcp_project_id}"
  name          = "discoveryengine_search_requests_regional"
  dimensions    = { region = "global" }
  service       = "discoveryengine.googleapis.com"
  quota_id      = "SearchRequestsPerMinutePerProjectPerRegion"
  quota_config  {
    preferred_value = var.search_requests_regional
  }
}
