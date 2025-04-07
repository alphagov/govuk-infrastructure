locals {
  internal_dns_zone_import = {
    integration = "Z15X3KXNVBQPDX"
    staging     = "Z3NWZWKZO6M8LD"
    production  = "Z2Q1IA44B0B7UR"
  }
  external_dns_zone_import = {
    integration = "ZNHYJS6IH772R"
    staging     = "Z2W7W2S1Y9HA8Q"
    production  = "Z23V51RSQPRS0P"
  }
}

import {
  to = aws_route53_zone.internal_zone
  id = local.internal_dns_zone_import[var.govuk_environment]
}

import {
  to = aws_route53_zone.external_zone
  id = local.external_dns_zone_import[var.govuk_environment]
}
