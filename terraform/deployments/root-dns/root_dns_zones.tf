resource "aws_route53_zone" "internal_zone" {
  name = "${var.govuk_environment}.govuk-internal.digital."

  vpc {
    vpc_id = data.tfe_outputs.vpc.nonsensitive_values.id
  }
}

resource "aws_route53_zone" "external_zone" {
  name = "${var.govuk_environment}.govuk.digital."
}
