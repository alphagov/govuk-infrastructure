module "serving_config_variant_global" {
  source = "./modules/serving_config"

  id           = "variant_search"
  display_name = "Variant (used as the 'B' variant when AB testing live Search API v2)"
  engine_id    = google_discovery_engine_search_engine.govuk_global.engine_id

  boost_control_ids = [
    # specific to serving_config_variant
    module.control_boost_demote_historic_global.id,
    module.control_boost_freshness_general_global.id,

    # identical to serving_config_default
    module.control_boost_promote_medium_global.id,
    module.control_boost_promote_low_global.id,
    module.control_boost_demote_low_global.id,
    module.control_boost_demote_medium_global.id,
    module.control_boost_demote_pages_global.id,

    # explicitly not included in serving_config_variant
    # module.control_boost_demote_strong.id,
  ]
  filter_control_ids = [
    # identical to serving_config_default
    module.control_filter_temporary_exclusions_global.id,
  ]
  synonyms_control_ids = [
    # identical to serving_config_default
    module.control_synonym_hmrc_global.id,
  ]
}

module "control_boost_demote_historic_global" {
  source = "./modules/control"

  id           = "boost_demote_historic"
  display_name = "Boost: Demote historic"
  engine_id    = google_discovery_engine_search_engine.govuk_global.engine_id
  action = {
    boostAction = {
      filter     = "is_historic = 1",
      fixedBoost = -0.25
      dataStore  = google_discovery_engine_data_store.govuk_content.name
    }
  }
}

module "control_boost_freshness_general_global" {
  source = "./modules/control"

  id           = "boost_freshness_general"
  display_name = "Boost: Freshness (general)"
  engine_id    = google_discovery_engine_search_engine.govuk_global.engine_id
  action = {
    boostAction = {
      dataStore = google_discovery_engine_data_store.govuk_content.name,
      interpolationBoostSpec = {
        fieldName         = "public_timestamp_datetime",
        attributeType     = "FRESHNESS",
        interpolationType = "LINEAR",
        controlPoints = [
          {
            attributeValue = "0D",
            boostAmount    = 0.4
          },
          {
            attributeValue = "30D",
            boostAmount    = 0.1
          },
          {
            attributeValue = "1460D",
            boostAmount    = 0
          }
        ]
      }
    }
  }
}
