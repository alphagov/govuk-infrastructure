resource "aws_route53_record" "cache" {
  for_each = var.caches

  zone_id = data.tfe_outputs.root-dns.nonsensitive_values.internal_root_zone_id
  name    = each.value.name
  type    = "CNAME"
  ttl     = 300
  records = [aws_elasticache_replication_group.cache[each.key].primary_endpoint_address]
}
