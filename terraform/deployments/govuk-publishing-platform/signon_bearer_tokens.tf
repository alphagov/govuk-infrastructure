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
    content_store = {
      app_name = "content-store"
      email    = join("-", compact([local.api_user_prefix, "content-store@${var.publishing_service_domain}"]))
    }
    draft_content_store = {
      app_name = "draft-content-store"
      email    = join("-", compact([local.api_user_prefix, "draft-content-store@${var.publishing_service_domain}"]))
    }
    frontend = {
      app_name = "frontend"
      email    = join("-", compact([local.api_user_prefix, "frontend@${var.publishing_service_domain}"]))
    }
    publisher = {
      app_name = "publisher"
      email    = join("-", compact([local.api_user_prefix, "publisher@${var.publishing_service_domain}"]))
    }
    publishing_api = {
      app_name = "publishing-api"
      email    = join("-", compact([local.api_user_prefix, "publishing-api@${var.publishing_service_domain}"]))
    }
  }

  signon_bearer_tokens = {
    cs_to_pub_api = {
      api_user   = local.signon_api_user.content_store.email
      app        = local.signon_app.publishing_api.name
      client_app = local.signon_api_user.content_store.app_name
    }

    cs_to_router_api = {
      api_user   = local.signon_api_user.content_store.email
      app        = local.signon_app.router_api.name
      client_app = local.signon_api_user.content_store.app_name
    }

    dcs_to_pub_api = {
      api_user   = local.signon_api_user.draft_content_store.email
      app        = local.signon_app.publishing_api.name
      client_app = local.signon_api_user.draft_content_store.app_name
    }

    dcs_to_draft_router_api = {
      api_user   = local.signon_api_user.draft_content_store.email
      app        = local.signon_app.draft_router_api.name
      client_app = local.signon_api_user.draft_content_store.app_name
    }

    pub_to_pub_api = {
      api_user   = local.signon_api_user.publisher.email
      app        = local.signon_app.publishing_api.name
      client_app = local.signon_api_user.publisher.app_name
    }

    pub_api_to_cs = {
      api_user   = local.signon_api_user.publishing_api.email
      app        = local.signon_app.content_store.name
      client_app = local.signon_api_user.publishing_api.app_name
    }

    pub_api_to_dcs = {
      api_user   = local.signon_api_user.publishing_api.email
      app        = local.signon_app.draft_content_store.name
      client_app = local.signon_api_user.publishing_api.app_name
    }

    pub_api_to_router_api = {
      api_user   = local.signon_api_user.publishing_api.email
      app        = local.signon_app.router_api.name
      client_app = local.signon_api_user.publishing_api.app_name
    }

    frontend_to_pub_api = {
      api_user   = local.signon_api_user.frontend.email
      app        = local.signon_app.publishing_api.name
      client_app = local.signon_api_user.frontend.app_name
    }
  }

  generated_bearer_tokens = {
    for user, user_data in local.signon_api_user :
    user => [
      for k, v in local.signon_bearer_tokens : module.signon_bearer_tokens[k].token_data
      if v.api_user == user_data.email
    ]
  }
}

module "signon_bearer_tokens" {
  for_each = local.signon_bearer_tokens
  source   = "../../modules/signon_bearer_token"

  additional_tags                 = local.additional_tags
  api_user_email                  = each.value.api_user
  app_name                        = each.value.app
  client_app                      = each.value.client_app
  name                            = each.key
  deploy_event_bucket_arn         = aws_s3_bucket.deploy_event_bucket.arn
  deploy_event_bucket_name        = aws_s3_bucket.deploy_event_bucket.id
  environment                     = var.govuk_environment
  private_subnets                 = local.private_subnets
  providers                       = { aws = aws, archive = archive }
  signon_admin_password_arn       = aws_secretsmanager_secret.signon_admin_password.arn
  signon_host                     = module.signon.virtual_service_name
  signon_lambda_security_group_id = aws_security_group.signon_lambda.id
  workspace                       = local.workspace
}
