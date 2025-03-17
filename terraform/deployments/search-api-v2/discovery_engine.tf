# TODO: These IDs/paths are semi-hardcoded here as there aren't first party resources/data sources
# available for them yet.
locals {
  discovery_engine_default_collection_name = "projects/${var.gcp_project_id}/locations/${var.discovery_engine_location}/collections/default_collection"
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

resource "restapi_object" "google_discovery_engine_datastore_schema" {
  path      = "/dataStores/${google_discovery_engine_data_store.govuk_content.data_store_id}/schemas"
  object_id = "default_schema"

  data = jsonencode({
    jsonSchema = file("${path.module}/files/datastore-schema.json")
  })
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
