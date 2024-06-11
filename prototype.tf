# Creates and configures service accounts, IAM roles, role bindings, and keys for a UI prototype to
# access Discovery Engine on a read-only basis.
# TODO: Remove this once the prototype is no longer needed.

locals {
  prototype_discovery_engine_serving_config_path = "${google_discovery_engine_search_engine.ui_prototype.name}/servingConfigs/default_search"
}

# Additional engine specifically for the UI prototype, allowing us to enable a higher search tier
# and add ons without risking accidentally using them in production (expensive!).
resource "google_discovery_engine_search_engine" "ui_prototype" {
  engine_id    = "ui_prototype"
  display_name = "Search UI Prototype"

  location      = google_discovery_engine_data_store.govuk_content.location
  collection_id = "default_collection"

  industry_vertical = "GENERIC"

  data_store_ids = [google_discovery_engine_data_store.govuk_content.data_store_id]

  search_engine_config {
    search_tier    = "SEARCH_TIER_ENTERPRISE"
    search_add_ons = ["SEARCH_ADD_ON_LLM"]
  }

  common_config {
    company_name = "GOV.UK"
  }
}

resource "google_service_account" "prototype" {
  account_id   = "search-ui-prototype"
  display_name = "search-ui-prototype (research prototype)"
  description  = "Service account to provide read-only access to the Discovery Engine API for the Search UI prototype"
}

resource "google_service_account_key" "prototype" {
  service_account_id = google_service_account.prototype.id
}

resource "google_project_iam_custom_role" "prototype" {
  role_id     = "search_ui_prototype"
  title       = "search-ui-prototype"
  description = "Provides the required permissions for the Search UI prototype to access Discovery Engine"

  permissions = [
    "discoveryengine.servingConfigs.search",
    "discoveryengine.dataStores.completeQuery",
  ]
}

resource "google_project_iam_binding" "prototype" {
  project = var.gcp_project_id
  role    = google_project_iam_custom_role.prototype.id

  members = [
    google_service_account.prototype.member
  ]
}
