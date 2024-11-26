resource "aws_route53_zone" "internal_zone" {
  name = "${var.govuk_environment}.govuk-internal.digital."

  vpc {
    vpc_id = aws_vpc.vpc.id
  }
}

resource "aws_route53_zone" "external_zone" {
  name = "${var.govuk_environment}.govuk.digital."
}
