# Creates and configures service accounts, IAM roles, role bindings, and keys for `search-api-v2` to
# be able to access the Discovery Engine API.
resource "google_service_account" "api" {
  account_id   = "search-api-v2"
  display_name = "search-api-v2 (Rails API app and document sync worker)"
  description  = "Service account to provide access to the search-api-v2 Rails app and document sync worker"
}

resource "google_service_account_key" "api" {
  service_account_id = google_service_account.api.id
}

resource "google_project_iam_custom_role" "api" {
  role_id     = "search_api_v2"
  title       = "search-api-v2"
  description = "Provides the required permissions for Search API v2 to access Discovery Engine"

  permissions = [
    "discoveryengine.servingConfigs.search",
    "discoveryengine.dataStores.completeQuery",
    "discoveryengine.dataStores.get",
    "discoveryengine.documents.create",
    "discoveryengine.documents.delete",
    "discoveryengine.documents.get",
    "discoveryengine.documents.import",
    "discoveryengine.documents.list",
    "discoveryengine.documents.update",
    "discoveryengine.operations.get",
  ]
}

resource "google_project_iam_binding" "api" {
  project = var.gcp_project_id
  role    = google_project_iam_custom_role.api.id

  members = [
    google_service_account.api.member
  ]
}

# Creates and configures service accounts, IAM roles, role bindings, and keys for `search-admin` to
# be able to access the Discovery Engine API.
resource "google_service_account" "search_admin" {
  account_id   = "search-admin"
  display_name = "Search Admin (Rails admin app)"
  description  = "Service account to provide access to the search-admin Rails app"
}

resource "google_service_account_key" "search_admin" {
  service_account_id = google_service_account.search_admin.id
}

resource "google_project_iam_custom_role" "search_admin" {
  role_id     = "search_admin"
  title       = "Search Admin"
  description = "Provides the required permissions for Search Admin to access Discovery Engine"

  permissions = [
    "discoveryengine.controls.create",
    "discoveryengine.controls.delete",
    "discoveryengine.controls.get",
    "discoveryengine.controls.list",
    "discoveryengine.controls.update",
    "discoveryengine.operations.get",
    "discoveryengine.servingConfigs.get",
    "discoveryengine.servingConfigs.list",
    "discoveryengine.servingConfigs.update",
  ]
}

resource "google_project_iam_binding" "search_admin" {
  project = var.gcp_project_id
  role    = google_project_iam_custom_role.search_admin.id

  members = [
    google_service_account.search_admin.member
  ]
}

resource "google_service_account" "analytics_events_pipeline" {
  account_id   = "analytics-events-pipeline"
  display_name = "analytics-events-pipeline"
  description  = "Service account for reading GA4 search events data and importing events into our project"
}
