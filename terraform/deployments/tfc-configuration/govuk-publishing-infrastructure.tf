module "govuk-publishing-infrastructure-integration" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "govuk-publishing-infrastructure-integration"
  workspace_desc    = "This module manages AWS resources which are specific to GOV.UK Publishing."
  workspace_tags    = ["integration", "govuk-publishing-infrastructure", "eks", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/govuk-publishing-infrastructure/"
  trigger_patterns  = ["/terraform/deployments/govuk-publishing-infrastructure/**/*"]

  project_name = "govuk-infrastructure"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Non-Production (r/o)" = "write"
    "GOV.UK Production"           = "write"
  }

  variable_set_ids = [
    local.aws_credentials["integration"],
    local.gcp_credentials["integration"],
    module.variable-set-common.id,
    module.variable-set-integration.id,
    module.variable-set-amazonmq-integration.id,
    module.sensitive-variables.security_integration_id,
    module.sensitive-variables.waf_integration_id,
    module.govuk-publishing-infrastructure-variable-set-integration.id,
  ]
}

module "govuk-publishing-infrastructure-variable-set-integration" {
  source = "./variable-set"

  name = "govuk-publishing-infrastructure-integration-non-sensitive"

  tfvars = {
    subdomain_delegation_name_servers = {}
    subdomain_dns_records = [
      { type = "A", name = "@", ttl = 10800, value = ["151.101.0.144", "151.101.64.144", "151.101.128.144", "151.101.192.144"] },
      { type = "CNAME", name = "_acme-challenge", ttl = 3600, value = ["tgcqj5pd616ulzbjv9.fastly-validations.com."] },
      { type = "CNAME", name = "_9fe718d811f09809db412a7f98eb9ffb", ttl = 10800, value = ["5dd99c1fde2deb7076ac37f0b2be18a6.53330f7819da7606482bc76d77ca8777.ba9be94b9a84fd28d757.comodoca.com."] },
      { type = "CNAME", name = "chat", ttl = 3600, value = ["chat.eks.integration.govuk.digital."] },
      { type = "CNAME", name = "ckan", ttl = 3600, value = ["ckan.eks.integration.govuk.digital."] },
      { type = "CNAME", name = "govspeak-preview", ttl = 3600, value = ["govspeak-preview.eks.integration.govuk.digital."] },
      { type = "CNAME", name = "govuk-graphql", ttl = 3600, value = ["govuk-graphql.eks.integration.govuk.digital."] },
      { type = "CNAME", name = "govuk-ai-accelerator", ttl = 3600, value = ["govuk-ai-accelerator-app.eks.integration.govuk.digital."] },
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
  }
}

module "govuk-publishing-infrastructure-staging" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "govuk-publishing-infrastructure-staging"
  workspace_desc    = "This module manages AWS resources which are specific to GOV.UK Publishing."
  workspace_tags    = ["staging", "govuk-publishing-infrastructure", "eks", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/govuk-publishing-infrastructure/"
  trigger_patterns  = ["/terraform/deployments/govuk-publishing-infrastructure/**/*"]

  project_name = "govuk-infrastructure"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production" = "write"
  }

  variable_set_ids = [
    local.aws_credentials["staging"],
    local.gcp_credentials["staging"],
    module.variable-set-common.id,
    module.variable-set-staging.id,
    module.variable-set-amazonmq-staging.id,
    module.sensitive-variables.security_staging_id,
    module.sensitive-variables.waf_staging_id,
    module.govuk-publishing-infrastructure-variable-set-staging.id,
  ]
}

module "govuk-publishing-infrastructure-variable-set-staging" {
  source = "./variable-set"

  name = "govuk-publishing-infrastructure-staging-non-sensitive"

  tfvars = {
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
  }
}

module "govuk-publishing-infrastructure-production" {
  source = "github.com/alphagov/terraform-govuk-tfe-workspacer"

  organization      = var.organization
  workspace_name    = "govuk-publishing-infrastructure-production"
  workspace_desc    = "This module manages AWS resources which are specific to GOV.UK Publishing."
  workspace_tags    = ["production", "govuk-publishing-infrastructure", "eks", "aws"]
  terraform_version = var.terraform_version
  execution_mode    = "remote"
  working_directory = "/terraform/deployments/govuk-publishing-infrastructure/"
  trigger_patterns  = ["/terraform/deployments/govuk-publishing-infrastructure/**/*"]

  project_name = "govuk-infrastructure"
  vcs_repo = {
    identifier     = "alphagov/govuk-infrastructure"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  team_access = {
    "GOV.UK Production" = "write"
  }

  variable_set_ids = [
    local.aws_credentials["production"],
    local.gcp_credentials["production"],
    module.variable-set-common.id,
    module.variable-set-production.id,
    module.variable-set-amazonmq-production.id,
    module.sensitive-variables.security_production_id,
    module.sensitive-variables.waf_production_id,
    module.govuk-publishing-infrastructure-variable-set-production.id,
  ]
}

module "govuk-publishing-infrastructure-variable-set-production" {
  source = "./variable-set"

  name = "govuk-publishing-infrastructure-production-non-sensitive"

  tfvars = {
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
  }
}
