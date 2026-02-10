module "tetragon" {
  count = var.enable_tetragon ? 1 : 0

  source            = "./modules/tetragon/"
  govuk_environment = var.govuk_environment
  provider_arn      = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_oidc_provider_arn
  cluster_id        = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_id
  account_id        = data.aws_caller_identity.current.account_id
}

