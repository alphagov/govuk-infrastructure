resource "helm_release" "aws_vpc_cni" {
  name = "aws-vps-cni"

  chart      = "aws-vpc-cni"
  repository = "https://aws.github.io/eks-charts"
  version    = "v1.21.1"

  namespace        = "kube-system"
  create_namespace = false

  timeout = var.helm_timeout_seconds

  values = [yamlencode({
    enableNetworkPolicy = true
    serviceAccount = {
      name   = "aws-vpc-cni-sa"
      create = true
      annotations = {
        "eks.amazonaws.com/role-arn" = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.aws_vpc_cni_role_arn
      }
    }
  })]
}
