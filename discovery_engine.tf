# Creates and configures an unstructured datastore for Google Discovery Engine ("Vertex AI Search")
# see https://cloud.google.com/generative-ai-app-builder/docs/reference/rest/

module "govuk_content_discovery_engine" {
  source = "../modules/google_discovery_engine_restapi"

  datastore_id = "govuk_content"
}

# TODO: These IDs/paths are semi-hardcoded here as there aren't first party resources/data sources
# available for them yet.
locals {
  discovery_engine_datastore_branch_path = "${google_discovery_engine_data_store.govuk_content.name}/branches/default_branch"
  discovery_engine_serving_config_path   = "${google_discovery_engine_data_store.govuk_content.name}/servingConfigs/default_search"
}

resource "google_discovery_engine_data_store" "govuk_content" {
  data_store_id = "govuk_content"
  display_name  = "govuk_content"
  location      = "global"

  industry_vertical = "GENERIC"
  content_config    = "CONTENT_REQUIRED" # == "unstructured" datastore
  solution_types    = ["SOLUTION_TYPE_SEARCH"]
}

resource "google_discovery_engine_search_engine" "govuk" {
  engine_id    = "govuk"
  display_name = "GOV.UK Site Search"

  location      = google_discovery_engine_data_store.govuk_content.location
  collection_id = "default_collection"

  # TODO: The engine was originally created before this field existed. It now defaults to "GENERIC",
  # but setting that explicitly causes it to be replaced. This is a workaround to avoid that.
  industry_vertical = ""

  data_store_ids = [google_discovery_engine_data_store.govuk_content.data_store_id]

  search_engine_config {
    search_tier    = "SEARCH_TIER_STANDARD"
    search_add_ons = []
  }

  common_config {
    company_name = "GOV.UK"
  }
}

resource "aws_secretsmanager_secret" "discovery_engine_configuration" {
  name                    = "govuk/search-api-v2/google-cloud-discovery-engine-configuration"
  recovery_window_in_days = 0 # Force delete to allow re-applying immediately after destroying
}

resource "aws_secretsmanager_secret_version" "discovery_engine_configuration" {
  secret_id = aws_secretsmanager_secret.discovery_engine_configuration.id
  secret_string = jsonencode({
    "GOOGLE_CLOUD_CREDENTIALS"          = base64decode(google_service_account_key.api.private_key)
    "DISCOVERY_ENGINE_DATASTORE_BRANCH" = local.discovery_engine_datastore_branch_path,
    "DISCOVERY_ENGINE_DATASTORE"        = google_discovery_engine_data_store.govuk_content.name,
    "DISCOVERY_ENGINE_SERVING_CONFIG"   = local.discovery_engine_serving_config_path
  })
}
