module "serving_config_global_raw" {
  source = "./modules/serving_config"

  id           = "raw"
  display_name = "Raw (without any attached controls, used for internal testing)"
  engine_id    = google_discovery_engine_search_engine.govuk_global.engine_id
}
