locals {
  publishing_subdomain = var.govuk_environment == "production" ? "" : "${var.govuk_environment}."
}
resource "aws_route53_zone" "internal_zone" {
  name = "${var.govuk_environment}.govuk-internal.digital."

  vpc {
    vpc_id = data.terraform_remote_state.vpc.outputs.id
  }
}

resource "aws_route53_zone" "external_zone" {
  name = "${var.govuk_environment}.govuk.digital."
}

resource "aws_route53_zone" "publishing_subdomain" {
  name = "${local.publishing_subdomain}publishing.service.gov.uk"
}
