# external_dns.tf defines a Route53 zone and an IAM role and policy to allow
# the k8s external-dns addon to manage the zone, plus a wildcard TLS cert which
# covers the external-dns domain and the user-facing
# *.(env.)?publishing.service.gov.uk domain.
#
# The k8s side of the external-dns addon is in
# ../cluster-services/external_dns.tf.

locals {
  external_dns_service_account_name = "external-dns"
  external_dns_ns                   = "external-dns"
}

module "external_dns_iam_role" {
  source             = "terraform-aws-modules/iam/aws//modules/iam-role"
  version            = "~> 6.0"
  name               = "${local.external_dns_service_account_name}-${var.cluster_name}"
  use_name_prefix    = false
  description        = "Role for External DNS addon. Corresponds to ${local.external_dns_service_account_name} k8s ServiceAccount."
  enable_oidc        = true
  oidc_provider_urls = [module.eks.oidc_provider]
  policies = {
    "${aws_iam_policy.external_dns.name}" = aws_iam_policy.external_dns.arn
  }
  oidc_subjects = ["system:serviceaccount:${local.external_dns_ns}:${local.external_dns_service_account_name}"]
}

resource "aws_iam_policy" "external_dns" {
  name        = "EKSExternalDNS-${var.cluster_name}"
  description = "EKS ${local.external_dns_service_account_name} policy for cluster ${module.eks.cluster_name}"
  policy      = data.aws_iam_policy_document.external_dns.json
}

# https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md#iam-policy
data "aws_iam_policy_document" "external_dns" {
  statement {
    effect    = "Allow"
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = [data.tfe_outputs.networking.nonsensitive_values.external_dns_zone_arn]
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
