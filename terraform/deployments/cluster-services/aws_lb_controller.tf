# aws_lb_controller.tf manages the in-cluster components of the AWS Load
# Balancer Controller.
#
# The AWS IAM resources for the AWS LB Controller are in
# ../cluster-infrastructure/aws_lb_controller_iam.tf. See
# https://github.com/alphagov/govuk-infrastructure/blob/main/docs/architecture/decisions/0003-split-terraform-state-into-separate-aws-cluster-and-kubernetes-resource-phases.md#decision for rationale.

resource "helm_release" "aws_lb_controller" {
  name             = "aws-load-balancer-controller"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  version          = "1.4.4" # TODO: Dependabot or equivalent so this doesn't get neglected.
  namespace        = local.services_ns
  create_namespace = true
  values = [yamlencode({
    clusterName      = data.terraform_remote_state.cluster_infrastructure.outputs.cluster_id
    defaultSSLPolicy = "ELBSecurityPolicy-TLS13-1-2-2021-06" # TLS 1.3, backward compatible with 1.2
    serviceAccount = {
      name = data.terraform_remote_state.cluster_infrastructure.outputs.aws_lb_controller_service_account_name
      annotations = {
        "eks.amazonaws.com/role-arn" = data.terraform_remote_state.cluster_infrastructure.outputs.aws_lb_controller_role_arn
      }
    }
    replicaCount = var.desired_ha_replicas
  })]
}

resource "helm_release" "aws_lb_ingress_class" {
  name       = "aws-lb-ingress-class"
  repository = "https://alphagov.github.io/govuk-helm-charts/"
  chart      = "ingress-class"
  version    = "0.1.1" # TODO: Dependabot or equivalent so this doesn't get neglected.
}
