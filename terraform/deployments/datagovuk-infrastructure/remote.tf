data "aws_region" "current" {}

data "terraform_remote_state" "cluster_infrastructure" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    bucket = var.cluster_infrastructure_state_bucket
    key    = "projects/cluster-infrastructure.tfstate"
    region = data.aws_region.current.name
  }
}
