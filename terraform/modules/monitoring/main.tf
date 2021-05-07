locals {
  additional_tags = {
    chargeable_entity    = "monitoring"
    environment          = var.govuk_environment
    project              = "replatforming"
    repository           = "govuk-infrastructure"
    terraform_deployment = "monitoring"
    terraform_workspace  = var.workspace
  }

  workspace_external_domain = "${var.workspace}.${var.external_app_domain}"
}
