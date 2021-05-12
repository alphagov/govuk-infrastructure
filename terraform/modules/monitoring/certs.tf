data "aws_route53_zone" "public" {
  name = var.external_app_domain
}

resource "aws_route53_record" "monitoring_public_zone_ns" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = local.monitoring_external_domain
  type    = "NS"
  ttl     = "300"

  records = aws_route53_zone.monitoring_public.name_servers
}


resource "aws_route53_zone" "monitoring_public" {
  name = local.monitoring_external_domain
}

resource "aws_acm_certificate" "monitoring_public" {
  domain_name = "*.${local.monitoring_external_domain}"

  subject_alternative_names = ["*.${var.workspace}.${var.publishing_service_domain}"]

  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
  tags = merge(
    local.additional_tags,
    {
      Name = "${local.monitoring_external_domain}-${var.govuk_environment}-${var.workspace}"
    },
  )
}

resource "aws_route53_record" "monitoring_public" {
  for_each = {
    for dvo in aws_acm_certificate.monitoring_public.domain_validation_options : dvo.domain_name => {
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
  zone_id         = aws_route53_zone.monitoring_public.zone_id
}

resource "aws_acm_certificate_validation" "monitoring_public" {
  certificate_arn         = aws_acm_certificate.monitoring_public.arn
  validation_record_fqdns = [for record in aws_route53_record.monitoring_public : record.name]
}
