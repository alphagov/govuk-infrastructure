resource "aws_route53_record" "workspace_public_zone_ns" {
  zone_id = data.terraform_remote_state.infra_root_dns_zones.outputs.external_root_zone_id
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

  subject_alternative_names = local.is_default_workspace ? ["*.${var.publishing_service_domain}"] : null

  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
  tags = merge(
    local.additional_tags,
    {
      Name = "${local.workspace_external_domain}-${var.govuk_environment}-${local.workspace}"
    },
  )
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

resource "aws_route53_record" "cdn_certificate_validation" {
  count   = var.enable_cdn && local.is_default_workspace ? 1 : 0
  zone_id = aws_route53_zone.workspace_public.zone_id
  name    = var.cdn_certificate_validation_cname.name
  type    = "CNAME"
  ttl     = 300
  records = [var.cdn_certificate_validation_cname.record]
}

resource "aws_route53_record" "cdn" {
  count   = var.enable_cdn && local.is_default_workspace ? 1 : 0
  zone_id = aws_route53_zone.workspace_public.zone_id
  name    = "www"
  type    = "CNAME"
  ttl     = 300
  records = ["www-gov-uk.map.fastly.net."]
}
