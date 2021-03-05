locals {
  workspace_external_domain = "${terraform.workspace == "default" ? "ecs.${var.external_app_domain}" : "${terraform.workspace}.${var.external_app_domain}"}"
  workspace_internal_domain = "${terraform.workspace == "default" ? "ecs.${var.internal_app_domain}" : "${terraform.workspace}.${var.internal_app_domain}"}"
}



data "aws_route53_zone" "public" {
  name = var.external_app_domain
}

resource "aws_route53_record" "workspace_public_zone_ns" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = local.workspace_external_domain
  type    = "NS"
  ttl     = "30"

  records = aws_route53_zone.workspace_public.name_servers
}

resource "aws_route53_zone" "workspace_public" {
  name  = local.workspace_external_domain
}

resource "aws_route53_zone" "internal_public" {
  name  = local.workspace_internal_domain
}

resource "aws_route53_zone" "internal_private" {
  name  = local.workspace_internal_domain

  vpc {
    vpc_id = data.terraform_remote_state.infra_networking.outputs.vpc_id
  }

}
