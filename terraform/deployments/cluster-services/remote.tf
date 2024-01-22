data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "cluster_infrastructure" {
  backend   = "remote"
  workspace = terraform.workspace
  config = {
    organization = "govuk"
    workspaces = {
      name = "cluster-infrastructure-${var.govuk_environment}"
    }
  }
}
