resource "aws_secretsmanager_secret" "secret_key_base" {
  for_each = toset([
    # "authenticating_proxy",
    # "content_store",
    # "draft_content_store", # new
    # "draft_frontend", # new
    # "draft_static",
    # "draft_router_api",
    "frontend",
    # "publisher",
    # "publishing_api",
    # "signon",
    # "static",
    # "router_api",
  ])

  name = "${each.key}-${local.workspace}-SECRET_KEY_BASE"

  # HACK: Fixes a bug where Terraform can't handle secrets scheduled for deletion:
  # https://github.com/hashicorp/terraform-provider-aws/issues/5127
  recovery_window_in_days = 0

  tags = merge(
    local.additional_tags,
    {
      Name = "${each.key}-secret_key_base-${var.govuk_environment}-${local.workspace}"
    },
  )
}

data "aws_secretsmanager_secret" "authenticating_proxy_secret_key_base" {
  name = "authenticating-proxy_SECRET_KEY_BASE" # pragma: allowlist secret
}

data "aws_secretsmanager_secret" "content_store_secret_key_base" {
  name = "content-store_SECRET_KEY_BASE" # pragma: allowlist secret
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
