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
  source             = "terraform-aws-modules/iam/aws//modules/iam-role"
  version            = "~> 6.0"
  name               = "${local.aws_lb_controller_service_account_name}-${var.cluster_name}"
  use_name_prefix    = false
  description        = "Role for the AWS Load Balancer Controller. Corresponds to ${local.aws_lb_controller_service_account_name} k8s ServiceAccount."
  enable_oidc        = true
  oidc_provider_urls = [module.eks.oidc_provider]
  policies = {
    "${aws_iam_policy.aws_lb_controller.name}" = aws_iam_policy.aws_lb_controller.arn
  }
  oidc_subjects = ["system:serviceaccount:${local.cluster_services_namespace}:${local.aws_lb_controller_service_account_name}"]
}

moved {
  from = module.aws_lb_controller_iam_role.aws_iam_role_policy_attachment.custom[0]
  to   = module.aws_lb_controller_iam_role.aws_iam_role_policy_attachment.this["AWSLoadBalancerController-govuk"]
}

resource "aws_iam_policy" "aws_lb_controller" {
  name        = "AWSLoadBalancerController-${var.cluster_name}"
  description = "Allow AWS Load Balancer Controller to manage ALBs/NLBs etc."

  # The policy file should be a verbatim copy of
  # https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/main/docs/install/iam_policy.json
  # which is Apache-licensed:
  # https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/LICENSE
  policy = file("aws_lb_controller_iam_policy.json")
}
