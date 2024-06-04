# Creates and configures service accounts, IAM roles, role bindings, and keys for a UI prototype to
# access Discovery Engine on a read-only basis.
# TODO: Remove this once the prototype is no longer needed.

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
