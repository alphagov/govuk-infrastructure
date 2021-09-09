# external_dns.tf defines a Route53 zone and an IAM role and policy to allow
# the k8s external-dns addon to manage the zone.
#
# The k8s side of the external-dns addon is in
# ../cluster-services/external_dns.tf.

locals {
  external_dns_service_account_name = "external-dns"
  external_dns_domain_name          = "${var.external_dns_subdomain}.${data.terraform_remote_state.infra_root_dns_zones.outputs.external_root_domain_name}"
}

module "external_dns_iam_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.3.0"
  create_role                   = true
  role_name                     = "${local.external_dns_service_account_name}-${var.cluster_name}"
  role_description              = "Role for External DNS addon. Corresponds to ${local.external_dns_service_account_name} k8s ServiceAccount."
  provider_url                  = local.cluster_oidc_issuer
  role_policy_arns              = [aws_iam_policy.external_dns.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.cluster_services_namespace}:${local.external_dns_service_account_name}"]
}

resource "aws_iam_policy" "external_dns" {
  name        = "EKSExternalDNS-${var.cluster_name}"
  description = "EKS ${local.external_dns_service_account_name} policy for cluster ${module.eks.cluster_id}"
  policy      = data.aws_iam_policy_document.external_dns.json
}

# https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md#iam-policy
data "aws_iam_policy_document" "external_dns" {
  statement {
    effect    = "Allow"
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = [aws_route53_zone.cluster_public.arn]
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

resource "aws_route53_zone" "cluster_public" {
  name          = local.external_dns_domain_name
  force_destroy = var.force_destroy
}

resource "aws_route53_record" "cluster_public_ns" {
  zone_id = data.terraform_remote_state.infra_root_dns_zones.outputs.external_root_zone_id
  name    = var.external_dns_subdomain
  type    = "NS"
  ttl     = 21600
  records = aws_route53_zone.cluster_public.name_servers
}
