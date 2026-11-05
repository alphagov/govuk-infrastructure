data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "tfe_outputs" "cluster_infrastructure" {
  organization = "govuk"
  workspace    = "tools-cluster-infrastructure"
}

data "aws_iam_roles" "fulladmin" {
  name_regex = "\\..*-fulladmin$"
}

data "aws_iam_roles" "fulladmin_sso" {
  name_regex = "^AWSReservedSSO_ApprovedAdmin_[0-9a-f]+$"
}

data "aws_iam_roles" "platformengineer" {
  name_regex = "\\..*platformengineer$"
}

data "aws_iam_roles" "platformengineer_sso" {
  name_regex = "^AWSReservedSSO_GovUkPlatformEngineerPermission_[0-9a-f]+$"
}

data "aws_iam_roles" "readonly" {
  name_regex = "\\..*readonly$"
}

data "aws_iam_roles" "readonly_sso" {
  name_regex = "^AWSReservedSSO_ReadOnlyAccessPermission_[0-9a-f]+$"
}

data "aws_eks_cluster_auth" "cluster_token" {
  name = var.cluster_name
}
