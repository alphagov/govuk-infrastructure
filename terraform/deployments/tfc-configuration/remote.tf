data "tfe_oauth_client" "github" {
  organization     = var.organization
  service_provider = "github"
}

data "tfe_workspace_ids" "aws_config" {
  organization = "govuk"
  names        = ["tfc-aws-config-*"]
}

data "tfe_outputs" "aws_config" {
  for_each = data.tfe_workspace_ids.aws_config.full_names

  organization = "govuk"
  workspace    = each.key
}

locals {
  aws_credentials = { for k, v in data.tfe_outputs.aws_config : trimprefix(k, "tfc-aws-config-") => lookup(v.nonsensitive_values, "aws_credentials_id", null) }
  gcp_credentials = { for k, v in data.tfe_outputs.aws_config : trimprefix(k, "tfc-aws-config-") => lookup(v.nonsensitive_values, "gcp_credentials_id", null) }
}
