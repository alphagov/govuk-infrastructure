locals {
  external_dns_service_account_name = "external-dns"
  external_dns_ns                   = "external-dns"
}

module "external_dns_iam_role" {
  source             = "terraform-aws-modules/iam/aws//modules/iam-role"
  version            = "~> 6.0"
  name               = "${var.environment_name}-${local.external_dns_service_account_name}"
  use_name_prefix    = false
  description        = "Role for External DNS addon. Corresponds to ${local.external_dns_service_account_name} k8s ServiceAccount."
  enable_oidc        = true
  oidc_provider_urls = [module.eks.oidc_provider]
  policies = {
    (aws_iam_policy.external_dns.policy_name) = data.tfe_outputs.networking.nonsensitive_values.external_dns_policy_arn
  }
  oidc_subjects = ["system:serviceaccount:${local.external_dns_ns}:${local.external_dns_service_account_name}"]
}

resource "aws_iam_policy" "external_dns" {
  name        = "${var.environment_name}-EKSExternalDNS"
  description = "EKS ${local.external_dns_service_account_name} policy for cluster ${var.environment_name}"
  policy      = data.aws_iam_policy_document.external_dns.json
}


# https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md#iam-policy
data "aws_iam_policy_document" "external_dns" {
  statement {
    effect  = "Allow"
    actions = ["route53:ChangeResourceRecordSets"]
    # TODO: resources = [data.aws_route53_zone.tools_govuk_digital.arn]
    resources = ["arn:aws:route53:::hostedzone/Z06013223IXAZ2MZAWWS6"]
  }
  statement {
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]
    resources = ["*"]
  }
}
