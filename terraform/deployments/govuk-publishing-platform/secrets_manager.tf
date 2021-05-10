# Default secrets

data "aws_secretsmanager_secret" "sentry_dsn" {
  name = "SENTRY_DSN"
}
data "aws_secretsmanager_secret" "ga_universal_id" {
  name = "GA_UNIVERSAL_ID"
}
data "aws_secretsmanager_secret" "splunk_url" {
  name = "SPLUNK_HEC_URL"
}
data "aws_secretsmanager_secret" "splunk_token" {
  name = "SPLUNK_TOKEN"
}

# Frontend app secrets

data "aws_secretsmanager_secret" "frontend_secret_key_base" {
  name = "frontend_app-SECRET_KEY_BASE" # pragma: allowlist secret
}

# Content store app secrets

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
data "aws_secretsmanager_secret" "publisher_secret_key_base" {
  name = "publisher_app-SECRET_KEY_BASE" # pragma: allowlist secret
}

# Publishing API app

data "aws_secretsmanager_secret" "publishing_api_database_url" {
  name = "publishing_api_app-DATABASE_URL"
}

data "aws_secretsmanager_secret" "publishing_api_event_log_aws_secret_key" {
  name = "publishing_api_app-EVENT_LOG_AWS_SECRET_KEY"
}

data "aws_secretsmanager_secret" "publishing_api_rabbitmq_password" {
  name = "publishing_api_app-RABBITMQ_PASSWORD"
}

data "aws_secretsmanager_secret" "publishing_api_secret_key_base" {
  name = "publishing_api_app-SECRET_KEY_BASE"
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

# Smokey

data "aws_secretsmanager_secret" "smokey_auth_username" {
  name = "smokey_AUTH_USERNAME"
}

data "aws_secretsmanager_secret" "smokey_auth_password" {
  name = "smokey_AUTH_PASSWORD"
}

data "aws_secretsmanager_secret" "smokey_signon_password" {
  name = "SMOKEY_SIGNON_PASSWORD"
}

# Static app

data "aws_secretsmanager_secret" "static_secret_key_base" {
  name = "static_SECRET_KEY_BASE" # pragma: allowlist secret
}
data "aws_secretsmanager_secret" "draft_static_secret_key_base" {
  name = "draft-static_SECRET_KEY_BASE" # pragma: allowlist secret
}

# Router-api app

data "aws_secretsmanager_secret" "router_api_secret_key_base" {
  name = "router-api_SECRET_KEY_BASE"
}
data "aws_secretsmanager_secret" "draft_router_api_secret_key_base" {
  name = "draft-router-api_SECRET_KEY_BASE"
}

# Authenticating-proxy app

data "aws_secretsmanager_secret" "authenticating_proxy_secret_key_base" {
  name = "authenticating-proxy_SECRET_KEY_BASE"
}
data "aws_secretsmanager_secret" "authenticating_proxy_jwt_auth_secret" {
  name = "authenticating-proxy_JWT_AUTH_SECRET"
}
