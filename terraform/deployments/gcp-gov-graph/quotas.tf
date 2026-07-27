resource "google_cloud_quotas_quota_preference" "bigquery_query_usage_per_day" {
  parent        = "projects/${var.project_id}"
  name          = "bigquery-query-usage-per-day"
  service       = "bigquery.googleapis.com"
  quota_id      = "QueryUsagePerDay"
  contact_email = "govgraph-developers@digital.cabinet-office.gov.uk"
  quota_config {
    preferred_value = 3145728 # 3145728 Mib = 3 TiB
  }
}
