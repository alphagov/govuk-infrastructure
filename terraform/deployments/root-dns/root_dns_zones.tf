locals {
  publishing_subdomain = var.govuk_environment == "production" ? "" : "${var.govuk_environment}."
}
resource "aws_route53_zone" "internal_zone" {
  name = "${var.govuk_environment}.govuk-internal.digital."

  vpc {
    vpc_id = data.tfe_outputs.vpc.nonsensitive_values.id
  }
}

resource "aws_route53_zone" "external_zone" {
  name = "${var.govuk_environment}.govuk.digital."
}

resource "aws_route53_zone" "publishing_subdomain" {
  name = "${local.publishing_subdomain}publishing.service.gov.uk"
}

resource "aws_route53_record" "publishing_fastly_acme_challenge" {
  count   = var.govuk_environment == "production" ? 1 : 0
  zone_id = aws_route53_zone.publishing_subdomain.id
  name    = "_acme-challenge.publishing.service.gov.uk."
  type    = "CNAME"
  ttl     = 3600
  records = [data.tfe_outputs.fastly_www[count.index].nonsensitive_values.tls_subscription_acme_challenges["*.publishing.service.gov.uk"][0].record_value]
}
