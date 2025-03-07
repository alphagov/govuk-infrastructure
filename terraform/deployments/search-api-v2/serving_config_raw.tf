module "serving_config_raw" {
  source = "./modules/serving_config"

  id           = "raw_search"
  display_name = "Raw (without any attached controls, used for internal testing)"
  engine_id    = google_discovery_engine_search_engine.govuk.engine_id
}
