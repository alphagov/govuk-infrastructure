# The default serving config is automatically created by the API when the engine is created, so we
# need to make sure Terraform knows it already exists and doesn't try to create it.
import {
  id = "/engines/${google_discovery_engine_search_engine.govuk.engine_id}/servingConfigs/default_search"
  to = module.serving_config_default.restapi_object.serving_config
}

# The default serving config is automatically created by the API when the engine is created, so we
# need to make sure Terraform knows it already exists and doesn't try to create it.
import {
  id = "/engines/${google_discovery_engine_search_engine.govuk_global.engine_id}/servingConfigs/default_search"
  to = module.serving_config_default_global.restapi_object.serving_config
}

# The completion config resource is a permanent, pre-existing subresource on the datastore, so we
# never want to create it even if the state is empty.
import {
  id = "/dataStores/${google_discovery_engine_data_store.govuk_content.data_store_id}/completionConfig"
  to = restapi_object.google_discovery_engine_data_store_completion_config
}
