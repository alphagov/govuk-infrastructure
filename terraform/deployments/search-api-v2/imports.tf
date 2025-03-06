# The default serving config is automatically created by the API when the engine is created, so we
# need to make sure Terraform knows it already exists and doesn't try to create it.
import {
  id = "/engines/${google_discovery_engine_search_engine.govuk.engine_id}/servingConfigs/default_search"
  to = module.govuk_content_discovery_engine.module.serving_config_default.restapi_object.serving_config
}

# Migrate existing controls to new control module
import {
  id = "/engines/${google_discovery_engine_search_engine.govuk.engine_id}/controls/boost_promote_medium"
  to = module.govuk_content_discovery_engine.module.control_boost_promote_medium.restapi_object.control
}

import {
  id = "/engines/${google_discovery_engine_search_engine.govuk.engine_id}/controls/boost_promote_low"
  to = module.govuk_content_discovery_engine.module.control_boost_promote_low.restapi_object.control
}

import {
  id = "/engines/${google_discovery_engine_search_engine.govuk.engine_id}/controls/boost_demote_low"
  to = module.govuk_content_discovery_engine.module.control_boost_demote_low.restapi_object.control
}

import {
  id = "/engines/${google_discovery_engine_search_engine.govuk.engine_id}/controls/boost_demote_medium"
  to = module.govuk_content_discovery_engine.module.control_boost_demote_medium.restapi_object.control
}

import {
  id = "/engines/${google_discovery_engine_search_engine.govuk.engine_id}/controls/boost_demote_strong"
  to = module.govuk_content_discovery_engine.module.control_boost_demote_strong.restapi_object.control
}

import {
  id = "/engines/${google_discovery_engine_search_engine.govuk.engine_id}/controls/boost_demote_pages"
  to = module.govuk_content_discovery_engine.module.control_boost_demote_pages.restapi_object.control
}

import {
  id = "/engines/${google_discovery_engine_search_engine.govuk.engine_id}/controls/syn_hmrc"
  to = module.govuk_content_discovery_engine.module.control_synonym_hmrc.restapi_object.control
}
