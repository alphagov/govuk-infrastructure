# TODO: These IDs/paths are semi-hardcoded here as there aren't first party resources/data sources
# available for them yet.
locals {
  discovery_engine_default_location_name   = "projects/${var.gcp_project_id}/locations/${var.discovery_engine_location}"
  discovery_engine_default_collection_name = "${local.discovery_engine_default_location_name}/collections/default_collection"
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

resource "google_discovery_engine_search_engine" "govuk_global" {
  engine_id    = "govuk_global"
  display_name = "GOV.UK Site Search for Global Search"

  location      = google_discovery_engine_data_store.govuk_content.location
  collection_id = "default_collection"

  industry_vertical = "GENERIC"

  data_store_ids = [google_discovery_engine_data_store.govuk_content.data_store_id]

  search_engine_config {
    search_tier    = "SEARCH_TIER_STANDARD"
    search_add_ons = []
  }

  common_config {
    company_name = "GOV.UK"
  }
}
