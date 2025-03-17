# The default serving config is automatically created by the API when the engine is created, so we
# need to make sure Terraform knows it already exists and doesn't try to create it.
import {
  id = "/engines/${google_discovery_engine_search_engine.govuk.engine_id}/servingConfigs/default_search"
  to = module.serving_config_default.restapi_object.serving_config
}

moved {
  from = module.govuk_content_discovery_engine.restapi_object.discovery_engine_datastore_schema
  to   = restapi_object.google_discovery_engine_datastore_schema
}
