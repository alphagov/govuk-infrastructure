govuk_aws_state_bucket              = "govuk-terraform-steppingstone-integration"
cluster_infrastructure_state_bucket = "govuk-terraform-integration"

cluster_log_retention_in_days = 7

eks_control_plane_subnets = {
  a = { az = "eu-west-1a", cidr = "10.1.19.0/28" }
  b = { az = "eu-west-1b", cidr = "10.1.19.16/28" }
  c = { az = "eu-west-1c", cidr = "10.1.19.32/28" }
}

eks_public_subnets = {
  a = { az = "eu-west-1a", cidr = "10.1.20.0/24" }
  b = { az = "eu-west-1b", cidr = "10.1.21.0/24" }
  c = { az = "eu-west-1c", cidr = "10.1.22.0/24" }
}

eks_private_subnets = {
  a = { az = "eu-west-1a", cidr = "10.1.24.0/22" }
  b = { az = "eu-west-1b", cidr = "10.1.28.0/22" }
  c = { az = "eu-west-1c", cidr = "10.1.32.0/22" }
}

govuk_environment             = "integration"
ecs_default_capacity_provider = "FARGATE_SPOT"

publishing_service_domain = "integration.publishing.service.gov.uk"
internal_app_domain       = "integration.govuk-internal.digital"
external_app_domain       = "integration.govuk.digital"
