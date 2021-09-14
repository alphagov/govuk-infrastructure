# external_dns.tf defines a Route53 zone and an IAM role and policy to allow
# the k8s external-dns addon to manage the zone, plus a wildcard TLS cert which
# covers the external-dns domain and the user-facing
# *.(env.)?publishing.service.gov.uk domain.
#
# The k8s side of the external-dns addon is in
# ../cluster-services/external_dns.tf.

locals {
  external_dns_service_account_name = "external-dns"
  external_dns_zone_name            = trimsuffix("${var.external_dns_subdomain}.${data.terraform_remote_state.infra_root_dns_zones.outputs.external_root_domain_name}", ".")
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
  name          = local.external_dns_zone_name
  force_destroy = var.force_destroy
}

resource "aws_route53_record" "cluster_public_ns_parent" {
  zone_id = data.terraform_remote_state.infra_root_dns_zones.outputs.external_root_zone_id
  name    = var.external_dns_subdomain
  type    = "NS"
  ttl     = 21600
  records = aws_route53_zone.cluster_public.name_servers
}

resource "aws_acm_certificate" "cluster_public" {
  domain_name               = "*.${local.external_dns_zone_name}"
  subject_alternative_names = ["*.${var.publishing_service_domain}"]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = local.external_dns_zone_name
  }
}

# See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation#example-usage
resource "aws_route53_record" "cluster_public_cert_validation" {
  for_each = {
    # TODO: Delegate the non-prod domains to the non-prod AWS accounts so that
    # the validation records for *.(env.)?publishing.service.gov.uk can easily
    # be added here as part of turnup/DR automation. Those records currently
    # exist for the test/integration/staging/prod environments in a single zone
    # managed in alphagov/govuk-dns-config.
    for dvo in aws_acm_certificate.cluster_public.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
    if length(regexall("${local.external_dns_zone_name}\\.$", dvo.resource_record_name)) > 0
    # i.e. if dvo.resource_record_name.endswith(local.external_dns_zone_name + ".")
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = aws_route53_zone.cluster_public.id
}

resource "aws_acm_certificate_validation" "cluster_public" {
  certificate_arn = aws_acm_certificate.cluster_public.arn
}
