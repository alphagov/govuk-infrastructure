resource "restapi_object" "google_discovery_engine_data_store_completion_config" {
  path      = "/dataStores/${google_discovery_engine_data_store.govuk_content.data_store_id}/completionConfig"
  object_id = "completionConfig"

  update_path = "/dataStores/${google_discovery_engine_data_store.govuk_content.data_store_id}/completionConfig?updateMask=matching_order,max_suggestions,min_prefix_length,query_model,enable_mode,query_frequency_threshold,num_unique_users_threshold"
  read_path   = "/dataStores/${google_discovery_engine_data_store.govuk_content.data_store_id}/completionConfig"

  data = jsonencode({
    matchingOrder           = "out-of-order"
    maxSuggestions          = 5,
    minPrefixLength         = 3,
    queryFrequencyThreshold = 250,
    numUniqueUsersThreshold = 10,
    queryModel              = "automatic",
    enableMode              = "AUTOMATIC"
  })

  # VAIS adds some properties dynamically, which creates false positive drift
  ignore_changes_to = [
    "name"
  ]
}

# Bucket for autocomplete data artifacts (denylist)
resource "google_storage_bucket" "vais_artifacts" {
  name     = "${var.gcp_project_id}_vais_artifacts"
  location = var.gcp_region
}
