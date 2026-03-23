subdomain_delegation_name_servers = {}
subdomain_dns_records = [
  { type = "A", name = "@", ttl = 3600, value = ["151.101.0.144", "151.101.64.144", "151.101.128.144", "151.101.192.144"] },
  { type = "TXT", name = "@", ttl = 3600, value = ["globalsign-domain-verification=mA2HaIifSZB8-qKkj2IFzxpZcLA8rkZfS7Y9zSS5BQ", "google-site-verification=M5Q0yBeU28XdlP78DtIzUcc6m63GXzYS4Rrkf2Ab7Ng"] }, // pragma: allowlist secret
  { type = "CNAME", name = "_acme-challenge", ttl = 3600, value = ["swkxpvjulr7u0dfqxo.fastly-validations.com."] },
  { type = "CNAME", name = "chat", ttl = 3600, value = ["chat.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "ckan", ttl = 3600, value = ["ckan.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "govspeak-preview", ttl = 3600, value = ["govspeak-preview.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "search", ttl = 3600, value = ["zd1o9hz5w5.execute-api.eu-west-1.amazonaws.com."] },
  { type = "CNAME", name = "asset-manager", ttl = 3600, value = ["assets-origin.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "assets", ttl = 300, value = ["www-gov-uk.map.fastly.net."] },
  { type = "CNAME", name = "assets-origin", ttl = 3600, value = ["assets-origin.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "account-api", ttl = 3600, value = ["account-api.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "bouncer", ttl = 3600, value = ["bouncer.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "collections-publisher", ttl = 3600, value = ["collections-publisher.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "content-block-manager", ttl = 3600, value = ["content-block-manager.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "contacts-admin", ttl = 3600, value = ["contacts-admin.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "content-data-api", ttl = 3600, value = ["content-data-api.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "content-data", ttl = 3600, value = ["content-data.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "content-data-admin", ttl = 3600, value = ["content-data.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "content-tagger", ttl = 3600, value = ["content-tagger.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "csp-reporter", ttl = 3600, value = ["csp-reporter.staging.govuk.digital."] },
  { type = "CNAME", name = "draft-assets", ttl = 3600, value = ["draft-assets.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "draft-origin", ttl = 3600, value = ["draft-origin.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "email-alert-api-public", ttl = 3600, value = ["email-alert-api.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "hmrc-manuals-api", ttl = 3600, value = ["hmrc-manuals-api.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "licensify-admin.eks", ttl = 3600, value = ["licensify-admin.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "licensify-admin", ttl = 3600, value = ["licensify-admin.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "licensify.eks", ttl = 3600, value = ["licensify.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "licensify", ttl = 3600, value = ["licensify.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "local-links-manager", ttl = 3600, value = ["local-links-manager.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "manuals-publisher", ttl = 3600, value = ["manuals-publisher.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "places-manager", ttl = 3600, value = ["places-manager.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "publisher", ttl = 3600, value = ["publisher.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "release", ttl = 3600, value = ["release.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "search-admin", ttl = 3600, value = ["search-admin.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "service-manual-publisher", ttl = 3600, value = ["service-manual-publisher.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "short-url-manager", ttl = 3600, value = ["short-url-manager.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "signon", ttl = 60, value = ["signon.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "specialist-publisher", ttl = 3600, value = ["specialist-publisher.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "support", ttl = 3600, value = ["support.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "transition", ttl = 3600, value = ["transition.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "travel-advice-publisher", ttl = 3600, value = ["travel-advice-publisher.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "try-new-search-engine", ttl = 3600, value = ["try-new-search-engine.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "whitehall-admin", ttl = 3600, value = ["whitehall-admin.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "www", ttl = 300, value = ["www-gov-uk.map.fastly.net."] },
  { type = "CNAME", name = "www-origin", ttl = 3600, value = ["www-origin.eks.staging.govuk.digital."] },
  { type = "CNAME", name = "5384b32d193a6e103ffb2d5dfde19731", ttl = 10800, value = ["e23b6d9e6e00c1bc4b8732ec65360e2173a3ec9b.comodoca.com."] }, // pragma: allowlist secret
  { type = "CNAME", name = "_bbd4dea834d458f83ac60848ca01c40e", ttl = 10800, value = ["_bbf4a50f6274672e86d2b03bf2baf9cd.acm-validations.aws."] },
  { type = "CNAME", name = "_1bae2c761ad955829733a3676595703b", ttl = 3600, value = ["7d714034d77f2078a33396b112a162f5.b8bd6c48a8ba5d47f49d3daf50191d3d.1f8c4b6a0115a4617e28.comodoca.com."] },
  { type = "CNAME", name = "_4c690fcb01db7a39d9506a525be87761", ttl = 3600, value = ["4d13df04115ed231f76cbb4fc99258aa.6aee3d49400d9c78c16b489b62b609d8.9b09b014d728789be571.comodoca.com."] },
]

amazonmq_engine_version                       = "3.13"
amazonmq_deployment_mode                      = "SINGLE_INSTANCE"
amazonmq_maintenance_window_start_day_of_week = "MONDAY"
amazonmq_maintenance_window_start_time_utc    = "07:00"
amazonmq_host_instance_type                   = "mq.m5.large"

amazonmq_govuk_chat_retry_message_ttl = 300000

frontend_memcached_node_type = "cache.t4g.medium"

licensify_documentdb_instance_count       = 1
licensify_backup_retention_period         = 1
shared_documentdb_instance_count          = 1
shared_documentdb_backup_retention_period = 1
