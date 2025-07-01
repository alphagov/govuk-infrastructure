data "aws_route53_zone" "publishing_subdomain" {
  zone_id = data.tfe_outputs.root_dns.nonsensitive_values.publishing_subdomain_zone_id
}

resource "aws_route53_record" "additional_dns_records" {
  # this could be a simple foreach, but Terraform would think the order matters then
  # instead transform the list into a name => object pair so that each resource has
  # a stable name
  for_each = { for _, v in var.subdomain_dns_records : v.name => v }

  zone_id = data.aws_route53_zone.publishing_subdomain.zone_id
  name = (
    each.value.name == "@" ?
    data.aws_route53_zone.publishing_subdomain.name
    : "${each.value.name}.${data.aws_route53_zone.publishing_subdomain.name}"
  )
  type    = each.value.type
  records = each.value.value
  ttl     = each.value.ttl
}

resource "aws_route53_record" "subdomain_delegation" {
  for_each = var.subdomain_delegation_name_servers

  zone_id = data.aws_route53_zone.publishing_subdomain.zone_id
  name    = "${each.key}.${data.aws_route53_zone.publishing_subdomain.name}"
  type    = "NS"
  records = each.value
  ttl     = 86400
}
