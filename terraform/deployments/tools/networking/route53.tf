locals {
  external_dns_service_account_name = "external-dns"
  external_dns_zone_name            = "tools.govuk.digital"
  # external_dns_ns                   = "external-dns"
}

# module "external_dns_iam_role" {
#   source             = "terraform-aws-modules/iam/aws//modules/iam-role"
#   version            = "~> 6.0"
#   name               = "${local.external_dns_service_account_name}-${var.cluster_name}"
#   use_name_prefix    = false
#   description        = "Role for External DNS addon. Corresponds to ${local.external_dns_service_account_name} k8s ServiceAccount."
#   enable_oidc        = true
#   oidc_provider_urls = [module.eks.oidc_provider]
#   policies = {
#     "${aws_iam_policy.external_dns.name}" = aws_iam_policy.external_dns.arn
#   }
#   oidc_subjects = ["system:serviceaccount:${local.external_dns_ns}:${local.external_dns_service_account_name}"]
# }


resource "aws_iam_policy" "external_dns" {
  name        = "EKSExternalDNS-${var.cluster_name}"
  description = "EKS ${local.external_dns_service_account_name} policy for cluster ${var.cluster_name}"
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
  name          = local.external_dns_zone_name
  force_destroy = var.force_destroy
}


resource "aws_acm_certificate" "cluster_public" {
  domain_name       = "*.${local.external_dns_zone_name}"
  validation_method = "DNS"
  lifecycle { create_before_destroy = true }
  tags = { Name = local.external_dns_zone_name }
}

# See
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation#alternative-domains-dns-validation-with-route-53
resource "aws_route53_record" "cluster_public_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cluster_public.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = aws_route53_zone.cluster_public.id
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_acm_certificate_validation" "cluster_public" {
  certificate_arn = aws_acm_certificate.cluster_public.arn
}
