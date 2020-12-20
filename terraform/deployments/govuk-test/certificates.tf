# TODO: Use ecs as default workspace
# TODO: DNS Delegation from default zone
data "aws_route53_zone" "root_public" {
  # Created in govuk-aws
  name = "${var.govuk_environment}.${var.public_domain}" # test.govuk.digital
}

resource "aws_route53_record" "workspace_public_zone_ns" {
  zone_id = data.aws_route53_zone.root_public.zone_id
  name    = local.public_lb_domain_name
  type    = "NS"
  ttl     = "30"

  records = aws_route53_zone.workspace_public.name_servers
  # [
  #   aws_route53_zone.external_zone.name_servers.0,
  #   aws_route53_zone.external_zone.name_servers.1,
  #   aws_route53_zone.external_zone.name_servers.2,
  #   aws_route53_zone.external_zone.name_servers.3,
  # ]
}

resource "aws_acm_certificate" "workspace_public" {
  domain_name       = "*.${local.public_lb_domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_zone" "workspace_public" {
  name = local.public_lb_domain_name # plouf.test.govuk.digital
}

resource "aws_route53_zone" "internal_public" {
  name = local.internal_domain_name # plouf.test.govuk-internal.digital
}

resource "aws_route53_zone" "internal_private" {
  name = local.internal_domain_name # plouf.test.govuk-internal.digital

  vpc {
    vpc_id = data.terraform_remote_state.infra_networking.outputs.vpc_id
  }

}

resource "aws_route53_record" "workspace_public" {
  for_each = {
    for dvo in aws_acm_certificate.workspace_public.domain_validation_options : dvo.domain_name => {
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
  zone_id         = aws_route53_zone.workspace_public.zone_id
}

resource "aws_acm_certificate_validation" "workspace_public" {
  certificate_arn         = aws_acm_certificate.workspace_public.arn
  validation_record_fqdns = [for record in aws_route53_record.workspace_public : record.fqdn]
}
