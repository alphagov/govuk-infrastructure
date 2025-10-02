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
    module.control_global_boost_demote_low_pages.id,
    module.control_global_boost_demote_medium.id,
    module.control_global_boost_demote_pages.id,
    module.control_global_boost_demote_strong.id,
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
        # Control points explained
        # 0.2 (decaying to 0.05), for the first 7 days
        # 0.05 (decaying to 0), for 8 days to 90 days
        # 0 (decaying to -0.5) for 91 days to 365 days
        # -0.5 (decaying to -0.75) for 366 days to 1460 days
        controlPoints = [
          {
            attributeValue = "0D",
            boostAmount    = 0.2
          },
          {
            attributeValue = "7D",
            boostAmount    = 0.05
          },
          {
            attributeValue = "90D",
            boostAmount    = 0
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
