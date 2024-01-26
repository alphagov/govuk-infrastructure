output "google_cloud_discovery_engine_datastore_path" {
  description = "The full path of the datastore created by the module (for data ingestion)"
  value       = module.govuk_content_discovery_engine.datastore_path
}

output "google_cloud_discovery_engine_datastore_branch_path" {
  description = "The full path of the default branch of the datastore created by the module (for data ingestion)"
  value       = module.govuk_content_discovery_engine.datastore_default_branch_path
}

output "google_cloud_discovery_engine_serving_config_path" {
  description = "The full path of the default serving config on the engine created by the module (for querying)"
  value       = module.govuk_content_discovery_engine.serving_config_path
}
