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
  signon_api_user = {
    publisher = join("-", compact([local.api_user_prefix, "publisher@alphagov.co.uk"]))
  }
}

module "publisher_to_publishing_api_bearer_token" {
  source = "../../modules/signon_bearer_token"

  api_user_email            = local.signon_api_user.publisher
  app_name                  = "Publishing API" # TODO: Replace with Application.ID
  from_app                  = "publisher"
  signon_admin_password_arn = aws_secretsmanager_secret.signon_admin_password.arn
  signon_host               = local.signon_host
  to_app                    = "publishing-api"
  workspace                 = local.workspace
}
