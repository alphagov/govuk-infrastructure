data "aws_secretsmanager_secret" "content_store_oauth_id" {
  name = "content-store_OAUTH_ID"
}
data "aws_secretsmanager_secret" "content_store_oauth_secret" {
  name = "content-store_OAUTH_SECRET"
}
data "aws_secretsmanager_secret" "content_store_publishing_api_bearer_token" {
  name = "content-store_PUBLISHING_API_BEARER_TOKEN" # pragma: allowlist secret
}
data "aws_secretsmanager_secret" "content_store_router_api_bearer_token" {
  name = "content-store_ROUTER_API_BEARER_TOKEN" # pragma: allowlist secret
}
data "aws_secretsmanager_secret" "content_store_secret_key_base" {
  name = "content-store_SECRET_KEY_BASE" # pragma: allowlist secret
}
data "aws_secretsmanager_secret" "sentry_dsn" {
  name = "SENTRY_DSN"
}
