resource "aws_secretsmanager_secret" "discovery_engine_configuration" {
  name                    = "govuk/search-api-v2/google-cloud-discovery-engine-configuration"
  recovery_window_in_days = 0 # Force delete to allow re-applying immediately after destroying
}

resource "aws_secretsmanager_secret_version" "discovery_engine_configuration" {
  secret_id = aws_secretsmanager_secret.discovery_engine_configuration.id
  secret_string = jsonencode({
    "GOOGLE_CLOUD_CREDENTIALS"                 = base64decode(google_service_account_key.api.private_key)
    "GOOGLE_CLOUD_PROJECT_ID"                  = var.gcp_project_id
    "DISCOVERY_ENGINE_DEFAULT_COLLECTION_NAME" = local.discovery_engine_default_collection_name
  })
}

resource "aws_secretsmanager_secret" "discovery_engine_configuration_search_admin" {
  name                    = "govuk/search-admin/google-cloud-discovery-engine-configuration"
  recovery_window_in_days = 0 # Force delete to allow re-applying immediately after destroying
}

resource "aws_secretsmanager_secret_version" "discovery_engine_configuration_search_admin" {
  secret_id = aws_secretsmanager_secret.discovery_engine_configuration_search_admin.id
  secret_string = jsonencode({
    "GOOGLE_CLOUD_CREDENTIALS"                 = base64decode(google_service_account_key.search_admin.private_key)
    "DISCOVERY_ENGINE_DEFAULT_COLLECTION_NAME" = local.discovery_engine_default_collection_name
  })
}
