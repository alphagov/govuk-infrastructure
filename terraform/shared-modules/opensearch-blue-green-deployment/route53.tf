locals {
  service_record_name = "${var.opensearch_domain_name}-opensearch.${var.govuk_environment}.govuk-internal.digital"
}

resource "aws_route53_record" "service_record" {
  zone_id = data.tfe_outputs.root_dns.nonsensitive_values.internal_root_zone_id
  name    = local.service_record_name
  type    = "CNAME"
  ttl     = 300
  records = [
    var.current_live_domain == "blue" ? module.blue_domain[0].opensearch_endpoint
    : var.current_live_domain == "green" ? module.green_domain[0].opensearch_endpoint
    : "IMPOSSIBLE_CONDITION"
  ]
}
