data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket   = var.eks_state_bucket
    key      = "projects/eks.tfstate"
    region   = data.aws_region.current.name
    role_arn = var.assume_role_arn
  }
}

data "terraform_remote_state" "infra_security" {
  backend = "s3"
  config = {
    bucket   = var.govuk_aws_state_bucket
    key      = "govuk/infra-security.tfstate"
    region   = data.aws_region.current.name
    role_arn = var.assume_role_arn
  }
}
