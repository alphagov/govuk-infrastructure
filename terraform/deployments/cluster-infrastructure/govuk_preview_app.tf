# A dedicated wildcard ACM cert for every ephemeral preview's own hostname
# (<preview-slug>.govuk-preview-app.<domain>) - the shared cert in
# external_dns.tf only covers one level of wildcard (<app>.<domain>), not
# this second, deeper one. Without it, the AWS Load Balancer Controller
# can't build govuk-preview-app's Ingress at all: "no certificate found
# for host: *.govuk-preview-app.eks.integration.govuk.digital" (see
# alphagov/govuk-helm-charts#4550, which removed the wildcard host
# pending this).
#
# DNS-validated against the same zone external_dns.tf already owns and
# validates against (aws_route53_zone.cluster_public) - this only covers
# the eks.<env>.govuk.digital form. There's no equivalent SAN for
# (env.)?publishing.service.gov.uk here: that zone lives outside this
# Terraform (see external_dns.tf's own TODO on cluster_public's SAN for
# that domain), so validating a SAN there would need a manual record in
# alphagov/govuk-dns-config or govuk-dns-tf - deliberately not attempted
# here. That's fine for what this cert is actually for: the ALB only
# needs this eks-domain form to build the Ingress model and terminate TLS
# for it at all - the host-header routing rule that sends real preview
# traffic (reached via the publishing domain) to the right place doesn't
# depend on this cert covering that domain too.
resource "aws_acm_certificate" "govuk_preview_app_wildcard" {
  count = var.enable_govuk_preview_app_wildcard_cert ? 1 : 0

  domain_name       = "*.govuk-preview-app.${local.external_dns_zone_name}"
  validation_method = "DNS"
  lifecycle { create_before_destroy = true }
  tags = { Name = "govuk-preview-app-wildcard" }
}

resource "aws_route53_record" "govuk_preview_app_wildcard_cert_validation" {
  for_each = var.enable_govuk_preview_app_wildcard_cert ? {
    for dvo in aws_acm_certificate.govuk_preview_app_wildcard[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = aws_route53_zone.cluster_public.id
}

resource "aws_acm_certificate_validation" "govuk_preview_app_wildcard" {
  count = var.enable_govuk_preview_app_wildcard_cert ? 1 : 0

  certificate_arn         = aws_acm_certificate.govuk_preview_app_wildcard[0].arn
  validation_record_fqdns = [for r in aws_route53_record.govuk_preview_app_wildcard_cert_validation : r.fqdn]
}
