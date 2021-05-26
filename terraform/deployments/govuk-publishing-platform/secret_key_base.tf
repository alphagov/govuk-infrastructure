data "aws_secretsmanager_secret" "authenticating_proxy_secret_key_base" {
  name = "authenticating-proxy_SECRET_KEY_BASE" # pragma: allowlist secret
}

data "aws_secretsmanager_secret" "content_store_secret_key_base" {
  name = "content-store_SECRET_KEY_BASE" # pragma: allowlist secret
}

data "aws_secretsmanager_secret" "frontend_secret_key_base" {
  name = "frontend_app-SECRET_KEY_BASE" # pragma: allowlist secret
}

data "aws_secretsmanager_secret" "publisher_secret_key_base" {
  name = "publisher_app-SECRET_KEY_BASE" # pragma: allowlist secret
}

data "aws_secretsmanager_secret" "publishing_api_secret_key_base" {
  name = "publishing_api_app-SECRET_KEY_BASE" # pragma: allowlist secret
}

data "aws_secretsmanager_secret" "signon_secret_key_base" {
  name = "signon_app-SECRET_KEY_BASE" # pragma: allowlist secret
}

data "aws_secretsmanager_secret" "static_secret_key_base" {
  name = "static_SECRET_KEY_BASE" # pragma: allowlist secret
}

data "aws_secretsmanager_secret" "draft_static_secret_key_base" {
  name = "draft-static_SECRET_KEY_BASE" # pragma: allowlist secret
}

data "aws_secretsmanager_secret" "router_api_secret_key_base" {
  name = "router-api_SECRET_KEY_BASE" # pragma: allowlist secret
}

data "aws_secretsmanager_secret" "draft_router_api_secret_key_base" {
  name = "draft-router-api_SECRET_KEY_BASE" # pragma: allowlist secret
}
