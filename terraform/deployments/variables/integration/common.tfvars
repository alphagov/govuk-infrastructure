govuk_aws_state_bucket              = "govuk-terraform-steppingstone-integration"
cluster_infrastructure_state_bucket = "govuk-terraform-integration"

cluster_log_retention_in_days = 7

govuk_environment             = "integration"
ecs_default_capacity_provider = "FARGATE_SPOT"

publishing_service_domain = "integration.publishing.service.gov.uk"
internal_app_domain       = "integration.govuk-internal.digital"
external_app_domain       = "integration.govuk.digital"
