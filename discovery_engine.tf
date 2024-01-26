# Creates and configures an unstructured datastore for Google Discovery Engine ("Vertex AI Search")
# see https://cloud.google.com/generative-ai-app-builder/docs/reference/rest/

module "govuk_content_discovery_engine" {
  source = "../modules/google_discovery_engine_restapi"

  datastore_id = "govuk_content"
  engine_id    = "govuk"
}

resource "aws_secretsmanager_secret" "discovery_engine_configuration" {
  name                    = "govuk/search-api-v2/google-cloud-discovery-engine-configuration"
  recovery_window_in_days = 0 # Force delete to allow re-applying immediately after destroying
}

resource "aws_secretsmanager_secret_version" "discovery_engine_configuration" {
  secret_id = aws_secretsmanager_secret.discovery_engine_configuration.id
  secret_string = jsonencode({
    "GOOGLE_CLOUD_CREDENTIALS"          = base64decode(google_service_account_key.api.private_key)
    "DISCOVERY_ENGINE_DATASTORE_BRANCH" = module.govuk_content_discovery_engine.datastore_default_branch_path,
    "DISCOVERY_ENGINE_DATASTORE"        = module.govuk_content_discovery_engine.datastore_path,
    "DISCOVERY_ENGINE_SERVING_CONFIG"   = module.govuk_content_discovery_engine.serving_config_path,
  })
}
