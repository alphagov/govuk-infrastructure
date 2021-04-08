resource "fastly_service_v1" "www_service" {
  count = local.is_default_workspace ? 1 : 0
  name  = "www_service_${var.govuk_environment}"

  domain {
    name    = "www1.ecs.${var.publishing_service_domain}" #TODO: replace www1 with www as this is for testing only
    comment = "www CDN entry point for the ${var.govuk_environment} GOV.UK environment"
  }

  force_destroy = true

  vcl {
    name = "www_main_vcl_template"
    content = templatefile("templates/www_vcl_template.tpl",
      { origin_hostname                     = module.www_origin.origin_app_fqdn
        basic_authentication_encoded_secret = contains(["staging", "production"], var.govuk_environment) ? "" : data.aws_secretsmanager_secret_version.cdn_basic_authentication_encoded_secret[0].secret_string,
        allowed_ip_addresses                = [for cidr in concat(var.office_cidrs_list, local.nat_gateway_public_cidrs_list) : cidrhost(cidr, 0)],
        default_ttl                         = var.cdn_cache_default_ttl,
      }
    )
    main = true
  }
}
