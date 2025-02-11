data "tfe_oauth_client" "github" {
  organization     = var.organization
  service_provider = "github"
}

data "tfe_workspace_ids" "aws_config" {
  organization = "govuk"
  tag_names    = ["tfc", "aws", "configuration"]
}

data "tfe_outputs" "aws_config" {
  for_each = data.tfe_workspace_ids.aws_config.full_names

  organization = "govuk"
  workspace    = each.key
}
