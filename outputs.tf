output "google_cloud_discovery_engine_datastore_path" {
  description = "The full path of the datastore created by the module (for data ingestion)"
  value       = google_discovery_engine_data_store.govuk_content.name
}

output "google_cloud_discovery_engine_datastore_branch_path" {
  description = "The full path of the default branch of the datastore created by the module (for data ingestion)"
  value       = local.discovery_engine_datastore_branch_path
}

output "google_cloud_discovery_engine_serving_config_path" {
  description = "The full path of the default serving config on the engine created by the module (for querying)"
  value       = local.discovery_engine_serving_config_path
}

output "prototype_service_account_key" {
  description = "The key for the prototype service account (to be added to Heroku)"
  value       = base64decode(google_service_account_key.prototype.private_key)
}
