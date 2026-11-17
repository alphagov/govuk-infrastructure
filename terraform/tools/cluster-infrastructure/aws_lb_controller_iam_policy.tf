locals {
  aws_lb_controller_service_account_name = "aws-load-balancer-controller"
  aws_lb_controller_ns                   = "aws-lb-controller"
}

module "aws_lb_controller_iam_role" {
  source             = "terraform-aws-modules/iam/aws//modules/iam-role"
  version            = "~> 6.0"
  name               = "${var.environment_name}-${local.aws_lb_controller_service_account_name}"
  use_name_prefix    = false
  description        = "Role for the AWS Load Balancer Controller. Corresponds to ${local.aws_lb_controller_service_account_name} k8s ServiceAccount."
  enable_oidc        = true
  oidc_provider_urls = [module.eks.oidc_provider]
  policies = {
    aws_iam_policy.aws_lb_controller.name = aws_iam_policy.aws_lb_controller.arn
  }
  oidc_subjects = ["system:serviceaccount:${local.aws_lb_controller_ns}:${local.aws_lb_controller_service_account_name}"]
}


resource "aws_iam_policy" "aws_lb_controller" {
  name        = "${var.environment_name}-AWSLoadBalancerController"
  description = "Allow AWS Load Balancer Controller to manage ALBs/NLBs etc."

  # The policy file should be a verbatim copy of
  # https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/main/docs/install/iam_policy.json
  # which is Apache-licensed:
  # https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/LICENSE
  policy = file("aws_lb_controller_iam_policy.json")
}

