resource "aws_route53_zone" "internal_zone" {
  name = "${var.govuk_environment}.govuk-internal.digital."

  vpc {
    vpc_id = aws_vpc.vpc.id
  }
}

resource "aws_route53_zone" "external_zone" {
  name = "${var.govuk_environment}.govuk.digital."
}

// Imports (temporary)

data "aws_route53_zone" "internal" {
  name         = "${var.govuk_environment}.govuk-internal.digital."
  private_zone = true
}

data "aws_route53_zone" "external" {
  name = "${var.govuk_environment}.govuk.digital."
}

import {
  to = aws_route53_zone.external_zone
  id = data.aws_route53_zone.external.zone_id
}

import {
  to = aws_route53_zone.internal_zone
  id = data.aws_route53_zone.internal.zone_id
}
