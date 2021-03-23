data "aws_route53_zone" "public" {
  name = var.external_app_domain
}

resource "aws_route53_record" "workspace_public_zone_ns" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = local.workspace_external_domain
  type    = "NS"
  ttl     = "300"

  records = aws_route53_zone.workspace_public.name_servers
}

resource "aws_route53_zone" "workspace_public" {
  name = local.workspace_external_domain
}

resource "aws_route53_zone" "internal_public" {
  name = local.workspace_internal_domain
}

resource "aws_route53_zone" "internal_private" {
  name = local.workspace_internal_domain

  vpc {
    vpc_id = data.terraform_remote_state.infra_networking.outputs.vpc_id
  }

}

resource "aws_acm_certificate" "workspace_public" {
  domain_name = "*.${local.workspace_external_domain}"

  subject_alternative_names = local.is_default_workspace ? ["*.${local.workspace}.${var.publishing_service_domain}"] : null

  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
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
  validation_record_fqdns = [for record in aws_route53_record.workspace_public : record.name]
}
