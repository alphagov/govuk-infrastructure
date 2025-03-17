resource "restapi_object" "google_discovery_engine_data_store_completion_config" {
  path      = "/dataStores/${google_discovery_engine_data_store.govuk_content.data_store_id}/completionConfig"
  object_id = "completionConfig"

  update_path = "/dataStores/${google_discovery_engine_data_store.govuk_content.data_store_id}/completionConfig?updateMask=name,matching_order,max_suggestions,min_prefix_length,query_model,enable_mode"
  read_path   = "/dataStores/${google_discovery_engine_data_store.govuk_content.data_store_id}/completionConfig"

  data = jsonencode({
    name            = "completionConfig"
    matchingOrder   = "out-of-order"
    maxSuggestions  = 5,
    minPrefixLength = 3,
    queryModel      = "automatic",
    enableMode      = "AUTOMATIC"
  })
}
