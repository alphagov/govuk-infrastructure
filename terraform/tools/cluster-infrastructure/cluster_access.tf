data "aws_iam_roles" "platform_engineer" {
  name_regex = "AWSReservedSSO_GovUkPlatformEngineerPermission.*"
}

data "aws_iam_roles" "readonly" {
  name_regex = "AWSReservedSSO_ReadOnlyPermission.*"
}

module "access_entry_cluster_creator" {
  source       = "../../shared-modules/kubernetes-access-entry"
  name         = "terraform"
  cluster_name = module.eks.cluster_name

  access_policy_scope = "cluster"
  access_policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
}

module "access_entry_platform_engineer" {
  source = "../../shared-modules/kubernetes-access-entry"

  name         = "platformengineer"
  cluster_name = module.eks.cluster_name

  aws_iam_role_arns = data.aws_iam_roles.platform_engineer.arns

  access_policy_scope = "cluster"
  access_policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  cluster_role_rules = [
    {
      api_groups = ["*"]
      resources  = ["*"]
      verbs      = ["*"]
    }
  ]
}

module "access_entry_readonly" {
  source = "../../shared-modules/kubernetes-access-entry"

  name         = "readonly"
  cluster_name = module.eks.cluster_name

  aws_iam_role_arns = data.aws_iam_roles.readonly.arns

  # The Concourse cluster should only ever be accessed directly by Platform Engineering
  # team members, so the admin view policy is more appropriate than the regular
  # view policy
  access_policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminViewPolicy"
  access_policy_scope = "cluster"
}
