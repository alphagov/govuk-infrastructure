module "serving_config_global_variant" {
  source = "./modules/serving_config"

  id           = "variant"
  display_name = "Variant (used as the 'B' variant when AB testing live Search API v2)"
  engine_id    = google_discovery_engine_search_engine.govuk_global.engine_id

  boost_control_ids = [
    # specific to serving_config_global_variant
    google_discovery_engine_control.boost_freshness_general.control_id,

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

resource "google_discovery_engine_control" "boost_freshness_general" {
  location      = google_discovery_engine_search_engine.govuk_global.location
  engine_id     = google_discovery_engine_search_engine.govuk_global.engine_id
  control_id    = "boost_freshness_general"
  display_name  = "Boost: Freshness (general)"
  solution_type = "SOLUTION_TYPE_SEARCH"
  use_cases     = ["SEARCH_USE_CASE_SEARCH"]
  boost_action {
    data_store = google_discovery_engine_data_store.govuk_content.name
    filter     = "content_purpose_supergroup: ANY(\"news_and_communications\")"
    interpolation_boost_spec {
      field_name         = "public_timestamp_datetime"
      attribute_type     = "FRESHNESS"
      interpolation_type = "LINEAR"
      # Control points explained
      # 0.2 (decaying to 0.05), for the first 7 days
      # 0.05 (decaying to 0), for 8 days to 90 days
      # 0 (decaying to -0.5) for 91 days to 365 days
      # -0.5 (decaying to -0.75) for 366 days to 1460 days
      control_point {
        attribute_value = "0D"
        boost_amount    = 0.2
      }
      control_point {
        attribute_value = "7D"
        boost_amount    = 0.05
      }
      control_point {
        attribute_value = "90D"
        boost_amount    = 0
      }
      control_point {
        attribute_value = "365D"
        boost_amount    = -0.5
      }
      control_point {
        attribute_value = "1460D"
        boost_amount    = -0.75
      }
    }
  }
}
