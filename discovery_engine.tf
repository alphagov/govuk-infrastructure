# Creates and configures an unstructured datastore for Google Discovery Engine ("Vertex AI Search")
# see https://cloud.google.com/generative-ai-app-builder/docs/reference/rest/

module "govuk_content_discovery_engine" {
  source = "../modules/google_discovery_engine_restapi"

  datastore_id   = google_discovery_engine_data_store.govuk_content.data_store_id
  datastore_path = google_discovery_engine_data_store.govuk_content.name
  engine_id      = google_discovery_engine_search_engine.govuk.engine_id
}

# TODO: These IDs/paths are semi-hardcoded here as there aren't first party resources/data sources
# available for them yet.
locals {
  discovery_engine_datastore_branch_path           = "${google_discovery_engine_data_store.govuk_content.name}/branches/default_branch"
  discovery_engine_serving_config_path             = "${google_discovery_engine_search_engine.govuk.name}/servingConfigs/default_search"
  discovery_engine_site_search_serving_config_path = "${google_discovery_engine_search_engine.govuk.name}/servingConfigs/site_search"
}

resource "google_discovery_engine_data_store" "govuk_content" {
  data_store_id = "govuk_content"
  display_name  = "govuk_content"
  location      = "global"

  industry_vertical = "GENERIC"
  content_config    = "CONTENT_REQUIRED" # == "unstructured" datastore
  solution_types    = ["SOLUTION_TYPE_SEARCH"]

  lifecycle {
    ignore_changes = [
      # TODO: Annoyingly, this field is not updatable by us, but can change internally (and indeed
      # has changed in integration after some engine experiments). This means we need to ignore
      # changes to it to avoid unnecessary resource replacements.
      solution_types
    ]
  }
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

resource "aws_secretsmanager_secret" "discovery_engine_configuration_search_admin" {
  name                    = "govuk/search-admin/google-cloud-discovery-engine-configuration"
  recovery_window_in_days = 0 # Force delete to allow re-applying immediately after destroying
}

resource "aws_secretsmanager_secret_version" "discovery_engine_configuration_search_admin" {
  secret_id = aws_secretsmanager_secret.discovery_engine_configuration_search_admin.id
  secret_string = jsonencode({
    "GOOGLE_CLOUD_CREDENTIALS"        = base64decode(google_service_account_key.search_admin.private_key)
    "DISCOVERY_ENGINE_ENGINE"         = google_discovery_engine_search_engine.govuk.name
    "DISCOVERY_ENGINE_SERVING_CONFIG" = local.discovery_engine_site_search_serving_config_path
  })
}
