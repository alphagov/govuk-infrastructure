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
  # TODO Change this to local.public_domain once publishing.service domains
  # for backend apps are working.
  signon_api_url  = "https://signon.${local.workspace_external_domain}/api/v1"
  api_user_prefix = local.is_default_workspace ? null : local.workspace
  signon_api_user = {
    content_store       = join("-", compact([local.api_user_prefix, "content-store@${var.publishing_service_domain}"]))
    draft_content_store = join("-", compact([local.api_user_prefix, "draft-content-store@${var.publishing_service_domain}"]))
    frontend            = join("-", compact([local.api_user_prefix, "frontend@${var.publishing_service_domain}"]))
    publisher           = join("-", compact([local.api_user_prefix, "publisher@${var.publishing_service_domain}"]))
    publishing_api      = join("-", compact([local.api_user_prefix, "publishing-api@${var.publishing_service_domain}"]))
  }
}

# TODO: generate all these module instantiations with module for_each
module "publisher_to_publishing_api_bearer_token" {
  source = "../../modules/signon_bearer_token"

  additional_tags                 = local.additional_tags
  api_user_email                  = local.signon_api_user.publisher
  app_name                        = local.signon_app.publishing_api.name
  environment                     = var.govuk_environment
  name                            = "pub_to_pub_api"
  private_subnets                 = local.private_subnets
  signon_admin_password_arn       = aws_secretsmanager_secret.signon_admin_password.arn
  signon_host                     = module.signon.virtual_service_name
  signon_lambda_security_group_id = aws_security_group.signon_lambda.id
  workspace                       = local.workspace
}

module "publishing_api_to_content_store_bearer_token" {
  source = "../../modules/signon_bearer_token"

  additional_tags                 = local.additional_tags
  api_user_email                  = local.signon_api_user.publishing_api
  app_name                        = local.signon_app.content_store.name
  environment                     = var.govuk_environment
  name                            = "pub_api_to_cs"
  private_subnets                 = local.private_subnets
  signon_admin_password_arn       = aws_secretsmanager_secret.signon_admin_password.arn
  signon_host                     = module.signon.virtual_service_name
  signon_lambda_security_group_id = aws_security_group.signon_lambda.id
  workspace                       = local.workspace
}


module "publishing_api_to_draft_content_store_bearer_token" {
  source = "../../modules/signon_bearer_token"

  additional_tags                 = local.additional_tags
  api_user_email                  = local.signon_api_user.publishing_api
  app_name                        = local.signon_app.draft_content_store.name
  environment                     = var.govuk_environment
  name                            = "pub_api_to_dcs"
  private_subnets                 = local.private_subnets
  signon_admin_password_arn       = aws_secretsmanager_secret.signon_admin_password.arn
  signon_host                     = module.signon.virtual_service_name
  signon_lambda_security_group_id = aws_security_group.signon_lambda.id
  workspace                       = local.workspace
}


module "publishing_api_to_router_api_bearer_token" {
  source = "../../modules/signon_bearer_token"

  additional_tags                 = local.additional_tags
  api_user_email                  = local.signon_api_user.publishing_api
  app_name                        = local.signon_app.router_api.name
  environment                     = var.govuk_environment
  name                            = "pub_api_to_router_api"
  private_subnets                 = local.private_subnets
  signon_admin_password_arn       = aws_secretsmanager_secret.signon_admin_password.arn
  signon_host                     = module.signon.virtual_service_name
  signon_lambda_security_group_id = aws_security_group.signon_lambda.id
  workspace                       = local.workspace
}

module "frontend_to_publishing_api_bearer_token" {
  source = "../../modules/signon_bearer_token"

  additional_tags                 = local.additional_tags
  api_user_email                  = local.signon_api_user.frontend
  app_name                        = local.signon_app.publishing_api.name
  environment                     = var.govuk_environment
  name                            = "frontend_to_pub_api"
  private_subnets                 = local.private_subnets
  signon_admin_password_arn       = aws_secretsmanager_secret.signon_admin_password.arn
  signon_host                     = module.signon.virtual_service_name
  signon_lambda_security_group_id = aws_security_group.signon_lambda.id
  workspace                       = local.workspace
}

module "content_store_to_publishing_api_bearer_token" {
  source = "../../modules/signon_bearer_token"

  additional_tags                 = local.additional_tags
  api_user_email                  = local.signon_api_user.content_store
  app_name                        = local.signon_app.publishing_api.name
  environment                     = var.govuk_environment
  name                            = "cs_to_pub_api"
  private_subnets                 = local.private_subnets
  signon_admin_password_arn       = aws_secretsmanager_secret.signon_admin_password.arn
  signon_host                     = module.signon.virtual_service_name
  signon_lambda_security_group_id = aws_security_group.signon_lambda.id
  workspace                       = local.workspace
}

module "draft_content_store_to_publishing_api_bearer_token" {
  source = "../../modules/signon_bearer_token"

  additional_tags                 = local.additional_tags
  api_user_email                  = local.signon_api_user.draft_content_store
  app_name                        = local.signon_app.publishing_api.name
  environment                     = var.govuk_environment
  name                            = "dcs_to_pub_api"
  private_subnets                 = local.private_subnets
  signon_admin_password_arn       = aws_secretsmanager_secret.signon_admin_password.arn
  signon_host                     = module.signon.virtual_service_name
  signon_lambda_security_group_id = aws_security_group.signon_lambda.id
  workspace                       = local.workspace
}

module "content_store_to_router_api_bearer_token" {
  source = "../../modules/signon_bearer_token"

  additional_tags                 = local.additional_tags
  api_user_email                  = local.signon_api_user.content_store
  app_name                        = local.signon_app.router_api.name
  environment                     = var.govuk_environment
  name                            = "cs_to_router_api"
  private_subnets                 = local.private_subnets
  signon_admin_password_arn       = aws_secretsmanager_secret.signon_admin_password.arn
  signon_host                     = module.signon.virtual_service_name
  signon_lambda_security_group_id = aws_security_group.signon_lambda.id
  workspace                       = local.workspace
}

module "draft_content_store_to_draft_router_api_bearer_token" {
  source = "../../modules/signon_bearer_token"

  additional_tags                 = local.additional_tags
  api_user_email                  = local.signon_api_user.draft_content_store
  app_name                        = local.signon_app.draft_router_api.name
  environment                     = var.govuk_environment
  name                            = "dcs_to_draft_router_api"
  private_subnets                 = local.private_subnets
  signon_admin_password_arn       = aws_secretsmanager_secret.signon_admin_password.arn
  signon_host                     = module.signon.virtual_service_name
  signon_lambda_security_group_id = aws_security_group.signon_lambda.id
  workspace                       = local.workspace
}
