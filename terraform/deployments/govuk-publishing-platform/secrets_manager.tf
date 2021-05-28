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

# Content store app secrets

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

# Signon app

data "aws_secretsmanager_secret" "signon_devise_pepper" {
  name = "signon_app-DEVISE_PEPPER"
}

data "aws_secretsmanager_secret" "signon_devise_secret_key" {
  name = "signon_app-DEVISE_SECRET_KEY" # pragma: allowlist secret
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

# Router-api app

# Authenticating-proxy app

data "aws_secretsmanager_secret" "authenticating_proxy_jwt_auth_secret" {
  name = "authenticating-proxy_JWT_AUTH_SECRET"
}
