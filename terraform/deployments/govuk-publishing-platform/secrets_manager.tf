# Default secrets

data "aws_secretsmanager_secret" "sentry_dsn" {
  name = "SENTRY_DSN"
}
data "aws_secretsmanager_secret" "ga_universal_id" {
  name = "GA_UNIVERSAL_ID"
}

# Content store app secrets

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

# Publisher app secrets

data "aws_secretsmanager_secret" "publisher_asset_manager_bearer_token" {
  name = "publisher_app-ASSET_MANAGER_BEARER_TOKEN"
}
data "aws_secretsmanager_secret" "publisher_fact_check_password" {
  name = "publisher_app-FACT_CHECK_PASSWORD"
}
data "aws_secretsmanager_secret" "publisher_fact_check_reply_to_address" {
  name = "publisher_app-FACT_CHECK_REPLY_TO_ADDRESS"
}
data "aws_secretsmanager_secret" "publisher_fact_check_reply_to_id" {
  name = "publisher_app-FACT_CHECK_REPLY_TO_ID"
}
data "aws_secretsmanager_secret" "publisher_govuk_notify_api_key" {
  name = "publisher_app-GOVUK_NOTIFY_API_KEY"
}
data "aws_secretsmanager_secret" "publisher_govuk_notify_template_id" {
  name = "publisher_app-GOVUK_NOTIFY_TEMPLATE_ID" # pragma: allowlist secret
}
data "aws_secretsmanager_secret" "publisher_jwt_auth_secret" {
  name = "publisher_app-JWT_AUTH_SECRET"
}
data "aws_secretsmanager_secret" "publisher_link_checker_api_bearer_token" {
  name = "publisher_app-LINK_CHECKER_API_BEARER_TOKEN"
}
data "aws_secretsmanager_secret" "publisher_link_checker_api_secret_token" {
  name = "publisher_app-LINK_CHECKER_API_SECRET_TOKEN"
}
data "aws_secretsmanager_secret" "publisher_mongodb_uri" {
  name = "publisher_app-MONGODB_URI"
}
data "aws_secretsmanager_secret" "publisher_oauth_id" {
  name = "publisher_app-OAUTH_ID"
}
data "aws_secretsmanager_secret" "publisher_oauth_secret" {
  name = "publisher_app-OAUTH_SECRET"
}
data "aws_secretsmanager_secret" "publisher_publishing_api_bearer_token" {
  name = "publisher_app-PUBLISHING_API_BEARER_TOKEN" # pragma: allowlist secret
}
data "aws_secretsmanager_secret" "publisher_secret_key_base" {
  name = "publisher_app-SECRET_KEY_BASE" # pragma: allowlist secret
}

# Signon app

data "aws_secretsmanager_secret" "signon_devise_pepper" {
  name = "signon_app-DEVISE_PEPPER"
}

data "aws_secretsmanager_secret" "signon_devise_secret_key" {
  name = "signon_app-DEVISE_SECRET_KEY" # pragma: allowlist secret
}

data "aws_secretsmanager_secret" "signon_secret_key_base" {
  name = "signon_app-SECRET_KEY_BASE" # pragma: allowlist secret
}

data "aws_secretsmanager_secret" "signon_database_url" {
  name = "signon_app-DATABASE_URL"
}

# Static app

data "aws_secretsmanager_secret" "static_publishing_api_bearer_token" {
  name = "static_PUBLISHING_API_BEARER_TOKEN" # pragma: allowlist secret
}
data "aws_secretsmanager_secret" "static_secret_key_base" {
  name = "static_SECRET_KEY_BASE" # pragma: allowlist secret
}
data "aws_secretsmanager_secret" "draft_static_publishing_api_bearer_token" {
  name = "draft-static_PUBLISHING_API_BEARER_TOKEN" # pragma: allowlist secret
}
data "aws_secretsmanager_secret" "draft_static_secret_key_base" {
  name = "draft-static_SECRET_KEY_BASE" # pragma: allowlist secret
}
