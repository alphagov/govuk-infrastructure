output "google_cloud_discovery_engine_datastore_path" {
  description = "The full path of the datastore created by the module (for data ingestion)"
  value       = google_discovery_engine_data_store.govuk_content.name
}

output "google_cloud_discovery_engine_default_collection_name" {
  description = "The fully qualified name of the default collection on the GCP project"
  value       = local.discovery_engine_default_collection_name
}
