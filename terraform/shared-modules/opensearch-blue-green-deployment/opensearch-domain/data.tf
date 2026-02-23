data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_acm_certificate" "govuk_internal" {
  domain   = "*.${var.govuk_environment}.govuk-internal.digital"
  statuses = ["ISSUED"]
}
