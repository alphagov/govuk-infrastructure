data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "cluster_infrastructure" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    bucket = var.cluster_infrastructure_state_bucket
    key    = "projects/cluster-infrastructure.tfstate"
    region = data.aws_region.current.name
  }
}

# Not got as far as testing this yet but assuming it probably some thing like this
# data "terraform_remote_state" "cluster_infrastructure" {
#   backend = "remote"
#   config = {
#     organization = "govuk"
#     workspaces = {
#       tags = ["cluster-service", "eks", "aws"]
#     }
#   }
# }


# or this 
# data "tfe_outputs" "cluster_infrastructure_integration" {
#   organization = "govuk"
#   workspace = "cluster-infrastructure-integration"
# }
