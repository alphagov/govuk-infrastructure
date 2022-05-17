resource "aws_route53_record" "www" {
  zone_id = local.external_dns_zone_id
  name    = var.www_dns_name
  type    = "CNAME"
  ttl     = 300
  records = ["www-gov-uk.map.fastly.net."]
}

resource "aws_route53_record" "www_validation" {
  zone_id = local.external_dns_zone_id
  name    = var.www_dns_validation_name
  type    = "CNAME"
  ttl     = 300
  records = [var.www_dns_validation_rdata]
}
