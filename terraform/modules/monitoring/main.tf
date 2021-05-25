locals {
  additional_tags = {
    chargeable_entity    = "monitoring"
    environment          = var.govuk_environment
    project              = "replatforming"
    repository           = "govuk-infrastructure"
    terraform_deployment = "monitoring"
    terraform_workspace  = var.workspace
  }

  monitoring_external_domain = "monitoring.${var.external_app_domain}"
}

data "aws_caller_identity" "current" {}
