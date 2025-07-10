module "serving_config_global_variant" {
  source = "./modules/serving_config"

  id           = "variant"
  display_name = "Variant (used as the 'B' variant when AB testing live Search API v2)"
  engine_id    = google_discovery_engine_search_engine.govuk_global.engine_id

  boost_control_ids = [
    # specific to serving_config_global_variant
    module.control_global_boost_freshness_general.id,

    # identical to serving_config_global_default
    module.control_global_boost_promote_medium.id,
    module.control_global_boost_promote_low.id,
    module.control_global_boost_demote_low.id,
    module.control_global_boost_demote_medium.id,
    module.control_global_boost_demote_pages.id,
    module.control_global_boost_demote_strong.id
  ]
  filter_control_ids = [
    # identical to serving_config_global_default
    module.control_global_filter_temporary_exclusions.id,
  ]
  synonyms_control_ids = [
    # identical to serving_config_global_default
    module.control_global_synonym_hmrc.id,
  ]
}

module "control_global_boost_freshness_general" {
  source = "./modules/control"

  id           = "boost_freshness_general"
  display_name = "Boost: Freshness (general)"
  engine_id    = google_discovery_engine_search_engine.govuk_global.engine_id
  action = {
    boostAction = {
      dataStore = google_discovery_engine_data_store.govuk_content.name,
      filter    = "content_purpose_supergroup: ANY(\"news_and_communications\")",
      interpolationBoostSpec = {
        fieldName         = "public_timestamp_datetime",
        attributeType     = "FRESHNESS",
        interpolationType = "LINEAR",
        controlPoints = [
          {
            attributeValue = "7D",
            boostAmount    = 0.2
          },
          {
            attributeValue = "90D",
            boostAmount    = 0.05
          },
          {
            attributeValue = "365D",
            boostAmount    = -0.5
          },
          {
            attributeValue = "1460D",
            boostAmount    = -0.75
          }
        ]
      }
    }
  }
}