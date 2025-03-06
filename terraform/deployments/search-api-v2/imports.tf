# The default serving config is automatically created by the API when the engine is created, so we
# need to make sure Terraform knows it already exists and doesn't try to create it.
import {
  id = "/engines/${google_discovery_engine_search_engine.govuk.engine_id}/servingConfigs/default_search"
  to = module.serving_config_default.restapi_object.serving_config
}

# Migrate existing controls to new control module
moved {
  from = module.govuk_content_discovery_engine.module.serving_config_default
  to   = module.serving_config_default
}

moved {
  from = module.govuk_content_discovery_engine.module.control_boost_promote_medium
  to   = module.control_boost_promote_medium
}

moved {
  from = module.govuk_content_discovery_engine.module.control_boost_promote_low
  to   = module.control_boost_promote_low
}

moved {
  from = module.govuk_content_discovery_engine.module.control_boost_demote_low
  to   = module.control_boost_demote_low
}

moved {
  from = module.govuk_content_discovery_engine.module.control_boost_demote_medium
  to   = module.control_boost_demote_medium
}

moved {
  from = module.govuk_content_discovery_engine.module.control_boost_demote_strong
  to   = module.control_boost_demote_strong
}

moved {
  from = module.govuk_content_discovery_engine.module.control_boost_demote_pages
  to   = module.control_boost_demote_pages
}

moved {
  from = module.govuk_content_discovery_engine.module.control_synonym_hmrc
  to   = module.control_synonym_hmrc
}
