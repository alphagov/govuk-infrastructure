enable_govuk_ai_accelerator       = true
enable_govuk_ai_graph_tools       = true
subdomain_delegation_name_servers = {}
subdomain_dns_records = [
  { type = "A", name = "@", ttl = 10800, value = ["151.101.0.144", "151.101.64.144", "151.101.128.144", "151.101.192.144"] },
  { type = "CNAME", name = "_acme-challenge", ttl = 3600, value = ["tgcqj5pd616ulzbjv9.fastly-validations.com."] },
  { type = "CNAME", name = "_9fe718d811f09809db412a7f98eb9ffb", ttl = 10800, value = ["5dd99c1fde2deb7076ac37f0b2be18a6.53330f7819da7606482bc76d77ca8777.ba9be94b9a84fd28d757.comodoca.com."] },
  { type = "CNAME", name = "chat", ttl = 3600, value = ["chat.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "ckan", ttl = 3600, value = ["ckan.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "govspeak-preview", ttl = 3600, value = ["govspeak-preview.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "govuk-graphql", ttl = 3600, value = ["govuk-graphql.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "govuk-ai-accelerator-app", ttl = 3600, value = ["govuk-ai-accelerator-app.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "search", ttl = 3600, value = ["otxkvx7dv3.execute-api.eu-west-1.amazonaws.com."] },
  { type = "CNAME", name = "app", ttl = 3600, value = ["www-gov-uk.map.fastly.net."] },
  { type = "CNAME", name = "assets", ttl = 300, value = ["www-gov-uk.map.fastly.net."] },
  { type = "CNAME", name = "assets-origin", ttl = 3600, value = ["assets-origin.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "account-api", ttl = 3600, value = ["account-api.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "bouncer", ttl = 3600, value = ["bouncer.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "collections-publisher", ttl = 3600, value = ["collections-publisher.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "content-block-manager", ttl = 3600, value = ["content-block-manager.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "contacts-admin", ttl = 3600, value = ["contacts-admin.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "content-data-api", ttl = 3600, value = ["content-data-api.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "content-data", ttl = 3600, value = ["content-data.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "content-data-admin", ttl = 3600, value = ["content-data.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "content-tagger", ttl = 3600, value = ["content-tagger.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "csp-reporter", ttl = 3600, value = ["csp-reporter.integration.govuk.digital."] },
  { type = "CNAME", name = "draft-assets", ttl = 3600, value = ["draft-assets.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "draft-origin", ttl = 3600, value = ["draft-origin.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "email-alert-api-public", ttl = 3600, value = ["email-alert-api.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "fact-check-manager", ttl = 3600, value = ["fact-check-manager.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "hmrc-manuals-api", ttl = 3600, value = ["hmrc-manuals-api.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "licensify.eks", ttl = 3600, value = ["licensify.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "licensify", ttl = 3600, value = ["licensify.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "licensify-admin.eks", ttl = 3600, value = ["licensify-admin.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "licensify-admin", ttl = 3600, value = ["licensify-admin.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "local-links-manager", ttl = 3600, value = ["local-links-manager.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "manuals-publisher", ttl = 3600, value = ["manuals-publisher.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "places-manager", ttl = 3600, value = ["places-manager.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "publisher", ttl = 3600, value = ["publisher.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "release", ttl = 3600, value = ["release.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "search-admin", ttl = 3600, value = ["search-admin.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "service-manual-publisher", ttl = 3600, value = ["service-manual-publisher.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "short-url-manager", ttl = 3600, value = ["short-url-manager.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "signon", ttl = 3600, value = ["signon.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "specialist-publisher", ttl = 3600, value = ["specialist-publisher.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "support", ttl = 3600, value = ["support.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "transition", ttl = 3600, value = ["transition.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "travel-advice-publisher", ttl = 3600, value = ["travel-advice-publisher.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "try-new-search-engine", ttl = 3600, value = ["try-new-search-engine.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "whitehall-admin", ttl = 3600, value = ["whitehall-admin.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "www-origin", ttl = 3600, value = ["www-origin.eks.integration.govuk.digital."] },
  { type = "CNAME", name = "www", ttl = 300, value = ["www-gov-uk.map.fastly.net."] },
  { type = "CNAME", name = "_8856ba0659f8a69bd98fb06fe5af8497", ttl = 10800, value = ["e2441c6708c93ef690bee5c55fb15fef.fcc76c0a310c69d4fadba05cce6456ed.ac597b7eca2b4a550ad1.comodoca.com."] },
  { type = "CNAME", name = "_a4d6a03c03ec8aafae7f4908e7525e4e", ttl = 10800, value = ["_11dbbdf1b1b8c8a8457f6351c7de827a.nhqijqilxf.acm-validations.aws."] },
]

amazonmq_engine_version                       = "3.13"
amazonmq_deployment_mode                      = "SINGLE_INSTANCE"
amazonmq_maintenance_window_start_day_of_week = "MONDAY"
amazonmq_maintenance_window_start_time_utc    = "07:00"
amazonmq_host_instance_type                   = "mq.m5.large"

amazonmq_govuk_chat_retry_message_ttl = 300000

frontend_memcached_node_type = "cache.t4g.micro"

licensify_documentdb_instance_count       = 1
licensify_backup_retention_period         = 1
shared_documentdb_instance_count          = 1
shared_documentdb_backup_retention_period = 1
create_licensify_documentdb_clone         = true
