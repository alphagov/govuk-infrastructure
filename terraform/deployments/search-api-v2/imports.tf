# The default serving config is automatically created by the API when the engine is created, so we
# need to make sure Terraform knows it already exists and doesn't try to create it.
import {
  id = "/engines/${google_discovery_engine_search_engine.govuk.engine_id}/servingConfigs/default_search"
  to = module.serving_config_default.restapi_object.serving_config
}
