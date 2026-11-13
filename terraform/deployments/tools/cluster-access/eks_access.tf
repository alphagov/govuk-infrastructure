module "platformengineer" {
  source = "./modules/access-entry"

  name = "platformengineer"

  cluster_name = local.cluster_name

  aws_iam_role_arns = sort(setunion(
    data.aws_iam_roles.platformengineer.arns,
    data.aws_iam_roles.platformengineer_sso.arns,
  ))
  access_policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_policy_scope = "cluster"

  cluster_role_rules = [
    {
      api_groups = ["*"]
      resources  = ["*"]
      verbs      = ["*"]
    }
  ]
}

module "fulladmin" {
  source = "./modules/access-entry"

  name = "fulladmin"

  cluster_name = local.cluster_name

  aws_iam_role_arns = sort(setunion(
    data.aws_iam_roles.fulladmin.arns,
    data.aws_iam_roles.fulladmin_sso.arns,
  ))
  access_policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_policy_scope = "cluster"

  cluster_role_rules = [
    {
      api_groups = ["*"]
      resources  = ["*"]
      verbs      = ["*"]
    }
  ]
}

module "readonly" {
  source = "./modules/access-entry"

  name = "readonly"

  cluster_name = local.cluster_name

  aws_iam_role_arns = sort(setunion(
    data.aws_iam_roles.readonly.arns,
    data.aws_iam_roles.readonly_sso.arns,
  ))
  access_policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  access_policy_scope = "cluster"

  cluster_role_rules = [
    {
      api_groups = [""]
      resources  = ["namespaces", "pods", "pods/logs", "services", "configmaps", "endpoints", "events"]
      verbs      = ["get", "list", "watch"]
    },
    {
      api_groups = [""]
      resources  = ["secrets"]
      verbs      = ["list"]
    },
    {
      api_groups = ["apps", "batch"]
      resources  = ["deployments", "replicasets", "statefulsets", "jobs", "cronjobs"]
      verbs      = ["get", "list", "watch"]
    },
    {
      api_groups = ["networking.k8s.io"]
      resources  = ["ingresses"]
      verbs      = ["get", "list", "watch"]
    }
  ]

  namespace_role_rules = [
    {
      api_groups = ["platform.publishing.service.gov.uk"]
      resources  = ["jobrequests", "jobrequestreviews"]
      verbs      = ["get", "list", "watch"]
    }
  ]
}

