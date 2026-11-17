resource "aws_route53_zone" "tools_govuk_digital" {
  name = "tools.govuk.digital"
}

resource "aws_acm_certificate" "tools_govuk_digital" {
  domain_name               = "tools.govuk.digital"
  validation_method         = "DNS"
  subject_alternative_names = ["*.tools.govuk.digital"]
}

resource "aws_route53_record" "tools_govuk_digital_validation" {
  for_each = {
    for dvo in aws_acm_certificate.tools_govuk_digital.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true

  zone_id = aws_route53_zone.tools_govuk_digital.zone_id

  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "tools_govuk_digital_validation" {
  certificate_arn = aws_acm_certificate.tools_govuk_digital.arn
  validation_record_fqdns = [for r in aws_route53_record.tools_govuk_digital_validation : r.fqdn]
}