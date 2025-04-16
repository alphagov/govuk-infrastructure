module "serving_config_raw_global" {
  source = "./modules/serving_config"

  id           = "raw_search"
  display_name = "Raw (without any attached controls, used for internal testing)"
  engine_id    = google_discovery_engine_search_engine.govuk_global.engine_id
}
