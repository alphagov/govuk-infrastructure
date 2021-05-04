resource "aws_secretsmanager_secret" "signon_admin_password" {
  name                    = "signon_admin_password_${local.workspace}" # pragma: allowlist secret
  recovery_window_in_days = 0
}

# TODO: Replace the random_password approach with an autogenerate_secret module
# that runs a rotation lambda to createSecret.
resource "aws_secretsmanager_secret_version" "example" {
  secret_id     = aws_secretsmanager_secret.signon_admin_password.id
  secret_string = random_password.signon_admin_password.result
}

resource "random_password" "signon_admin_password" {
  length  = 64
  special = true
}

#
# Signon bearer tokens
#

locals {
  signon_host = "signon.${local.workspace}.${var.govuk_environment}.govuk.digital"

  api_user_prefix = terraform.workspace == "default" ? null : local.workspace
  signon_app = {
    content_store       = "Content Store"
    draft_content_store = "Draft Content Store"
    frontend            = "Frontend"
    publisher           = "Publisher"
    publishing_api      = "Publishing API"
    router_api          = "Router API"
  }
  signon_api_user = {
    content_store       = join("-", compact([local.api_user_prefix, "content-store@alphagov.co.uk"]))
    draft_content_store = join("-", compact([local.api_user_prefix, "draft-content-store@alphagov.co.uk"]))
    frontend            = join("-", compact([local.api_user_prefix, "frontend@alphagov.co.uk"]))
    publisher           = join("-", compact([local.api_user_prefix, "publisher@alphagov.co.uk"]))
    publishing_api      = join("-", compact([local.api_user_prefix, "publishing-api@alphagov.co.uk"]))
  }
}

module "publisher_to_publishing_api_bearer_token" {
  source = "../../modules/signon_bearer_token"

  api_user_email            = local.signon_api_user.publisher
  app_name                  = local.signon_app.publishing_api
  name                      = "pub_to_pub_api"
  signon_admin_password_arn = aws_secretsmanager_secret.signon_admin_password.arn
  signon_host               = local.signon_host
  workspace                 = local.workspace
  additional_tags           = local.additional_tags
  environment               = var.govuk_environment
}

module "publishing_api_to_content_store_bearer_token" {
  source = "../../modules/signon_bearer_token"

  api_user_email            = local.signon_api_user.publishing_api
  app_name                  = local.signon_app.content_store
  name                      = "pub_api_to_cs"
  signon_admin_password_arn = aws_secretsmanager_secret.signon_admin_password.arn
  signon_host               = local.signon_host
  workspace                 = local.workspace
  additional_tags           = local.additional_tags
  environment               = var.govuk_environment
}


module "publishing_api_to_draft_content_store_bearer_token" {
  source = "../../modules/signon_bearer_token"

  api_user_email            = local.signon_api_user.publishing_api
  app_name                  = local.signon_app.draft_content_store
  name                      = "pub_api_to_dcs"
  signon_admin_password_arn = aws_secretsmanager_secret.signon_admin_password.arn
  signon_host               = local.signon_host
  workspace                 = local.workspace
  additional_tags           = local.additional_tags
  environment               = var.govuk_environment
}


module "publishing_api_to_router_api_bearer_token" {
  source = "../../modules/signon_bearer_token"

  api_user_email            = local.signon_api_user.publishing_api
  app_name                  = local.signon_app.router_api
  name                      = "pub_api_to_router_api"
  signon_admin_password_arn = aws_secretsmanager_secret.signon_admin_password.arn
  signon_host               = local.signon_host
  workspace                 = local.workspace
  additional_tags           = local.additional_tags
  environment               = var.govuk_environment
}

module "frontend_to_publishing_api_bearer_token" {
  source = "../../modules/signon_bearer_token"

  api_user_email            = local.signon_api_user.frontend
  app_name                  = local.signon_app.publishing_api
  name                      = "frontend_to_pub_api"
  signon_admin_password_arn = aws_secretsmanager_secret.signon_admin_password.arn
  signon_host               = local.signon_host
  workspace                 = local.workspace
  additional_tags           = local.additional_tags
  environment               = var.govuk_environment
}

module "content_store_to_publishing_api_bearer_token" {
  source = "../../modules/signon_bearer_token"

  api_user_email            = local.signon_api_user.content_store
  app_name                  = local.signon_app.publishing_api
  name                      = "cs_to_pub_api"
  signon_admin_password_arn = aws_secretsmanager_secret.signon_admin_password.arn
  signon_host               = local.signon_host
  workspace                 = local.workspace
  additional_tags           = local.additional_tags
  environment               = var.govuk_environment
}

module "draft_content_store_to_publishing_api_bearer_token" {
  source = "../../modules/signon_bearer_token"

  api_user_email            = local.signon_api_user.draft_content_store
  app_name                  = local.signon_app.publishing_api
  name                      = "dcs_to_pub_api"
  signon_admin_password_arn = aws_secretsmanager_secret.signon_admin_password.arn
  signon_host               = local.signon_host
  workspace                 = local.workspace
  additional_tags           = local.additional_tags
  environment               = var.govuk_environment
}

module "content_store_to_router_api_bearer_token" {
  source = "../../modules/signon_bearer_token"

  api_user_email            = local.signon_api_user.content_store
  app_name                  = local.signon_app.router_api
  name                      = "cs_to_router_api"
  signon_admin_password_arn = aws_secretsmanager_secret.signon_admin_password.arn
  signon_host               = local.signon_host
  workspace                 = local.workspace
  additional_tags           = local.additional_tags
  environment               = var.govuk_environment
}

module "draft_content_store_to_router_api_bearer_token" {
  source = "../../modules/signon_bearer_token"

  api_user_email            = local.signon_api_user.draft_content_store
  app_name                  = local.signon_app.router_api
  name                      = "dcs_to_router_api"
  signon_admin_password_arn = aws_secretsmanager_secret.signon_admin_password.arn
  signon_host               = local.signon_host
  workspace                 = local.workspace
  additional_tags           = local.additional_tags
  environment               = var.govuk_environment
}
