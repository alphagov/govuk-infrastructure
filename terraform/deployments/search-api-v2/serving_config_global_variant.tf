module "serving_config_global_variant" {
  source = "./modules/serving_config"

  id           = "variant"
  display_name = "Variant (used as the 'B' variant when AB testing live Search API v2)"
  engine_id    = google_discovery_engine_search_engine.govuk_global.engine_id

  boost_control_ids = [
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
