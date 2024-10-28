resource "google_service_account" "sa--ga4-analytics-352613" {
  account_id                   = "ga4-analytics-352613"
  disabled                     = "false"
  display_name                 = "App Engine default service account"
  project                      = google_project.project.project_id
  create_ignore_already_exists = "true"
}

resource "google_service_account" "sa--ga-database" {
  account_id                   = "ga-database"
  description                  = "Account for analytics_settings_database"
  disabled                     = "false"
  display_name                 = "ga-database"
  project                      = google_project.project.project_id
  create_ignore_already_exists = "true"
}

resource "google_service_account" "sa--ga4-user-admin" {
  account_id                   = "ga4-user-admin"
  disabled                     = "false"
  display_name                 = "GA4 User Admin"
  project                      = google_project.project.project_id
  create_ignore_already_exists = "true"
}

resource "google_service_account" "sa--search-analytics-pipeline" {
  account_id                   = "search-analytics-pipeline"
  description                  = "Service account used by the Search Analytics Pipeline to access the GA4 API"
  disabled                     = "false"
  display_name                 = "search-analytics-pipeline"
  project                      = google_project.project.project_id
  create_ignore_already_exists = "true"
}
