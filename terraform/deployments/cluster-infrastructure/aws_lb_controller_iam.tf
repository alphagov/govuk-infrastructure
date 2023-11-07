# IAM role and policy to allow the AWS Load Balancer Controller to talk to AWS
# APIs to configure load balancers, read certificates, etc.
#
# The k8s side of the AWS LB Controller is in
# ../cluster-services/aws_lb_controller.tf. See
# https://github.com/alphagov/govuk-infrastructure/blob/main/docs/architecture/decisions/0003-split-terraform-state-into-separate-aws-cluster-and-kubernetes-resource-phases.md#decision for rationale.

locals {
  aws_lb_controller_service_account_name = "aws-load-balancer-controller"
}

module "aws_lb_controller_iam_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 4.0"
  create_role                   = true
  role_name                     = "${local.aws_lb_controller_service_account_name}-${var.cluster_name}"
  role_description              = "Role for the AWS Load Balancer Controller. Corresponds to ${local.aws_lb_controller_service_account_name} k8s ServiceAccount."
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [aws_iam_policy.aws_lb_controller.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.cluster_services_namespace}:${local.aws_lb_controller_service_account_name}"]
}

resource "aws_iam_policy" "aws_lb_controller" {
  name        = "AWSLoadBalancerController-${var.cluster_name}"
  description = "Allow AWS Load Balancer Controller to manage ALBs/NLBs etc."

  # The policy file should be a verbatim copy of
  # https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.6.2/docs/install/iam_policy.json,
  # which is Apache-licensed:
  # https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/LICENSE
  policy = jsonencode(jsondecode(file("${path.module}/aws_lb_controller_iam_policy.json")))
}
