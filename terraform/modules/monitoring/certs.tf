resource "aws_route53_zone" "public" {
  name = local.workspace_external_domain
}

resource "aws_acm_certificate" "public" {
  domain_name = "*.${local.workspace_external_domain}"

  subject_alternative_names = ["*.${var.workspace}.${var.publishing_service_domain}"]

  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
  tags = merge(
    local.additional_tags,
    {
      Name = "${local.workspace_external_domain}-${var.govuk_environment}-${var.workspace}"
    },
  )
}

resource "aws_route53_record" "public" {
  for_each = {
    for dvo in aws_acm_certificate.public.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.public.zone_id
}

resource "aws_acm_certificate_validation" "public" {
  certificate_arn         = aws_acm_certificate.public.arn
  validation_record_fqdns = [for record in aws_route53_record.public : record.name]
}
