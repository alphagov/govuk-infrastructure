data "tfe_outputs" "cluster_infrastructure" {
  organization = "govuk"
  workspace    = "cluster-infrastructure-${var.govuk_environment}"
}

data "aws_eks_cluster_auth" "cluster_token" {
  name = var.cluster_name
}
