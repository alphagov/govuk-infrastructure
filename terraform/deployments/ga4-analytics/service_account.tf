resource "google_service_account" "ga4_analytics" {
  account_id                   = google_project.project.project_id
  display_name                 = "App Engine default service account"
  create_ignore_already_exists = "true"
}

resource "google_service_account" "ga_database" {
  account_id                   = "ga-database"
  description                  = "Account for analytics_settings_database"
  display_name                 = "ga-database"
  create_ignore_already_exists = "true"
}

resource "google_service_account" "ga4_user_admin" {
  account_id                   = "ga4-user-admin"
  display_name                 = "GA4 User Admin"
  create_ignore_already_exists = "true"
}

resource "google_service_account" "search_analytics_pipeline" {
  account_id                   = "search-analytics-pipeline"
  description                  = "Service account used by the Search Analytics Pipeline to access the GA4 API"
  display_name                 = "search-analytics-pipeline"
  create_ignore_already_exists = "true"
}
