subdomain_delegation_name_servers = {
  "integration" = [
    "ns-1575.awsdns-04.co.uk.",
    "ns-534.awsdns-02.net.",
    "ns-1077.awsdns-06.org.",
    "ns-11.awsdns-01.com.",
  ]
  "staging" = [
    "ns-821.awsdns-38.net.",
    "ns-114.awsdns-14.com.",
    "ns-1516.awsdns-61.org.",
    "ns-1898.awsdns-45.co.uk.",
  ]
}
subdomain_dns_records = [
  { type = "TXT", name = "@", ttl = 3600, value = ["globalsign-domain-verification=INYQnRXIQfznLaHejAi-z4ZPb6W3Ez3H7BMdhfeAXx", "google-site-verification=M5Q0yBeU28XdlP78DtIzUcc6m63GXzYS4Rrkf2Ab7Ng", "v=spf1 -all"] }, // pragma: allowlist secret
  { type = "TXT", name = "_dmarc", ttl = 3600, value = ["v=DMARC1;p=reject;fo=1;rua=mailto:dmarc-rua@dmarc.service.gov.uk;ruf=mailto:dmarc-ruf@dmarc.service.gov.uk"] },
  { type = "TXT", name = "_asvdns-b7cd4a67-98f4-4056-b75b-eb5f94223809", ttl = 3600, value = ["asvdns_a9d18704-67b6-4da8-af63-32465b1754ca"] },
  { type = "CNAME", name = "_28fd670cd9a9d10a4a6cfca6a309db7a", ttl = 10800, value = ["_efcd9da28f32bcef6e8be5e96ce66eab.kirrbxfjtw.acm-validations.aws."] },
  { type = "CNAME", name = "_41a1880a12e2265d29ece89c0e163b94.test", ttl = 300, value = ["_cbace80e22b28b08c9b1253991dc3198.zjfbrrwmzc.acm-validations.aws."] },
  { type = "CNAME", name = "_ae8b61c8a7382b325c17a8468ef3cb06.ckan", ttl = 300, value = ["_42557f53f60fe3529e3d4e0115756709.wsbhgzrqgq.acm-validations.aws."] },
  { type = "TXT", name = "_amazonses.travel-advice-publisher.alert", ttl = 3600, value = ["xRTTDO1uA0uuOHkKxaQH31n3uEI9QAEcjB/W54pOQ8U="] }, // pragma: allowlist secret
  { type = "CNAME", name = "_d58bf0ccfcf9b41fc9de0fedb51f0b9f.test", ttl = 10800, value = ["54e7aeeb59217b6185e3e1c3c9ffb428.fae5aab90a1fe75618dd4f802fe882d6.4f2663dcc42d6c774673.comodoca.com."] },
  { type = "CNAME", name = "account-api", ttl = 300, value = ["account-api.eks.production.govuk.digital."] },
  { type = "CNAME", name = "app", ttl = 3600, value = ["www-gov-uk.map.fastly.net."] },
  { type = "CNAME", name = "assets", ttl = 300, value = ["www-gov-uk.map.fastly.net."] },
  { type = "CNAME", name = "assets-origin", ttl = 300, value = ["assets-origin.eks.production.govuk.digital."] },
  { type = "CNAME", name = "bouncer", ttl = 3600, value = ["bouncer.eks.production.govuk.digital."] },
  { type = "CNAME", name = "chat", ttl = 300, value = ["chat.eks.production.govuk.digital."] },
  { type = "CNAME", name = "ckan", ttl = 300, value = ["ckan.eks.production.govuk.digital."] },
  { type = "CNAME", name = "collections-publisher", ttl = 3600, value = ["collections-publisher.eks.production.govuk.digital."] },
  { type = "CNAME", name = "content-api", ttl = 300, value = ["alphagov.github.io."] },
  { type = "CNAME", name = "content-block-manager", ttl = 3600, value = ["content-block-manager.eks.production.govuk.digital."] },
  { type = "CNAME", name = "content-data", ttl = 300, value = ["content-data.eks.production.govuk.digital."] },
  { type = "CNAME", name = "content-data-admin", ttl = 300, value = ["content-data.eks.production.govuk.digital."] },
  { type = "CNAME", name = "content-data-api", ttl = 300, value = ["content-data-api.eks.production.govuk.digital."] },
  { type = "CNAME", name = "content-tagger", ttl = 3600, value = ["content-tagger.eks.production.govuk.digital."] },
  { type = "CNAME", name = "csp-reporter", ttl = 3600, value = ["csp-reporter.production.govuk.digital."] },
  { type = "CNAME", name = "draft-assets", ttl = 3600, value = ["draft-assets.eks.production.govuk.digital."] },
  { type = "CNAME", name = "draft-origin", ttl = 300, value = ["draft-origin.eks.production.govuk.digital."] },
  { type = "CNAME", name = "email-alert-api-public", ttl = 3600, value = ["email-alert-api.eks.production.govuk.digital."] },
  { type = "CNAME", name = "govspeak-preview", ttl = 3600, value = ["govspeak-preview.eks.production.govuk.digital."] },
  { type = "CNAME", name = "govuk-kubernetes-cluster-user-docs", ttl = 3600, value = ["bouncer-cdn.production.govuk.service.gov.uk."] },
  { type = "TXT", name = "_fastly.govuk-kubernetes-cluster-user-docs", ttl = 3600, value = ["fastly-domain-delegation-qWiNqNqmqXcaseJh-2023-09-28"] },
  { type = "CNAME", name = "docs", ttl = 3600, value = ["alphagov.github.io."] },
  { type = "TXT", name = "_github-pages-challenge-alphagov.docs", ttl = 3600, value = ["2c1424b07edc15b8c5f9f63218d4ac"] }, // pragma: allowlist secret
  { type = "CNAME", name = "hmrc-manuals-api", ttl = 300, value = ["hmrc-manuals-api.eks.production.govuk.digital."] },
  { type = "CNAME", name = "licensify", ttl = 3600, value = ["licensify.eks.production.govuk.digital."] },
  { type = "CNAME", name = "licensify-admin", ttl = 300, value = ["licensify-admin.eks.production.govuk.digital."] },
  { type = "CNAME", name = "local-links-manager", ttl = 3600, value = ["local-links-manager.eks.production.govuk.digital."] },
  { type = "CNAME", name = "manuals-publisher", ttl = 3600, value = ["manuals-publisher.eks.production.govuk.digital."] },
  { type = "CNAME", name = "places-manager", ttl = 3600, value = ["places-manager.eks.production.govuk.digital."] },
  { type = "CNAME", name = "publisher", ttl = 3600, value = ["publisher.eks.production.govuk.digital."] },
  { type = "CNAME", name = "release", ttl = 3600, value = ["release.eks.production.govuk.digital."] },
  { type = "CNAME", name = "search", ttl = 3600, value = ["6nu88wrill.execute-api.eu-west-1.amazonaws.com."] },
  { type = "CNAME", name = "search-admin", ttl = 300, value = ["search-admin.eks.production.govuk.digital."] },
  { type = "CNAME", name = "service-manual-publisher", ttl = 3600, value = ["service-manual-publisher.eks.production.govuk.digital."] },
  { type = "CNAME", name = "short-url-manager", ttl = 3600, value = ["short-url-manager.eks.production.govuk.digital."] },
  { type = "CNAME", name = "signon", ttl = 300, value = ["signon.eks.production.govuk.digital."] },
  { type = "CNAME", name = "specialist-publisher", ttl = 3600, value = ["specialist-publisher.eks.production.govuk.digital."] },
  { type = "CNAME", name = "transition", ttl = 300, value = ["transition.eks.production.govuk.digital."] },
  { type = "CNAME", name = "transition-test", ttl = 300, value = ["bouncer-cdn.production.govuk.service.gov.uk."] },
  { type = "CNAME", name = "travel-advice-publisher", ttl = 3600, value = ["travel-advice-publisher.eks.production.govuk.digital."] },
  { type = "MX", name = "travel-advice-publisher.alert", ttl = 300, value = ["10 inbound-smtp.eu-west-1.amazonaws.com."] },
  { type = "CNAME", name = "try-new-search-engine", ttl = 3600, value = ["try-new-search-engine.eks.production.govuk.digital."] },
  { type = "CNAME", name = "github-webhook.dev", ttl = 3600, value = ["vast-lake-5107.herokuapp.com."] },
  { type = "CNAME", name = "asset-manager", ttl = 3600, value = ["assets-origin.eks.production.govuk.digital."] },
  { type = "CNAME", name = "components", ttl = 3600, value = ["graceful-diplodocus-ffrpnypo5ylbf0pfs28p5o7k.herokudns.com."] },
  { type = "CNAME", name = "support", ttl = 300, value = ["support.eks.production.govuk.digital."] },
  { type = "CNAME", name = "surveys", ttl = 3600, value = ["customdomain.smartsurvey.co.uk."] },
  { type = "CNAME", name = "status", ttl = 3600, value = ["xcz7hfscrbjs.stspg-customer.com."] },
  { type = "CNAME", name = "_90d4726a667139e7fc892ef7d439bbc1.dev", ttl = 10800, value = ["83f67e2584e6647f05216064ebb78544.89752f1622f555ec2c9bd7d8bc458929.comodoca.com."] },
  { type = "CNAME", name = "20018a471710f160ab3144a38023e155", ttl = 10800, value = ["41b1e2fd6551bb2c9f484a225184122cb6fad1f1.comodoca.com."] }, // pragma: allowlist secret
  { type = "CNAME", name = "_c24a8e44c6c094be91c86242bb551b8d", ttl = 3600, value = ["7fdbbdd49b55706b95c54bb18f11eeb2.efaa3bc1d00edbcd399b3e69676cfee3.21fc29fd6ec2b0dfe2d5.comodoca.com."] },
  { type = "CNAME", name = "docs.data-community", ttl = 3600, value = ["alphagov.github.io."] },
  { type = "CNAME", name = "_f0007b153fe893d93563eb3a1aa8f957.docs.data-community", ttl = 86400, value = ["_5128066b455eb200b84c908386353e7c.dxhlbxbsbv.acm-validations.aws."] },
  { type = "CNAME", name = "dns", ttl = 300, value = ["floating-blueberry-0v2fnhwrxrukdrmxzh1bio7m.herokudns.com."] },
  { type = "TXT", name = "_github-pages-challenge-alphagov.design-guide", ttl = 300, value = ["5560788dce22fe8b93575626647f77"] }, // pragma: allowlist secret
  { type = "CNAME", name = "design-guide", ttl = 300, value = ["alphagov.github.io."] },
  { type = "TXT", name = "_github-pages-challenge-alphagov.guidance", ttl = 300, value = ["ccb9432a9fba52e3163b5fbb73d5e7"] }, // pragma: allowlist secret
  { type = "CNAME", name = "guidance", ttl = 300, value = ["alphagov.github.io."] },
  { type = "CNAME", name = "whitehall-admin", ttl = 300, value = ["whitehall-admin.eks.production.govuk.digital."] },
  { type = "CNAME", name = "www-origin", ttl = 300, value = ["www-origin.eks.production.govuk.digital."] },
]

amazonmq_engine_version                       = "3.13"
amazonmq_deployment_mode                      = "CLUSTER_MULTI_AZ"
amazonmq_maintenance_window_start_day_of_week = "WEDNESDAY"
amazonmq_maintenance_window_start_time_utc    = "06:00"
amazonmq_host_instance_type                   = "mq.m5.xlarge"

amazonmq_govuk_chat_retry_message_ttl = 300000
